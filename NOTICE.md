# NOTICE

## ui-baseline·design-direction 참고 출처

`skills/ui-baseline/SKILL.md`와 `skills/design-direction/`(SKILL.md, references)는 아래 공개 규칙과 문서를 참고해 한국어로 새로 쓴 것입니다. 원문 문장은 옮기지 않았습니다. 디자인 시스템에서는 공개된 수치(글자 크기, 간격, 행 높이, 일부 색 값)만 빌렸고, 프리셋 색 대비는 WCAG 2.x 공식으로 직접 계산했습니다.

- vercel-labs/web-interface-guidelines (MIT) — https://github.com/vercel-labs/web-interface-guidelines
- ibelick/ui-skills `baseline-ui`, `fixing-accessibility` (MIT) — https://github.com/ibelick/ui-skills
- Community-Access/accessibility-agents `tables-data-specialist` (MIT) — https://github.com/Community-Access/accessibility-agents
- anthropics/skills `frontend-design` (Apache-2.0) — https://github.com/anthropics/skills
- pbakaus/impeccable (Apache-2.0) — https://github.com/pbakaus/impeccable
- Dammyjay93/interface-design (MIT) — https://github.com/Dammyjay93/interface-design
- 0xdesign/design-plugin (MIT) — https://github.com/0xdesign/design-plugin
- nextlevelbuilder/ui-ux-pro-max-skill (MIT) — https://github.com/nextlevelbuilder/ui-ux-pro-max-skill
- IBM Carbon Design System (코드 Apache-2.0) — https://carbondesignsystem.com
- GitHub Primer primitives (MIT) — https://primer.style
- Microsoft Fluent 2 (fluentui 코드 MIT) — https://fluent2.microsoft.design
- Radix Colors (MIT) — https://www.radix-ui.com/colors
- shadcn/ui 테마 변수 (MIT) — https://ui.shadcn.com/docs/theming
- W3C WCAG 2.2 — https://www.w3.org/TR/WCAG22/
- 디지털정부 디자인 시스템 KRDS (참고, 원문 미사용. 라이선스 미확인으로 공개 수치와 색 토큰 값만 사용) — https://www.krds.go.kr
- Material Design 3 (참고, 원문 미사용) — https://m3.material.io
- Apple Human Interface Guidelines (참고, 원문 미사용) — https://developer.apple.com/design/human-interface-guidelines
- Figma 리소스 라이브러리 "색상 조합" 글 (참고, 원문 미사용. 색 속성·조합 유형·분위기 연결의 개념만 참고했고 팔레트 이름과 색 값은 가져오지 않음) — https://www.figma.com/ko-kr/resource-library/color-combinations/
- 레퍼런스 갤러리(Mobbin, Refero, Recent, Land-book, Lapa Ninja, SaaS Landing Page, Awwwards, Siteinspire, Dribbble)는 이름과 용도만 적었고 화면·문구를 가져오지 않았습니다.
- 프리셋에 적은 글꼴(Pretendard, SUIT, Noto Sans KR, Noto Serif KR, Gowun Batang, IBM Plex Sans KR, Do Hyeon, Space Grotesk, Source Serif 4, JetBrains Mono, Atkinson Hyperlegible Next)은 SIL OFL입니다. 글꼴 파일은 이 저장소에 들어 있지 않습니다. Pretendard GOV는 라이선스를 따로 확인하지 못했습니다.

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
