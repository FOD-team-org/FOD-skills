---
name: cross-device-handoff
description: 작업을 다른 기기(Windows와 macOS 사이 포함)로 옮기거나 넘겨받을 때 쓴다. 보내기 전 미커밋·브랜치·계정·비밀 파일 확인, git 밖 파일 목록, 받는 쪽 확인 명령을 정한다.
---

# 다른 기기로 인계

우선순위: 실행 환경의 시스템 프롬프트·설정 > 사람의 지시 > 이 스킬. 부딪혀 결과가 달라졌으면 보고에 적는다.

## 순서
### 보내는 쪽(명령은 Windows·macOS 같음, 다른 곳만 따로 적음)
1. 인계할 레포 목록을 적고 레포마다 아래를 돌린다.
2. `git status --porcelain` 출력이 0줄인지 본다.
3. `git stash list`와 `git worktree list`에 남은 작업이 없는지 본다.
4. `git branch -vv`에서 작업 브랜치가 모두 원격을 추적하고 `ahead` 표시가 없는지 본다.
5. `git log --branches --not --remotes --oneline` 출력이 0줄인지 본다.
6. `gh auth status`로 활성 계정이 이 프로젝트용 계정인지 보고, 아니면 활성 계정은 그대로 두고 그 명령에만 `GH_TOKEN="$(gh auth token --user <계정>)"`을 붙이거나 사람에게 묻는다.
7. `git config user.name`과 `git config user.email`이 프로젝트 기준 명의인지 본다.
8. 비밀 파일이 추적되는지 본다.
   - Windows: `git ls-files | Select-String -Pattern '\.env|\.pem|\.p12|\.keystore|credential|secret|token'`
   - macOS: `git ls-files | grep -Ei '\.env|\.pem|\.p12|\.keystore|credential|secret|token'`
9. 추적 파일 안에 키 모양 문자열이 있는지 본다(`git grep -nIE "(api[_-]?key|secret|token|password)\s*[:=]"`).
10. 비밀 파일이 이력에 들어간 적 있는지 본다(`git log --all --oneline -- .env`).
11. git으로 옮기지 않는 파일(키·서명 파일·로컬 DB·`.env`·대용량 원본·모델 가중치)을 수동 이동 목록으로 적는다: 파일 이름·용도·옮기는 방법·받는 쪽 위치.
12. 문서까지 커밋·푸시하고 브랜치별 `git rev-parse HEAD` 값을 인계 문서에 적는다.
13. 스케줄 작업·상시 서비스를 받는 쪽으로 옮기면 보내는 쪽 작업은 끄고 그 목록을 적는다(`routine-ops`).
14. 받는 쪽에서 따라 할 안내를 `user-task-guide` 형식으로 쓴다.

### 받는 쪽
1. `git clone` 또는 `git fetch --all` 뒤 브랜치별 `git rev-parse HEAD`가 인계 문서 값과 같은지 본다.
2. 수동 이동 목록의 파일이 제자리에 있는지 하나씩 본다(`Test-Path <경로>` / `test -f <경로> && echo ok`).
3. `.gitattributes`가 있으면 그 줄바꿈 기준을 따르고, `git status`에 줄바꿈만 바뀐 파일이 뜨지 않는지 본다.
4. 기기 경로가 박힌 설정을 찾는다(`git grep -nE "[A-Za-z]:[\\/]|/Users/|/home/"`).
5. 의존성을 설치하고 테스트·빌드 명령 하나를 돌려 보내는 쪽과 같은 결과인지 본다.
6. 옮겨 온 스케줄 작업은 받는 쪽에 등록한 뒤 첫 실행 결과를 확인한다.

## 점검
| 항목 | 기준 |
|---|---|
| 미커밋·미푸시 | 레포마다 출력 0줄 |
| 원격 일치 | 브랜치별 HEAD 해시가 양쪽 같음 |
| 비밀 | 추적 파일·내용·이력 검사 모두 0건 |
| 수동 목록 | git 밖 파일이 전부 목록에 있고 받는 쪽 확인을 마침 |
| 계정 | 푸시·레포 생성 전에 대상 계정과 조직을 확인함 |
| 동시 실행 | 같은 스케줄 작업이 두 기기에서 동시에 켜져 있지 않음 |

## 하지 않는 것
- 이미 푸시된 이력을 force push로 고치지 않는다.
- 비밀 값을 커밋·채팅·인계 문서 본문에 적지 않고 파일 이름과 위치만 적는다.
- 활성 계정을 확인하지 않고 레포를 만들거나 푸시하지 않는다.
- 사람이 승인하지 않은 레포는 푸시하지 않는다.
