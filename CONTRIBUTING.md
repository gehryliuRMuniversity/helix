# Contributing to Helix

Helix evolves by accreting **failure cases**, not by accreting opinions. Every contribution — bug report, new iron law, or doc fix — must carry a war story. If you cannot point at the scar, the rule will not stick.

This document tells you how to file each kind of contribution and what the review bar is.

---

## How to Contribute

Four channels. Pick the one that fits.

| Type | Where | What to include |
|------|-------|-----------------|
| **Bug report** | Issue with `bug` label | Reproducer (commands + expected vs. actual), Helix version, Claude Code version, OS |
| **New iron law** | PR against `CLAUDE.md` + `EVOLUTION.md` | Failure case, root cause, proposed rule, hook layer justification, test plan (see below) |
| **New failure case** | Issue using `new-failure-case` template | Scenario, reproducer, frequency, current workaround, which gene should address it |
| **Docs / typo / clarification** | PR against the affected file | Before/after snippet. No test plan required for pure wording fixes. |

For anything ambiguous, open an issue first and ask. Drive-by PRs that propose new rules without a failure story will be closed with a pointer to this section.

---

## Iron Law PR Requirements

This is the bar that matters. Every new iron law PR must include all five sections in the PR body — in this order, no exceptions.

### 1. The failure case
A real incident or a reproducible scenario. "It feels like the agent does X" is not a failure case. "On 2026-03-12 the agent did X when I asked Y, transcript attached" is. Anonymize freely, but the chain of events must be concrete enough that a reviewer can imagine the moment.

### 2. Root cause classification
Pick one of five buckets and defend it in one sentence:
- **Process** — the workflow itself was wrong; the agent followed it correctly.
- **Cognition** — the agent misread the situation despite a correct process.
- **Tool** — a tool returned bad data, was missing, or was misused.
- **Communication** — user intent and agent interpretation diverged silently.
- **Reusable-workflow** — the task spanned ≥3 tool calls and ≥2 information sources and deserves to be a skill candidate.

### 3. Proposed rule
The exact text you want added to `CLAUDE.md`. Keep it under 80 words. State what the agent must do, what it must not do, and the trigger condition.

### 4. Why text-only doesn't work + which hook layer it needs
Iron Law 8 (mechanism design beats willpower) means most rules need a hook, not just doc text. Tell the reviewer:
- Why a `CLAUDE.md` reminder alone would silently rot (be specific — what context window length, what task type defeats it?).
- Which of the 4 layers should enforce it: L1 doc, L2 memory, L3 `SessionStart` hook, L4 `UserPromptSubmit` hook.
- If you propose L1 only, you must justify why the failure mode is rare enough that text suffices.

### 5. Test plan
How will the reviewer verify the rule works? Two acceptable patterns:
- **Negative test:** reproduce the original failure case and show the new rule prevents it.
- **Positive test:** describe a session transcript where the rule fires correctly without false positives.

PRs missing any of the five sections get a single comment pointing back here and stay open until fixed.

---

## Code Style

Helix is mostly markdown and shell. Keep it boring.

- **Markdown:** ATX headings (`#`), no trailing whitespace, fence code blocks with a language tag, tables for any ≥2-option comparison (Iron Law 3 applies to docs too).
- **Shell:** `#!/usr/bin/env bash`, `set -euo pipefail` at the top of every script, two-space indent, prefer long flags (`--quiet` over `-q`).
- **Filenames:** kebab-case for new files, match the existing pattern of the directory you're touching.

Run `scripts/redact.py` before every commit. It catches PII patterns we've collected from past slips.

---

## Commit Message Convention

One line, imperative mood, ≤72 characters. Optional body separated by a blank line.

```
add iron law 13: long-context drift detection

Triggered by the 5/15 career-planning incident where the agent
forgot the user's salary constraint by turn 30. Hook layer L4.
```

Prefixes we use: `add`, `fix`, `update`, `remove`, `refactor`, `docs`. No emoji in commit subjects.

---

## Review Process

Helix reviews its own PRs using the same pattern it preaches.

1. **Author opens PR** — fills the 5-section template above.
2. **Maintainer dispatches a review-agent** following `agents/review-agent-template.md`. The reviewer is a separate Claude Code spawn with no context from the authoring session. It cannot be the same agent that drafted the rule.
3. **Reviewer outputs a P0/P1/P2 defect list** against the 5 sections. P0 blocks merge.
4. **Author addresses P0s, optionally P1s.** P2s become follow-up issues.
5. **A second human maintainer** (or, for small PRs, a synthesizer agent) confirms the failure case is reproducible and the hook layer choice is defended.
6. **Merge.** Author adds an `EVOLUTION.md` entry in the same PR — no separate follow-up.

We eat our own dog food. If the review-agent pattern fails on a Helix PR, that itself becomes a failure case and a new iron law candidate.

---

## Questions

Open a Discussion, not an issue, for anything that isn't a bug or a concrete proposal. Reach the maintainer at `a5339666@163.com` for sensitive reports (security, PII slip in a merged PR).

The first failure case you contribute earns a permanent line in `EVOLUTION.md`. That is the only credit system we keep.
