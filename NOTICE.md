# NOTICE

## ui-baseline 참고 출처

`skills/ui-baseline/SKILL.md`는 아래 공개 규칙을 참고해 한국어로 새로 쓴 것입니다. 원문 문장은 옮기지 않았습니다.

- vercel-labs/web-interface-guidelines (MIT) — https://github.com/vercel-labs/web-interface-guidelines
- ibelick/ui-skills `baseline-ui`, `fixing-accessibility` (MIT) — https://github.com/ibelick/ui-skills
- Community-Access/accessibility-agents `tables-data-specialist` (MIT) — https://github.com/Community-Access/accessibility-agents

## 보안·테스트 스킬 참고 출처

`skills/security-check`, `data-exposure-guard`, `llm-feature-guard`, `http-roundtrip-test`, `data-edge-tests`, `mutation-check`는 아래 공개 자료의 점검 항목과 개념을 참고해 한국어로 새로 쓴 것입니다. 원문 문장, 코드, 목록은 옮기지 않았습니다. JavaScript 동작과 테스트 틀은 Node.js 24.18에서 직접 실행해 확인했습니다.

- openai/skills `security-best-practices` (Apache-2.0) — https://github.com/openai/skills
- anthropics/claude-plugins-official `security-guidance` (Apache-2.0) — https://github.com/anthropics/claude-plugins-official
- anthropics/skills `webapp-testing` (Apache-2.0) — https://github.com/anthropics/skills
- getsentry/skills `find-bugs` (Apache-2.0), `security-review` (CC BY-SA 4.0) — https://github.com/getsentry/skills
- trailofbits/skills `sharp-edges`, `property-based-testing`, `mutation-testing` (CC BY-SA 4.0) — https://github.com/trailofbits/skills
- OWASP Cheat Sheet Series(Node.js Security), CSV Injection, ASVS 5.0, Top 10 for LLM Applications 2025 (CC BY-SA 4.0) — https://owasp.org
- obra/superpowers (MIT) — https://github.com/obra/superpowers
- tartinerlabs/skills `testing` (MIT) — https://github.com/tartinerlabs/skills

## pstack

이 저장소의 일부 스킬은 pstack에서 가져와 고쳐 쓴 것입니다.

- 원본: https://github.com/cursor/plugins/tree/main/pstack (커밋 c742dd6)
- 미러: https://github.com/backnotprop/pstack (커밋 37d989c)
- 라이선스: MIT, Copyright (c) 2026 Lauren Tan (전문은 아래)

## 이식한 파일

| 새 경로 | 원본 경로 | 수정 |
|---|---|---|
| `skills/bro/SKILL.md` | `pstack/skills/bro/SKILL.md` | 없음 |
| `skills/how/SKILL.md` | 미러 `skills/how/SKILL.md` | 있음 |
| `skills/how/references/explorer-prompt.md` | 미러 `skills/how/references/explorer-prompt.md` | 있음 |
| `skills/how/references/explainer-prompt.md` | 미러 `skills/how/references/explainer-prompt.md` | 있음 |
| `skills/bug-fix/SKILL.md` | `pstack/skills/poteto-mode/playbooks/bug-fix.md`, `pstack/skills/tdd/SKILL.md`, `pstack/skills/principle-{fix-root-causes,attack-the-premise}/SKILL.md` | 한국어로 줄여 다시 씀 |

각 파일 맨 아래 줄에 원본 경로와 바꾼 내용을 적었습니다.

## pstack LICENSE

```
MIT License

Copyright (c) 2026 Lauren Tan

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
