#!/usr/bin/env bash
# FOD-skills installer (macOS, Linux, Git Bash on Windows).
# Copies skills/*/ into Claude Code (~/.claude/skills) and/or Codex
# ($CODEX_HOME/skills, default ~/.codex/skills). No network, no config edits.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MARKER_FILE=".fod-skills"
AGENTS_MARKER="<!-- fod-skills:codex-dev -->"

TARGET="both"
TARGET_SET=0
ONLY=""
DRY_RUN=0
PROJECT=""

usage() {
  cat <<'EOF'
Usage: install.sh [--target claude|codex|both] [--only a,b] [--dry-run] [--project DIR]

  --target   where to install skills (default: both)
  --only     comma-separated skill names to install (default: all)
  --dry-run  print what would be done, change nothing
  --project  install the codex-dev playbook (AGENTS.md, DECISIONS.md,
             ASSUMPTIONS.md) into DIR. With --project, skills are installed
             only when --target is also given.

Existing skill folders are skipped unless they contain a .fod-skills marker
(installed earlier by this script), in which case they are replaced.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --target) [ $# -ge 2 ] || { echo "error: --target needs a value" >&2; exit 2; }
              TARGET="$2"; TARGET_SET=1; shift 2 ;;
    --target=*) TARGET="${1#*=}"; TARGET_SET=1; shift ;;
    --only) [ $# -ge 2 ] || { echo "error: --only needs a value" >&2; exit 2; }
            ONLY="$2"; shift 2 ;;
    --only=*) ONLY="${1#*=}"; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    --project) [ $# -ge 2 ] || { echo "error: --project needs a value" >&2; exit 2; }
               PROJECT="$2"; shift 2 ;;
    --project=*) PROJECT="${1#*=}"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "error: unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

case "$TARGET" in
  claude|codex|both) ;;
  *) echo "error: --target must be claude, codex or both (got: $TARGET)" >&2; exit 2 ;;
esac

if [ "$DRY_RUN" -eq 1 ]; then echo "dry-run: no files will be changed"; fi

COMMIT="unknown"
if command -v git >/dev/null 2>&1; then
  COMMIT="$(git -C "$ROOT" rev-parse HEAD 2>/dev/null || echo unknown)"
fi

# ---- skill list ----------------------------------------------------------
ALL_SKILLS=()
for d in "$ROOT"/skills/*/; do
  [ -d "$d" ] || continue
  ALL_SKILLS+=("$(basename "$d")")
done

SKILLS=()
if [ -n "$ONLY" ]; then
  IFS=',' read -r -a WANT <<<"$ONLY"
  missing=0
  for w in ${WANT[@]+"${WANT[@]}"}; do
    w="$(echo "$w" | tr -d '[:space:]')"
    [ -n "$w" ] || continue
    if [ -d "$ROOT/skills/$w" ]; then SKILLS+=("$w")
    else echo "error: no such skill: $w" >&2; missing=1; fi
  done
  [ "$missing" -eq 0 ] || exit 2
else
  SKILLS=(${ALL_SKILLS[@]+"${ALL_SKILLS[@]}"})
fi

install_skills() {
  local dest="$1" installed=0 updated=0 skipped=0 n src dst
  echo "== skills -> $dest"
  if [ "$DRY_RUN" -eq 0 ]; then mkdir -p "$dest"; fi
  for n in ${SKILLS[@]+"${SKILLS[@]}"}; do
    src="$ROOT/skills/$n"
    dst="$dest/$n"
    if [ -e "$dst" ]; then
      if [ -f "$dst/$MARKER_FILE" ]; then
        if [ "$DRY_RUN" -eq 1 ]; then echo "would update: $n"
        else
          rm -rf "$dst"
          cp -R "$src" "$dst"
          printf '%s\n' "$COMMIT" >"$dst/$MARKER_FILE"
          echo "update: $n"
        fi
        updated=$((updated + 1))
      else
        echo "skip: $n"
        skipped=$((skipped + 1))
      fi
    else
      if [ "$DRY_RUN" -eq 1 ]; then echo "would install: $n"
      else
        cp -R "$src" "$dst"
        printf '%s\n' "$COMMIT" >"$dst/$MARKER_FILE"
        echo "install: $n"
      fi
      installed=$((installed + 1))
    fi
  done
  [ "$DRY_RUN" -eq 1 ] && printf "dry-run: "
  echo "installed $installed, updated $updated, skipped $skipped ($dest)"
}

install_project() {
  local dir="$1" installed=0 updated=0 skipped=0 f
  local pb="$ROOT/playbooks/codex-dev"
  echo "== codex-dev playbook -> $dir"
  if [ ! -d "$dir" ]; then echo "error: project folder not found: $dir" >&2; exit 2; fi
  if [ ! -f "$dir/AGENTS.md" ]; then
    if [ "$DRY_RUN" -eq 1 ]; then echo "would create: AGENTS.md"
    else
      { printf '%s\n\n' "$AGENTS_MARKER"; cat "$pb/AGENTS.md"; } >"$dir/AGENTS.md"
      echo "create: AGENTS.md"
    fi
    installed=$((installed + 1))
  elif grep -qF "$AGENTS_MARKER" "$dir/AGENTS.md"; then
    echo "skip: AGENTS.md (already appended)"
    skipped=$((skipped + 1))
  else
    if [ "$DRY_RUN" -eq 1 ]; then echo "would append: AGENTS.md"
    else
      { printf '\n\n%s\n\n' "$AGENTS_MARKER"; cat "$pb/AGENTS.md"; } >>"$dir/AGENTS.md"
      echo "append: AGENTS.md"
    fi
    updated=$((updated + 1))
  fi
  for f in DECISIONS.md ASSUMPTIONS.md; do
    if [ -e "$dir/$f" ]; then
      echo "skip: $f"
      skipped=$((skipped + 1))
    else
      if [ "$DRY_RUN" -eq 1 ]; then echo "would copy: $f"
      else cp "$pb/templates/$f" "$dir/$f"; echo "copy: $f"; fi
      installed=$((installed + 1))
    fi
  done
  [ "$DRY_RUN" -eq 1 ] && printf "dry-run: "
  echo "installed $installed, updated $updated, skipped $skipped ($dir)"
}

DO_SKILLS=1
if [ -n "$PROJECT" ] && [ "$TARGET_SET" -eq 0 ]; then DO_SKILLS=0; fi

if [ "$DO_SKILLS" -eq 1 ]; then
  if [ "$TARGET" = "claude" ] || [ "$TARGET" = "both" ]; then
    install_skills "$HOME/.claude/skills"
  fi
  if [ "$TARGET" = "codex" ] || [ "$TARGET" = "both" ]; then
    install_skills "${CODEX_HOME:-$HOME/.codex}/skills"
  fi
fi

if [ -n "$PROJECT" ]; then
  install_project "$PROJECT"
fi

if [ "$DRY_RUN" -eq 0 ]; then
  echo "done. Restart Claude Code / Codex to load new skills."
fi
