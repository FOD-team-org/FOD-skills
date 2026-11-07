---
name: how
description: "Use for \"how does X work\", code walkthroughs before changing something, and placement / ownership / layering questions (\"where should this live\", \"which package owns this\", \"is this the right layer\"). Explains subsystem architecture, runtime flow, onboarding mental models."
---

# How

Explore the codebase to answer "how does X work?" questions. Produce architectural explanations at the level of a senior engineer onboarding onto a subsystem, enough to build a working mental model, not so much that it reads like annotated source code.

Run every role yourself, read-only, one after another. The templates in `references/` describe what each pass must produce.

## 1. Assess complexity

If the scope is ambiguous, state your interpretation and explore. The user can redirect.

- **Simple** (a single module, a small utility, a narrow question such as "how does function X work"): no exploration passes. Do one explainer pass that explores and explains, following `references/explainer-prompt.md` without the explorer-findings section. Go to step 4.
- **Complex** (a subsystem spanning multiple files or services, a cross-cutting feature, a full architectural overview): go to step 2.

When in doubt, take the simple path.

## 2. Explore (complex only)

Decompose the question into 2 to 4 angles, each a distinct slice of the subsystem. Explore the angles one after another, each with `references/explorer-prompt.md` and its angle filled in. Write down each angle's findings before starting the next.

## 3. Synthesize (complex only)

Once every angle is written down, do the explainer pass with `references/explainer-prompt.md` and all the findings filled in.

## 4. Present

Present the explainer's output. Light edits for clarity or context from the conversation are fine. Do not substantially rewrite it.

## Output format

The explanation uses the sections defined in `references/explainer-prompt.md`, dropping any that do not apply: Overview, Key Concepts, How It Works, Where Things Live, Gotchas.

Adapted from pstack skills/how/SKILL.md in the backnotprop/pstack mirror (MIT, (c) 2026 Lauren Tan): removed subagent spawning, model settings, harness notes and the why/poteto-mode references; you run every role yourself, sequentially
