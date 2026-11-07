---
name: windows-env-pitfalls
description: Windows(PowerShell 5.1·Git Bash)에서 스크립트를 돌리거나 위임 프롬프트·프로젝트 지침을 쓸 때 쓴다. 인코딩, 한글 파일 쓰기, MCP 한글 본문 전송, 앱 컨테이너 가상화, 경로 함정의 대처를 정한다.
---

# Windows 환경 함정

우선순위: 실행 환경의 시스템 프롬프트·설정 > 사람의 지시 > 이 스킬. 부딪혀 결과가 달라졌으면 보고에 적는다.

## 순서
1. 위임 프롬프트와 프로젝트 지침에 아래 기본 블록을 그대로 붙인다.
   - 파이썬은 `python`으로만 부르고 `python3`·`py`는 쓰지 않는다(스토어 스텁이 설치 창을 연다).
   - 파이썬 실행 전 `$env:PYTHONIOENCODING='utf-8'`(PowerShell) 또는 `PYTHONIOENCODING=utf-8 python <파일>`(Git Bash)을 건다.
   - `-I` 격리 모드는 환경 변수를 무시하므로 코드 첫머리에서 `sys.stdout.reconfigure(encoding='utf-8')`를 부른다.
   - 한글이 들어간 긴 코드·정규식·백슬래시는 heredoc·here-string·`python -c`로 넘기지 않고 파일로 쓴 뒤 `python <파일>`로 실행한다.
   - 새 파일은 BOM 없는 UTF-8로 쓰고, 기존 파일의 줄바꿈(CRLF/LF)은 바꾸지 않는다.
   - 한글 결과는 콘솔에 찍지 않고 UTF-8 파일로 써서 파일 읽기 도구로 읽는다.
   - 문서에 적는 시각은 `Get-Date -Format s` 또는 `date` 출력을 복사한다.
   - 백그라운드 셸은 PATH가 비어 있을 수 있으니 빌드 도구를 전체 경로로 부른다.
   - 위임 프롬프트에 자동 수정 명령(`--fix`가 붙는 lint 등)을 넣지 않는다.
2. 명령이 이상하게 실패하면 아래 점검 표에서 증상을 먼저 찾는다.
3. 한글 본문을 MCP 도구로 보낼 때는 본문을 UTF-8 파일로 저장하고, 모델이 인자에 다시 타이핑하지 않게 스크립트가 파일을 읽어 그대로 보낸다.
4. 보낸 뒤 공개본을 받아 원본과 글자 수·해시를 비교해 차이 0을 확인한다.
5. 데스크톱 앱 패키지(MSIX) 안에서 도는 세션이면 아래 가상화 항목을 먼저 확인한다.
6. 같은 함정이 두 번 나오면 프로젝트 지침 문서에 한 줄로 박는다.

## 점검
| 증상·상황 | 대처 |
|---|---|
| PowerShell 5.1에서 `&&`·`||` 파서 오류 | `A; if ($?) { B }`로 쓴다 |
| `Set-Content`·`Add-Content`로 쓴 한글이 깨짐 | 기본이 ANSI라서 `-Encoding utf8`(BOM 붙음)을 쓰거나 `[IO.File]::WriteAllText($p, $s, (New-Object Text.UTF8Encoding $false))`로 쓴다 |
| 네이티브 명령에 `2>&1`을 붙이자 `$?`가 거짓 | stderr 줄이 오류 객체로 감싸지므로 리다이렉트하지 않는다 |
| 테스트 러너 stderr가 PowerShell에서 사라짐 | Git Bash에서 `2>&1`로 받는다 |
| psql에 한글 SQL | 옵션을 접속 문자열 앞에 두고 SQL은 UTF-8 파일로 `-f`에 넘긴다 |
| Git Bash `sed -i` 뒤 CRLF가 LF로 바뀜 | `open(p, newline='')`로 읽고 쓰는 파이썬 편집으로 바꾸고 치환 횟수가 1인지 assert한다 |
| sed 역슬래시 이스케이프로 문자열이 깨짐 | 치환을 파이썬 스크립트로 한다 |
| Git Bash가 `/sdcard` 같은 인자를 Windows 경로로 바꿈 | 명령 앞에 `MSYS_NO_PATHCONV=1`을 붙인다 |
| TSV·CSV 열 일부만 치환했더니 열이 합쳐짐 | 파일 전체를 파싱해 다시 쓴다 |
| 작업 폴더의 `select.py` 같은 파일이 표준 모듈을 가림 | 빈 하위 폴더에서 작업하고 표준 모듈 이름을 파일 이름으로 쓰지 않는다 |
| 긴 경로 폴더가 지워지지 않음 | 잡고 있는 프로세스를 먼저 끄고 `cmd /c rmdir /s /q "\\?\<절대 경로>"`를 쓴다 |
| 한글 경로에서 외부 도구가 실패 | ASCII 경로로 복사해 실행한다 |
| OneDrive 폴더의 수정 시각이 과거로 바뀜 | 완료·변경 판정은 수정 시각이 아니라 내용(해시·파싱)으로 한다 |
| 받은 웹 페이지가 euc-kr | 바이트로 받아 디코드한 뒤 UTF-8 파일로 저장해 읽는다 |
| exit 0인데 결과물이 옛것 | PATH 누락으로 다른 바이너리가 돌았거나 아무것도 안 돌았으니 산출물 해시·시각을 확인한다 |
| 모든 Bash 호출이 `-c: line N: unexpected EOF` | rc 파일이 아니라 셸 래퍼 문자열 문제로, 세션 시작 훅이 세션 env 파일에 export 줄을 중복으로 쌓은 경우가 있으니 세션을 재시작하고 훅에 중복 방지 가드를 넣는다(플러그인 업데이트 때 가드가 사라지는지 다시 확인) |
| 큰 폴더를 다른 드라이브로 옮김 | `safe-cleanup`의 이동 순서를 따른다 |
| 앱 패키지 세션에서 설치했는데 사람 터미널에 없음 | `%APPDATA%`·`%LOCALAPPDATA%` 쓰기가 패키지 `LocalCache`로 가상화된 것이며 세션 안 `Test-Path`는 참으로 나온다 |
| 위 가상화를 피하는 설치 | 홈 바로 아래(`~\.local\bin` 등)에 설치하고 도구별 설치 위치 변수(예: `UV_TOOL_DIR`)를 사용자 환경 변수로 고정하며 winget·`npm -g`·`pip --user`는 세션 안에서 쓰지 않는다 |
| 가상화 밖에서 검증 | `Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{CommandLine='cmd /c <명령> > %USERPROFILE%\probe.txt 2>&1'}`로 띄우고 홈 바로 아래 파일로 결과를 받는다 |
| 컨테이너 밖 프로세스와 파일 교환 | 임시 폴더(가상화 영역) 대신 홈 바로 아래 경로를 쓴다 |

## 하지 않는 것
- 증상만 보고 rc 파일·셸 설정을 고치지 않고, 오류가 `파일: line N`인지 `-c: line N`인지 먼저 구분한다.
- 한글 긴 본문을 도구 인자에 손으로 옮겨 적지 않는다(여러 편이 한꺼번에 손상된 사례).
- 줄바꿈을 정규화하는 편집 도구로 CRLF 파일을 고치지 않는다.
