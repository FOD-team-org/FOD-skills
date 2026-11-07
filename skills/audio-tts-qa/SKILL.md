---
name: audio-tts-qa
description: 나레이션·TTS가 들어간 영상의 소리를 내보내기 전에, 또는 TTS 엔진·목소리를 바꿀 때 쓴다. 라우드니스 측정 명령과 기준, 믹스·전사 점검, 엔진 폴백과 크레딧, 합성 캐시 관리를 정한다.
---

# 오디오·TTS 검수

우선순위: 실행 환경의 시스템 프롬프트·설정 > 사람의 지시 > 이 스킬. 부딪혀 결과가 달라졌으면 보고에 적는다.

## 순서
1. 측정은 믹스 wav가 아니라 AAC로 인코딩한 최종 mp4의 오디오를 디코딩해서 한다.
2. 통합·피크: `ffmpeg -hide_banner -nostats -i final.mp4 -map 0:a -af ebur128=peak=true -f null -` 끝 Summary의 I(LUFS), LRA, True peak를 적는다.
3. 보정값: `ffmpeg -hide_banner -nostats -i final.mp4 -map 0:a -af loudnorm=I=-14:TP=-1:LRA=11:print_format=json -f null -` 의 input_i, input_tp, input_lra를 2패스 보정에 넘긴다.
4. 순간 최대: `ffmpeg -hide_banner -nostats -i final.mp4 -map 0:a -af "ebur128=metadata=1,ametadata=mode=print:key=lavfi.r128.M:file=m.txt" -f null -` 뒤 `python -c "import re;print(max(map(float,re.findall(r'lavfi\.r128\.M=(-?[0-9.]+)',open('m.txt').read()))))"`
5. 끝 무음: `ffmpeg -hide_banner -nostats -i final.mp4 -map 0:a -af silencedetect=noise=-50dB:d=0.3 -f null -` 의 마지막 silence_start와 영상 길이를 비교한다.
6. 길이 대조: `ffprobe -v error -show_entries format=duration:stream=codec_type,duration -of compact final.mp4` 로 오디오가 영상보다 짧은지 본다(짧으면 무음 검출에 안 잡힌다).
7. 배경음 대역: `ffmpeg -hide_banner -nostats -i bgm.wav -af "highpass=f=1000,lowpass=f=4000,ebur128" -f null -` 로 말소리 대역(1~4kHz)에 배경음이 얼마나 들어오는지 잰다.
8. TTS 결과를 ASR로 다시 받아 적어 대본과 비교하고, 숫자·단위는 한 글자씩 대조한다.
9. 결과를 아래 점검 표에 채워 qa 기록 파일로 남긴다.

## 점검
| 항목 | 기준 |
|---|---|
| 목표 라우드니스 | 프로젝트가 정한 값 하나(예: 일반 -14 LUFS·TP -1 dBTP 이하, 잔잔한 콘텐츠 -16 LUFS·순간 최대 -10·TP -3 이하) |
| 측정 세 값 | I, 순간 최대, TP를 함께 적고 하나만 맞춘 채 통과시키지 않는다 |
| 끝 무음 | 마지막 말소리 뒤 2초 이하 |
| 효과음·배경음 | 비트 수·효과음 수를 세어 대본의 지시와 맞춘다 |
| 원음 덕킹 | 나레이션 아래 같은 언어 원음은 약 -18dB, 다른 언어 원음은 약 -12dB |
| 겹침 | 같은 언어 두 목소리를 같은 크기로 겹치지 않는다 |
| 주 음성 | 프로젝트 문서에 정한 방침을 따르고, 정한 것이 없으면 외국어 원음에 번역 자막만 달지 않고 나레이션을 주 음성으로 둔다 |
| 전사 오차 | ASR 대조 WER 10% 이하, 넘는 문장은 시작 부분 RMS를 재고 사람이 들어 본다 |
| 감정 | 감정은 문장으로 쓰고 TTS 자동 감정 옵션에 맡기지 않는다 |
| 부분 재합성 | 고칠 문장만 다시 합성한다, 전체 재합성은 빠르기가 바뀐다 |
| 예상 길이 | 실측한 초당 음절 수로 대본 길이를 계산해 슬롯에 맞춘다 |

## 엔진·목소리
- 엔진은 설정의 스위치 값으로 고르고, 이전 엔진은 폴백으로 남긴다.
- 키는 gitignore된 설정 파일에만 두고 코드·로그에 찍지 않는다.
- 크레딧 소진(HTTP 402)이 나오면 폴백본을 쌓지 말고 충전할지 사람에게 먼저 묻는다.
- 폴백 엔진으로 만든 판은 발행 후보로 쌓지 않는다.
- 목소리 비교 샘플은 같은 문단으로 조건 하나만 바꾸고, 숫자는 한글로 풀어 쓴다.
- 샘플의 빠르기·음량을 맞추고, 맞추지 못한 조건이 있으면 샘플 옆에 적는다.
- 목소리 채택은 사람이 듣고 정하며, 샘플마다 쓴 크레딧을 기록한다.

## 합성 캐시
- 빌더를 먼저 돌려 TTS 파일과 구간 경계를 얻고, 빌더 밖에서 따로 미리 합성하지 않는다.
- 캐시 키는 문장 텍스트 해시 사이드카이므로 문장 한 글자라도 바꾸면 재합성으로 본다.
- 길이 측정은 빌더가 쓰는 ffmpeg와 같은 실행 파일로 한다(버전마다 수십 밀리초 다르다).
- 같은 에피소드는 매번 같은 작업 폴더로 빌드하고, 시험 빌드 전에는 캐시 폴더를 복사해 둔다.
- 빌드 로그에 재합성이 한 건이라도 나오면 멈추고 원인을 보고한다.
- 빌드 메타 파일은 빌더만 쓴다.

## 하지 않는 것
- wav 측정값으로 최종본 라우드니스를 갈음하지 않는다.
- ASR 오인식을 근거로 TTS를 바로 다시 합성하지 않는다, 먼저 사람이 들어 본다.
- 크레딧이 없다고 사람 확인 없이 다른 엔진으로 바꿔 계속 빌드하지 않는다.
