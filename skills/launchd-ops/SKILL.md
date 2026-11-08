---
name: launchd-ops
description: macOS에서 상시 서비스나 예약 작업을 launchd(LaunchAgent)로 등록·재등록·해제할 때 사용한다. plist 작성, 재시작 정책, 환경 변수, TCC 권한 래퍼, 로그 위치, 등록 확인과 사람이 쓰는 켜기·끄기 파일을 정한다.
---

# launchd 작업 운영

예약 작업 운영 공통 규칙(등록부 백업, 멈춤 감지, 설정 변경 주체)은 routine-ops를 따른다. 이 스킬은 macOS launchd에만 있는 것을 다룬다.

## 언제
- 봇·게이트웨이·수집기 같은 상시 프로세스를 macOS에서 띄울 때
- cron 대신 launchd로 주기 작업을 걸 때
- 등록한 작업이 안 돌거나, 꺼도 다시 살아날 때
- 보호 폴더 접근 때문에 무인 실행이 멈출 때

## 설치 스크립트
등록은 손으로 하지 않고 설치 스크립트로 한다.
1. plist를 임시 파일에 쓰고 `plutil -lint`로 검사한다.
2. 권한 0600으로 원자적으로 옮긴다(임시 파일 → 이름 바꾸기).
3. `--dry-run` 출력을 사람에게 보여 주고 승인을 받은 뒤 다시 등록한다: `launchctl bootout gui/$UID/<label> || true` → `launchctl enable gui/$UID/<label>` → `launchctl bootstrap gui/$UID <plist>`.
4. `launchctl print gui/$UID/<label>`로 상태·PID·마지막 종료 코드를 확인한다.
5. 스크립트에 `--dry-run`을 둔다. 실제로 바꾸지 않고 쓸 plist와 실행할 명령만 출력한다.
- 해제: bootout 뒤 plist를 지우지 않고 휴지통(또는 보관 폴더)으로 시각을 붙여 옮긴다.

## plist에 넣을 것
| 키 | 기준 |
|---|---|
| ProgramArguments | 실행 파일은 전체 경로. 셸을 거치면 `/bin/zsh -lc`가 아니라 스크립트 파일을 직접 |
| EnvironmentVariables | PATH, venv 경로, 홈 경로를 명시한다. launchd는 로그인 셸의 PATH를 모른다 |
| KeepAlive | 상시 프로세스는 `{SuccessfulExit: false}`. 무조건 true면 사람이 끄려고 kill해도 다시 산다 |
| ThrottleInterval | 재시작 간격(예: 30초). 바로 죽는 프로세스가 무한 재시작하지 않게 |
| ExitTimeOut | 종료 신호 뒤 기다릴 시간 |
| StandardOutPath·StandardErrorPath | `~/Library/Logs/<label>/` 아래 |
| LowPriorityIO, Nice | 배경 작업은 사람 작업보다 낮게 |
- 잠들면 안 되는 작업은 `caffeinate -i`로 감싼다.
- LaunchAgent는 사용자가 로그인해야 돈다. 재부팅 뒤 로그인 전에는 돌지 않는다는 것을 운영 문서에 적는다.

## TCC 보호 폴더
- launchd로 띄운 프로세스가 데스크톱·문서 폴더를 읽으면 허용 창에서 멈춘다.
- 먼저 데이터를 보호 폴더 밖으로 옮길 수 있는지 본다.
- 옮길 수 없으면 실행 스크립트를 앱 래퍼(AppleScript 애플릿 `.app`)로 감싸고 `open -g -a <앱>`으로 띄운다. 사람이 그 앱에 한 번 권한을 준다.
- 돌고 있는 예약 작업이 쓰는 경로는 옮기지 않는다. 옮겨야 하면 옛 경로에 심볼릭 링크를 남기거나, 링크를 모아 둔 폴더를 하나 두고 작업은 그 폴더를 가리키게 한다.

## 사람이 쓰는 파일
- 켜기·끄기·영구 해제를 `.command` 파일로 만들어 둔다. 사람이 더블클릭으로 쓰고, 에이전트 없이도 멈출 수 있다.
- 운영 문서에 라벨, plist 경로, 로그 경로, 켜기·끄기 파일 위치를 한 줄로 적는다.

## 등록 직후 확인
1. `launchctl print`의 상태가 running이거나, 주기 작업이면 다음 실행 조건이 맞다.
2. 로그 파일에 이번 실행의 첫 줄이 찍혔다.
3. 알림을 보내는 작업이면 시험 알림 1건을 보내 받는 쪽에서 확인한다.
4. 상시 프로세스는 하트비트 파일(마지막 동작 시각)을 남기게 하고, 상태는 프로세스 존재가 아니라 하트비트 나이로 판정한다.
5. 코드를 바꿨으면 돌고 있는 프로세스가 옛 코드인지 본다. 시작 시각이 코드 수정 시각보다 이르면 재시작이 필요하다고 보고한다.

## 하지 않는 것
- 사람 승인 없는 등록·해제(operating-principles의 예약 작업 설정 변경)
- 무조건 KeepAlive, PATH 없는 plist
- plist 바로 삭제, 돌고 있는 작업의 경로 이동

## 관련 스킬
routine-ops, scheduled-job-design, macos-env-pitfalls, operating-principles
