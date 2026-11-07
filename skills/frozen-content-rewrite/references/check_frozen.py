"""원본과 재작성본을 대조해 고정 항목이 빠지거나 바뀌었는지 검사한다.

예:
  python check_frozen.py 원본.md 재작성.md
  python check_frozen.py 원본.md 재작성.md --terms terms.txt --len-min 0.10 --len-max 0.35

검사 항목:
  1. 제목 줄(# 로 시작) 텍스트와 순서
  2. 표 줄(| 로 시작) 수, 인용·박스 줄(> 로 시작) 수
  3. 숫자 다중집합(쉼표 제거, 같은 숫자가 몇 번 나오는지까지)
  4. URL 집합
  5. 용어 목록(--terms, 한 줄에 하나) 각각의 등장 횟수가 원본 이상인지
  6. 공백 뺀 글자 수 변화율이 --len-min ~ --len-max 안인지
하나라도 어긋나면 내용을 출력하고 종료 코드 1을 돌려준다.
"""
import argparse
import re
import sys
from collections import Counter

NUM = re.compile(r"\d[\d,]*(?:\.\d+)?")
URL = re.compile(r"https?://[^\s)\]>\"']+")


def load(path):
    with open(path, encoding="utf-8") as f:
        return f.read()


def headings(text):
    return [l.lstrip("#").strip() for l in text.splitlines() if l.startswith("#")]


def count_prefix(text, p):
    return sum(1 for l in text.splitlines() if l.lstrip().startswith(p))


def numbers(text):
    return Counter(n.replace(",", "") for n in NUM.findall(URL.sub("", text)))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("original")
    ap.add_argument("rewrite")
    ap.add_argument("--terms")
    ap.add_argument("--len-min", type=float, default=-0.05)
    ap.add_argument("--len-max", type=float, default=0.35)
    a = ap.parse_args()
    o, r = load(a.original), load(a.rewrite)
    fails = []

    if headings(o) != headings(r):
        fails.append("제목 다름: 원본 %s / 재작성 %s" % (headings(o), headings(r)))
    for p, name in (("|", "표 줄"), (">", "인용·박스 줄")):
        if count_prefix(o, p) != count_prefix(r, p):
            fails.append("%s 수 다름: %d -> %d" % (name, count_prefix(o, p), count_prefix(r, p)))

    no, nr = numbers(o), numbers(r)
    if no != nr:
        missing, added = no - nr, nr - no
        fails.append("숫자 다름: 빠짐 %s / 추가 %s" % (dict(missing), dict(added)))

    uo, ur = set(URL.findall(o)), set(URL.findall(r))
    if uo != ur:
        fails.append("URL 다름: 빠짐 %s / 추가 %s" % (sorted(uo - ur), sorted(ur - uo)))

    if a.terms:
        for t in (x.strip() for x in load(a.terms).splitlines()):
            if t and r.count(t) < o.count(t):
                fails.append("용어 줄어듦: %s %d -> %d" % (t, o.count(t), r.count(t)))

    lo, lr = len(re.sub(r"\s", "", o)), len(re.sub(r"\s", "", r))
    ratio = (lr - lo) / lo if lo else 0.0
    if not (a.len_min <= ratio <= a.len_max):
        fails.append("길이 변화 %+.1f%% 가 범위 %+.0f%%~%+.0f%% 밖" % (ratio * 100, a.len_min * 100, a.len_max * 100))

    print("길이 변화 %+.1f%%, 숫자 %d개, URL %d개, 실패 %d건" % (ratio * 100, sum(no.values()), len(uo), len(fails)))
    for f in fails:
        print("FAIL", f)
    sys.exit(1 if fails else 0)


if __name__ == "__main__":
    main()
