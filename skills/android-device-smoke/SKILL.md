---
name: android-device-smoke
description: 빌드한 APK를 안드로이드 실기기에 올려 화면·흐름을 확인할 때 쓴다. adb 연결, 사용 중 확인, APK 대조, 설치·실행·로그·화면 캡처·권한 확인 순서와 판정 방식을 정한다.
---

# 안드로이드 실기기 스모크

우선순위: 실행 환경의 시스템 프롬프트·설정 > 사람의 지시 > 이 스킬. 부딪혀 결과가 달라졌으면 보고에 적는다.

## 순서
0. 아래 명령은 Windows·macOS 공통이고, `| grep` 필터만 PowerShell에서 `| Select-String '<패턴>'`으로 바꾼다.
1. 무선 adb는 기기 화면의 페어링 코드를 사람에게 받아 `adb pair <기기 주소:페어링 포트>`, `adb connect <기기 주소:연결 포트>` 순으로 붙는다.
2. `adb devices -l`에서 기기가 `device` 상태인지 본다.
3. 조작 전에 포그라운드 앱을 본다(`adb shell dumpsys activity activities | grep -E "topResumedActivity|mResumedActivity"`).
4. 사람이 다른 앱을 쓰는 중이면 멈추고 진행해도 되는지 묻는다.
5. 화면을 켠다(`adb shell input keyevent KEYCODE_WAKEUP`).
6. 설치할 APK의 해시와 빌드 시각을 빌드 로그와 대조한다(`Get-FileHash <apk>` / `shasum -a 256 <apk>`, 파일 수정 시각).
7. 버전을 본다(`aapt dump badging <apk>`의 `versionCode`), 한글 경로에서 실패하면 ASCII 경로로 복사해 다시 한다.
8. 설치한다(`adb install -r <apk>`).
9. 기기에 깔린 버전이 방금 본 값과 같은지 본다(`adb shell dumpsys package <패키지> | grep versionCode`).
10. 로그를 비우고 실행한다(`adb logcat -c`, `adb shell monkey -p <패키지> -c android.intent.category.LAUNCHER 1`).
11. 시나리오 화면마다 전환이 끝날 시간을 기다린 뒤 캡처한다(`adb shell screencap -p /sdcard/<이름>.png`, `adb pull /sdcard/<이름>.png <로컬 폴더>`).
12. Git Bash에서 `/sdcard` 인자가 바뀌면 `windows-env-pitfalls`의 경로 변환 항목을 따른다.
13. 로그를 받는다(`adb logcat -d --pid=$(adb shell pidof <패키지>) > <로그 파일>`, PowerShell은 `$p = adb shell pidof <패키지>` 뒤 `adb logcat -d --pid=$p > <로그 파일>`).
14. 권한 상태를 본다(`adb shell dumpsys package <패키지> | grep "granted="`).
15. 권한 거부 흐름도 본다(`adb shell pm revoke <패키지> <권한>` 뒤 재실행, 끝나면 `adb shell pm grant <패키지> <권한>`).
16. "앱이 켜지지 않고 백그라운드에서" 같은 요구는 동작 전후 포그라운드 액티비티가 바뀌지 않았는지로 확인한다.
17. 캡처는 메인이 원본 크기로 직접 보고 판정한다(`visual-output-qa`).
18. 기기에 만든 캡처 파일을 지운다(`adb shell rm /sdcard/<이름>.png`).

## 점검
| 항목 | 기준 |
|---|---|
| 설치본 | 해시·빌드 시각·versionCode가 빌드 기록과 기기 양쪽에서 같음 |
| 캡처 | 시나리오의 모든 화면에 캡처가 있고 전환 중 화면이 없음 |
| 로그 | 시나리오 동안 앱 프로세스의 `FATAL`·`AndroidRuntime` 줄 0 |
| 권한 | 허용·거부 두 흐름 모두 앱이 죽지 않음 |
| 사용자 기기 | 조작 시작 전 포그라운드 확인 기록이 있음 |

## 하지 않는 것
- 페어링 코드·기기 주소·포트를 문서·로그·커밋에 적지 않는다.
- 사람이 폰을 쓰는 중에 탭·설치·재부팅을 하지 않는다.
- 빌드 명령이 exit 0이었다는 것만 보고 설치본을 최신으로 보지 않는다.
- `adb exec-out`으로 캡처를 Windows 셸 파이프에 받지 않는다(바이트가 섞인다).
- 에이전트의 "화면 정상" 보고를 판정으로 쓰지 않는다.
