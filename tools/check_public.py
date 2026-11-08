"""Scan the repository for things that should not be published.

Usage: python tools/check_public.py [ROOT]

Prints one line per finding as `path:line: kind: match` and exits 1 when
there is at least one finding. Lines marked `info-...` are shown for review
but do not count: `@name` inside Markdown code or in source files (usually a
decorator), `@scope/` package names, and 0.0.0.0 / 127.x addresses.

Checks: e-mail, IPv4, @handle, API key shapes (sk-, ghp_, github_pat_, AKIA),
user home paths (<drive>:/Users/<name>, /Users/<name>/, /home/<name>/), the em dash
character, and every word in tools/denylist.txt if that file exists.
Standard library only.
"""

from __future__ import annotations

import os
import re
import sys

SKIP_DIRS = {".git", "__pycache__", "node_modules"}
DENYLIST_REL = "tools/denylist.txt"
MARKDOWN_EXT = {".md", ".markdown", ".mdx"}

EM_DASH = "\u2014"

PATTERNS = [
    ("email", re.compile(r"[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}")),
    ("ipv4", re.compile(r"(?<![\d.])(?:(?:25[0-5]|2[0-4]\d|1?\d?\d)\.){3}(?:25[0-5]|2[0-4]\d|1?\d?\d)(?![\d.])")),
    ("key", re.compile(r"(?<![A-Za-z0-9])sk-[A-Za-z0-9_-]{16,}")),
    ("key", re.compile(r"(?<![A-Za-z0-9])ghp_[A-Za-z0-9]{20,}")),
    ("key", re.compile(r"(?<![A-Za-z0-9])github_pat_[A-Za-z0-9_]{20,}")),
    ("key", re.compile(r"(?<![A-Za-z0-9])AKIA[0-9A-Z]{16}")),
    ("user-path", re.compile(r"[A-Za-z]:[\\/]+Users[\\/]+[^\\/\s`'\"<>]*")),
    ("user-path", re.compile(r"(?<![\w.:])/(?:Users|home)/[^/\s`'\"<>]+/")),
    ("dash", re.compile(re.escape(EM_DASH))),
]

HANDLE_RE = re.compile(r"(?<![\w.@/\\-])@[A-Za-z0-9_][A-Za-z0-9_.]*[A-Za-z0-9_]|(?<![\w.@/\\-])@[A-Za-z0-9_]")
LOCAL_IPS = re.compile(r"^(?:0\.0\.0\.0|127\.\d+\.\d+\.\d+)$")
INLINE_CODE_RE = re.compile(r"(`+)(.+?)\1")
FENCE_RE = re.compile(r"^\s*(```|~~~)")
NPM_SCOPE_TAIL = re.compile(r"[\w.-]*/")


def load_denylist(root: str) -> list[str]:
    path = os.path.join(root, *DENYLIST_REL.split("/"))
    if not os.path.isfile(path):
        return []
    words = []
    with open(path, encoding="utf-8-sig", errors="replace") as fh:
        for raw in fh:
            word = raw.strip()
            if word and not word.startswith("#"):
                words.append(word)
    return words


def read_text(path: str) -> str | None:
    try:
        with open(path, "rb") as fh:
            data = fh.read()
    except OSError:
        return None
    if b"\0" in data[:8192]:
        return None
    try:
        return data.decode("utf-8-sig")
    except UnicodeDecodeError:
        return data.decode("utf-8", errors="replace")


def code_spans(line: str) -> list[tuple[int, int]]:
    return [(m.start(), m.end()) for m in INLINE_CODE_RE.finditer(line)]


def in_spans(pos: int, spans: list[tuple[int, int]]) -> bool:
    return any(a <= pos < b for a, b in spans)


def scan_file(path: str, rel: str, deny: list[str]) -> tuple[list[str], list[str]]:
    text = read_text(path)
    if text is None:
        return [], []
    is_md = os.path.splitext(path)[1].lower() in MARKDOWN_EXT
    hits: list[str] = []
    infos: list[str] = []
    in_fence = False
    for lineno, line in enumerate(text.splitlines(), 1):
        if is_md and FENCE_RE.match(line):
            in_fence = not in_fence
            fence_line = True
        else:
            fence_line = False

        email_spans = []
        for kind, rx in PATTERNS:
            for m in rx.finditer(line):
                value = m.group(0)
                if kind == "email":
                    email_spans.append((m.start(), m.end()))
                if kind == "dash":
                    infos.append(f"{rel}:{lineno}: info-dash: {value}")
                    continue
                if kind == "ipv4" and LOCAL_IPS.match(value):
                    infos.append(f"{rel}:{lineno}: info-ipv4-local: {value}")
                    continue
                hits.append(f"{rel}:{lineno}: {kind}: {value}")

        spans = code_spans(line) if is_md else []
        for m in HANDLE_RE.finditer(line):
            if in_spans(m.start(), email_spans):
                continue
            value = m.group(0)
            if NPM_SCOPE_TAIL.match(line, m.end()):
                infos.append(f"{rel}:{lineno}: info-npm-scope: {value}")
            elif not is_md or in_fence or fence_line or in_spans(m.start(), spans):
                infos.append(f"{rel}:{lineno}: info-handle: {value}")
            else:
                hits.append(f"{rel}:{lineno}: handle: {value}")

        lower = line.lower()
        for word in deny:
            start = 0
            wl = word.lower()
            while True:
                idx = lower.find(wl, start)
                if idx < 0:
                    break
                hits.append(f"{rel}:{lineno}: denylist: {line[idx:idx + len(word)]}")
                start = idx + len(wl)
    return hits, infos


def main(argv: list[str]) -> int:
    if len(argv) > 1:
        root = os.path.abspath(argv[1])
    else:
        root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    deny = load_denylist(root)
    deny_abs = os.path.normcase(os.path.join(root, *DENYLIST_REL.split("/")))

    all_hits: list[str] = []
    all_infos: list[str] = []
    files = 0
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = sorted(d for d in dirnames if d not in SKIP_DIRS)
        for name in sorted(filenames):
            path = os.path.join(dirpath, name)
            if os.path.normcase(path) == deny_abs:
                continue
            rel = os.path.relpath(path, root).replace(os.sep, "/")
            hits, infos = scan_file(path, rel, deny)
            files += 1
            all_hits.extend(hits)
            all_infos.extend(infos)

    out = sys.stdout
    for line in all_hits:
        out.write(line + "\n")
    for line in all_infos:
        out.write(line + "\n")
    out.write(
        f"scanned {files} files, {len(all_hits)} findings, {len(all_infos)} info"
        f" (denylist: {len(deny)} words)\n"
    )
    return 1 if all_hits else 0


if __name__ == "__main__":
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")  # type: ignore[attr-defined]
    except (AttributeError, ValueError):
        pass
    sys.exit(main(sys.argv))
