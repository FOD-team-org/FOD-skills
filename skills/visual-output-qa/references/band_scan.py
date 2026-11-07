"""영상의 한 띠(직사각형 영역)를 전 프레임 스캔해 조건에 맞는 픽셀 수를 센다.

쓰임: 크롭 뒤에 남은 로고·자막바·레이블·반짝이 잔상처럼 몇 프레임만 나오는 요소를 찾는다.

예:
  python band_scan.py reel.mp4 --box 0:1620:1080:1919 --expr "(L>170)|((r-g>35)&(r>120))"
  python band_scan.py reel.mp4 --box 0:0:24:1920 --expr "(r>150)&(g<80)&(b<80)" --min-pixels 20

--box 는 x0:y0:x1:y1 (끝 좌표 포함). --expr 은 numpy 식이며 r, g, b(0~255 정수)와 L(밝기)을 쓸 수 있다.
출력은 조건에 걸린 프레임 구간(시작 프레임, 끝 프레임, 길이, 최대 픽셀 수)이다. 프레임 번호는 0부터 센 원본 순서다.
걸린 구간이 하나라도 있으면 종료 코드 1을 돌려준다.
"""
import argparse
import json
import subprocess
import sys

import numpy as np


def probe_size(path):
    out = subprocess.run(
        ["ffprobe", "-v", "error", "-select_streams", "v:0",
         "-show_entries", "stream=width,height", "-of", "json", path],
        capture_output=True, text=True, check=True).stdout
    s = json.loads(out)["streams"][0]
    return int(s["width"]), int(s["height"])


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("video")
    ap.add_argument("--box", required=True, help="x0:y0:x1:y1, 끝 좌표 포함")
    ap.add_argument("--expr", required=True, help="numpy 조건식, 변수 r g b L")
    ap.add_argument("--min-pixels", type=int, default=1, help="이 수 이상 걸리면 그 프레임을 걸림으로 본다")
    args = ap.parse_args()

    w, h = probe_size(args.video)
    x0, y0, x1, y1 = (int(v) for v in args.box.split(":"))
    x1, y1 = min(x1, w - 1), min(y1, h - 1)
    cw, ch = x1 - x0 + 1, y1 - y0 + 1
    if cw <= 0 or ch <= 0:
        sys.exit("box 가 프레임 밖이다: 프레임 %dx%d" % (w, h))

    cmd = ["ffmpeg", "-v", "error", "-i", args.video, "-map", "0:v:0",
           "-vf", "crop=%d:%d:%d:%d" % (cw, ch, x0, y0),
           "-fps_mode", "passthrough", "-f", "rawvideo", "-pix_fmt", "rgb24", "-"]
    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE)
    frame_bytes = cw * ch * 3
    counts = []
    while True:
        buf = proc.stdout.read(frame_bytes)
        if len(buf) < frame_bytes:
            break
        a = np.frombuffer(buf, np.uint8).reshape(ch, cw, 3).astype(np.int16)
        r, g, b = a[..., 0], a[..., 1], a[..., 2]
        L = (0.299 * r + 0.587 * g + 0.114 * b)
        mask = eval(args.expr, {"__builtins__": {}}, {"r": r, "g": g, "b": b, "L": L, "np": np})
        counts.append(int(np.count_nonzero(mask)))
    proc.wait()

    runs, start = [], None
    for i, c in enumerate(counts + [0]):
        hit = c >= args.min_pixels and i < len(counts)
        if hit and start is None:
            start = i
        elif not hit and start is not None:
            runs.append((start, i - 1, i - start, max(counts[start:i])))
            start = None

    print("frames=%d box=%d:%d:%d:%d hits=%d" % (len(counts), x0, y0, x1, y1, len(runs)))
    for s, e, n, m in runs:
        print("run start=%d end=%d len=%d max_pixels=%d" % (s, e, n, m))
    sys.exit(1 if runs else 0)


if __name__ == "__main__":
    main()
