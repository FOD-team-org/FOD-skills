# FOD-skills

여러 프로젝트(영상·SNS·블로그·앱 개발·AI 코딩)에서 쓴 작업 방식을 누구나 깔아 쓸 수 있게 일반화한 스킬 모음이다. Claude Code와 Codex가 같은 파일을 쓴다.

## 우선순위
| 순서 | 무엇 |
|---|---|
| 1 | 작업 환경의 시스템 프롬프트·설정 |
| 2 | 사람의 지시 |
| 3 | 프로젝트에 이미 있는 지침(AGENTS.md, CLAUDE.md 등) |
| 4 | 이 저장소의 스킬 |

- 스킬은 기존 지침·설정을 고치거나 지우지 않는다.
- 부딪쳐서 위를 따랐으면 마지막 보고에 무엇이 부딪쳤고 결과가 어떻게 달라졌는지 적는다.
- 공통 원칙은 `operating-principles` 한 곳에만 있다.

## 설치
| 환경 | 명령 |
|---|---|
| macOS·Linux·Git Bash | `./install.sh` |
| Windows PowerShell | `powershell -NoProfile -ExecutionPolicy Bypass -File install.ps1` |

| 옵션 (sh / ps1) | 뜻 |
|---|---|
| `--target claude\|codex\|both` / `-Target` | 설치 위치. 기본 both. Claude Code는 `~/.claude/skills`, Codex는 `$CODEX_HOME/skills`(없으면 `~/.codex/skills`) |
| `--only a,b` / `-Only a,b` | 고른 스킬만 설치 |
| `--dry-run` / `-DryRun` | 바꾸지 않고 할 일만 출력 |
| `--project DIR` / `-Project DIR` | 개발 플레이북을 프로젝트 폴더에 설치(아래) |

- 같은 이름의 스킬 폴더가 이미 있으면 건너뛴다. 이 스크립트가 설치한 폴더(`.fod-skills` 표지 파일)만 새 버전으로 바꾼다.
- 네트워크 호출과 설정 파일 수정은 하지 않는다.

## 스킬 색인

### 공통
| 스킬 | 언제 |
|---|---|
| operating-principles | 모든 작업의 전제. 우선순위, 판단과 실행 분담, 승인 필요 행동, 비밀값 |
| evidence-status-report | 진행·상태·원인 질문에 답할 때, 마지막 보고 |
| project-docs | 문서 체계 만들기, 판단대기·runbook, 문서와 실제가 어긋날 때 |
| user-task-guide | 사람이 직접 할 일(로그인, 결제, 콘솔 설정) 안내 |

### 위임과 검수
| 스킬 | 언제 |
|---|---|
| delegation-loop | 하위 에이전트에 일 맡기기, 긴 배치 감독, 반납 직후 확인 |
| codex-delegation | Codex CLI에 구현·검수·생성 맡기기 |
| multi-ai-review | 여러 모델 토의, 검수 결과 채택 필터 |

### 조사와 기획
| 스킬 | 언제 |
|---|---|
| paced-research | 웹·영상 자료를 차단 없이 모으기 |
| reference-benchmark | 잘되는 레퍼런스 구조 분석 |
| idea-screening | 새 주제·포맷 아이디어 거르기 |
| hypothesis-experiment | 판정 기준을 먼저 정하는 실험, 프롬프트·스킬 개선 |
| performance-insights | 게시 후 지표 수집과 원인 분석 |

### 콘텐츠 제작
| 스킬 | 언제 |
|---|---|
| fact-check-gate | 게시 전 사실 항목 1차 출처 확인, 데이터 화면 |
| korean-voice-review | 한국어 글·대본의 AI 티와 말 흐름 검수 |
| frozen-content-rewrite | 사실·순서를 고정하고 표현만 바꾸는 재작성 |
| visual-output-qa | 영상·이미지·화면 결과물 검수, 크롭 좌표 실측 |
| audio-tts-qa | 라우드니스 측정, 음성 합성 캐시·폴백·목소리 비교 |
| short-video-pipeline | 짧은 영상 한 편의 단계·게이트·프레임 싱크 |
| asset-rights-check | 외부 자산 권리 확인, 신고 대응 |
| blog-post-pipeline | 정보 글 한 편의 초안부터 공개 후 확인까지 |

### 운영
| 스킬 | 언제 |
|---|---|
| safe-publish | 게시 도구 기준, 중복 방지, 실패 뒤 규칙 |
| routine-ops | 예약 작업 등록·백업·멈춤 감지·숨김 실행 |
| safe-cleanup | 디스크·산출물·프로세스 정리, 폴더 이동 |
| windows-env-pitfalls | Windows의 한글 인코딩·셸·AppData 가상화 함정 |
| cross-device-handoff | 다른 PC로 인계, 폰으로 산출물 전달 |
| external-tool-vetting | 외부 도구·플러그인·스킬 도입 전 점검 |
| service-access-hardening | 지인·팀용 비공개 서비스의 접근 보호와 비용 보호 |
| privacy-compliance-check | 개인정보 흐름표, 처리방침·스토어 표시 대조 |
| android-device-smoke | 안드로이드 실기기 설치·흐름 확인 |

### 개발 플레이북 (웹 서비스 빌드)
| 스킬 | 언제 |
|---|---|
| problem-definition | 설계 전에 진짜 문제를 사람과 정할 때(PROBLEM.md) |
| default-stack | 스택이 정해지지 않았을 때 React·NestJS·PostgreSQL 기본 구조 |
| design-doc | 코드보다 먼저 DESIGN.md, 끝날 때 코드와 맞추기 |
| judgment | 요구사항에 답이 없는 판단 나누기(DECISIONS.md·ASSUMPTIONS.md) |
| design-direction | 화면 디자인 방향(색·글꼴·밀도 프리셋)이 정해지지 않았을 때 상황에 맞게 고르기 |
| ui-baseline | 테마와 무관한 화면 기본기 |
| http-roundtrip-test | 실제 HTTP 요청으로 도는 API 테스트 |
| data-edge-tests | CSV·JSON 읽기·집계에서 자주 틀리는 지점 |
| data-exposure-guard | 응답·내보내기·로그의 고객 데이터 노출 막기 |
| llm-feature-guard | LLM 호출 기능의 주입·유출·비용 폭주 막기 |
| security-check | 완성 뒤 외부 입력 지점 보안 점검 |
| counterexample-review | 요구사항 대조로 반례 찾기(코드 수정 없음) |
| mutation-check | 테스트가 실제로 결함을 잡는지 확인 |
| bug-fix | 재현부터 시작하는 최소 수정 |
| explain-doc | 사람이 읽을 EXPLAIN.md 정리 |
| how | 코드 동작·위치 질문에 답하기 |
| bro | 직전 답을 쉬운 말로 다시 말하기 |

## 개발 플레이북 쓰는 법
`playbooks/codex-dev/`는 위 개발 스킬을 묶는 프로젝트 지침과 템플릿이다.

| 파일 | 역할 |
|---|---|
| AGENTS.md | 작업 규칙(우선순위, 진행, 스킬 고르기, 환경과 비용) |
| docs/WORKFLOW.md | 단계별 흐름과 검수 지점 |
| templates/ | REQUIREMENTS·DECISIONS·ASSUMPTIONS와 단계별 프롬프트 |

```bash
./install.sh --project path/to/app                 # 플레이북만
./install.sh --project path/to/app --target codex  # 플레이북 + Codex 스킬
```
- 프로젝트에 AGENTS.md가 있으면 덮어쓰지 않고 끝에 한 번만 이어 붙인다(표지 주석으로 중복 방지).
- DECISIONS.md·ASSUMPTIONS.md는 없을 때만 복사한다.

## 로드맵
| 단계 | 내용 |
|---|---|
| 1 (지금) | Windows PC의 작업 방식을 스킬로 정리 |
| 2 | macOS 기기들의 작업 방식을 같은 규격으로 합치기 |
| 3 | 스킬 모음을 하나의 하네스로 묶기 |

## 기여 규칙
- 스킬 한 개는 `skills/<name>/SKILL.md` 한 파일. frontmatter는 `name`, `description` 두 줄.
- 한 내용은 한 스킬에만 둔다. 겹치면 이름으로 가리킨다.
- 특정 채널·제품·과제 전용 문장을 넣지 않는다.
- 커밋 전에 `python tools/check_public.py`로 노출 항목 0건을 확인한다.

## 출처
외부 자료를 참고한 스킬과 라이선스는 [NOTICE.md](NOTICE.md)에 있다.
