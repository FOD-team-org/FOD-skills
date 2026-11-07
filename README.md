# FOD-skills

Claude Code와 Codex가 함께 읽는 작업 스킬 모음. 스킬 45개, Codex 개발 묶음 1개, 설치 스크립트 2개.

## 우선순위

| 순위 | 무엇 |
|---|---|
| 1 | 실행 환경의 시스템 프롬프트·설정 |
| 2 | 사람이 채팅으로 준 지시 |
| 3 | 이 저장소의 스킬·묶음 |

- 모든 스킬 첫머리에 같은 줄이 있다(영문 원본을 그대로 둔 `bro`·`how` 제외).
- 부딪혀서 결과가 달라졌으면 보고에 적는다.
- 스킬에 적힌 시간·횟수·임계값은 기본값이고, 프로젝트 문서에 값이 있으면 그 값을 따른다.

## 설치

| 환경 | 명령 |
|---|---|
| macOS·Linux·Git Bash | `bash install/install.sh [claude\|codex\|both] [--dry-run] [--project <dir>]` |
| Windows PowerShell 5.1+ | `powershell -NoProfile -ExecutionPolicy Bypass -File install\install.ps1 [claude\|codex\|both] [--dry-run] [--project <dir>]` |

| 옵션 | 하는 일 |
|---|---|
| `claude` / `codex` / `both` | 복사할 곳: `~/.claude/skills/`, `${CODEX_HOME:-~/.codex}/skills/`, 둘 다(기본) |
| `--dry-run` | 할 일만 출력하고 쓰지 않음 |
| `--home <dir>` | 홈 대신 쓸 폴더(시험용, `CODEX_HOME` 무시) |
| `--project <dir>` | 그 폴더에 `packs/codex-dev`의 `AGENTS.md`·`DECISIONS.md`·`ASSUMPTIONS.md` 설치 |

- [ ] 같은 이름의 스킬 폴더가 있으면 덮어쓰지 않고 건너뛴다.
- [ ] 설정·인증 파일은 건드리지 않는다.
- [ ] 기존 `AGENTS.md`는 표지 주석과 함께 아래에 이어 붙이고, 이미 붙였으면 건너뛴다.
- [ ] 마지막 줄: `설치 N / 건너뜀 M / 전체 K`.
- [ ] 업데이트: 바꿀 스킬 폴더를 지우거나 옮긴 뒤 다시 설치한다.

## 스킬 목록

### 1. 일하는 방식

| 스킬 | 언제 |
|---|---|
| `operating-principles` | 모든 작업의 시작, 판단이 갈릴 때 |
| `delegation-loop` | 실행 작업을 서브에이전트에 맡길 때 |
| `codex-delegation` | Codex CLI에 토의·검수·이미지 생성·GUI 조작을 맡길 때 |
| `multi-ai-review` | 여러 AI 모델에게 토의·검수를 시킬 때 |
| `evidence-status-report` | 진행·상태·원인 질문에 답할 때, 완료 보고 전 |
| `user-task-guide` | 사람이 직접 해야 하는 일(로그인·결제·앱 설정)을 안내할 때 |
| `project-docs` | 새 프로젝트 문서 체계를 잡거나 정리할 때 |
| `hypothesis-experiment` | 형식·프롬프트·플레이북을 바꿔 보고 판정할 때 |
| `reference-benchmark` | 잘된 레퍼런스를 재고 구조를 분해할 때 |
| `idea-screening` | 아이디어·소재 후보를 거를 때 |
| `paced-research` | 속도 제한을 지키며 웹·영상 자료를 모을 때 |
| `performance-insights` | 게시 후 지표를 모으고 비교할 때 |

### 2. 콘텐츠 품질

| 스킬 | 언제 |
|---|---|
| `fact-check-gate` | 숫자·고유명사·인용·데이터 그림이 들어갈 때 |
| `korean-voice-review` | 사람이 쓴 한국어 대본·글을 내보내기 전 |
| `frozen-content-rewrite` | 내용은 고정하고 문체만 바꿀 때(검사기 포함) |
| `visual-output-qa` | 영상·이미지·화면 결과물을 채택하기 전(띠 스캔 스크립트 포함) |
| `audio-tts-qa` | 나레이션·TTS 소리를 내보내기 전, 엔진을 바꿀 때 |
| `short-video-pipeline` | 짧은 세로 영상을 꾸준히 만들 때 |
| `asset-rights-check` | 남의 사진·영상·음악·글꼴을 넣기 전, 권리 신고가 왔을 때 |
| `blog-post-pipeline` | 검색 유입용 블로그 글을 꾸준히 쓸 때 |

### 3. 운영·개발 보조

| 스킬 | 언제 |
|---|---|
| `safe-publish` | 게시하거나 자동·예약 게시 도구를 만들 때 |
| `routine-ops` | 정기 루틴을 등록·점검·복구할 때 |
| `safe-cleanup` | 디스크·프로세스 정리, 큰 폴더 이동 |
| `windows-env-pitfalls` | Windows에서 스크립트·위임 프롬프트를 쓸 때 |
| `cross-device-handoff` | 다른 기기로 작업을 넘기거나 받을 때 |
| `external-tool-vetting` | 외부 도구·플러그인을 들이기 전 |
| `service-access-hardening` | 소수 인원용 비공개 서비스를 열 때 |
| `privacy-compliance-check` | 개인정보·위치정보를 다루거나 스토어 심사 전 |
| `android-device-smoke` | APK를 실기기에서 확인할 때 |

### 4. 개발(Codex 개발 묶음과 같이 씀)

| 스킬 | 언제 |
|---|---|
| `problem-definition` | 설계 전에 진짜 문제를 사람과 정할 때 |
| `judgment` | 요구사항에 답이 없는 판단을 만났을 때 |
| `default-stack` | 스택이 정해지지 않았을 때(React·NestJS·PostgreSQL) |
| `design-doc` | 빌드 시작·끝에 설계도(DESIGN.md)를 맞출 때 |
| `ui-baseline` | 웹 화면을 만들거나 고칠 때 |
| `data-edge-tests` | CSV·JSON을 읽고 집계하는 코드를 만들 때 |
| `http-roundtrip-test` | 웹 API 테스트를 만들 때 |
| `data-exposure-guard` | 응답·화면·내보내기·로그에 고객 데이터가 나갈 때 |
| `llm-feature-guard` | LLM 호출 기능이 있을 때 |
| `security-check` | 웹 서비스를 다 만든 뒤 보안 확인 |
| `mutation-check` | 완료라고 말하기 직전 테스트 확인 |
| `counterexample-review` | 만든 코드를 요구사항과 대조해 결함을 찾을 때 |
| `bug-fix` | 결함을 고칠 때 |
| `explain-doc` | 빌드 끝에 설명 재료(EXPLAIN.md)를 정리할 때 |
| `how` | 코드 동작·구조를 설명받을 때 |
| `bro` | 직전 답을 쉬운 말로 다시 들을 때 |

## Codex 개발 묶음 (`packs/codex-dev/`)

| 파일 | 역할 |
|---|---|
| `AGENTS.md` | 프로젝트 지침(설치하면 과제 폴더에 들어감) |
| `docs/WORKFLOW.md` | 사람이 따라가는 기본 순서·검수 지점·상황별 할 일 |
| `templates/PROBLEM_PROMPT.md` | 문제 정의 세션 지시 |
| `templates/BUILD_PROMPT.md` | 빌드 1·2단계 지시 |
| `templates/VERIFY_PROMPT.md` | 검증 세션 지시 |
| `templates/REQUIREMENTS.md` | 요구사항 표 틀 |
| `templates/DECISIONS.md` | 판단대기·판단기록 틀 |
| `templates/ASSUMPTIONS.md` | 직접 정한 가정 기록 틀 |

1. 위 설치 명령에 `--project <과제 폴더>`를 붙여 설치한다.
2. `docs/WORKFLOW.md`의 기본 순서를 따른다.

## 폴더

```
skills/<name>/SKILL.md        스킬 본문
skills/<name>/references/     보조 파일(스크립트·프롬프트)
packs/codex-dev/              Codex 개발 묶음
install/                      설치 스크립트
NOTICE.md                     참고·이식 출처와 라이선스
```

## 출처

| 대상 | 출처 |
|---|---|
| 1~3묶음 | 직접 작성 |
| `judgment` | FOD-team-org/fod-harness `fodh-judgment`를 고쳐 씀 |
| `how`·`bro`·`bug-fix` | pstack(MIT, Lauren Tan)에서 이식 |
| 보안·테스트·UI 스킬 | 공개 자료를 참고해 새로 씀, 원문 미포함 |
| 상세 | `NOTICE.md` |

## 라이선스

| 대상 | 라이선스 |
|---|---|
| 저장소 전체 | MIT (`LICENSE`) |
| 이식·참고 자료 | 각 원본 라이선스 (`NOTICE.md`) |

## 다음 단계

- [ ] macOS·MacBook 작업 방식 취합
- [ ] 겹치는 스킬 합치기
- [ ] FOD-team-org/fod-harness와 합쳐 하네스(설치·설정 일체)로 확장
