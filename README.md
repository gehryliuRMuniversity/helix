# Helix

> A self-evolving harness for Claude Code — turns a forgiving default agent into a disciplined collaborator that catches its own drift.

```
💀 Skills silently fail to activate, you find out 3 hours later
💀 You spawn 19 agents in parallel, none of them review each other, all of them hallucinate consensus
💀 The agent claims "done" after 8 tool calls. It is not done. It never was.
💀 50-turn conversation. Context rotted at turn 22. Nobody noticed until the user pasted the whole transcript back.
```

> If any of the four hit you in the chest — keep reading. Helix is the harness you wish shipped by default.

---

## Why Helix

Claude Code out of the box is **too forgiving**. It will:

- Run a skill you *meant* to trigger but didn't name — or skip one you obviously meant.
- Spawn parallel sub-agents that grade their own homework.
- Declare a task complete the moment the last tool call returns 200.
- Forget the constraint you set at turn 4 by turn 40, and not tell you.

These aren't bugs. They are **defaults optimized for the median user**. If you are building production agent workflows, the median user is not you.

Helix is an **opinionated harness** layered on top of Claude Code. It is not a framework, not an SDK, not a wrapper. It is a folder of conventions — 19 iron laws, 4 hook layers, a mandatory review-agent pattern, and a weekly self-evolution loop — that makes the agent behave like a senior engineer with code review turned on, not an enthusiastic intern with commit access.

It is not magic. It is `CLAUDE.md` + a few hooks + a `launchd` cron + a discipline of *writing down every failure mode the first time it bites you*.

---

## The 7 Genes

Each gene targets one well-documented Claude Code failure mode. Each ships with a story of when it bit us.

| # | Gene | Failure It Prevents |
|---|------|---------------------|
| 1 | **19 Iron Laws + 1 Meta-Law** — every law has a named failure case attached | Best-practice docs without a war story don't stick. Laws-with-scars do. |
| 2 | **4-Layer Hook Defense** (`CLAUDE.md` / `memory/` / `SessionStart` / `UserPromptSubmit`) | A single layer of "please remember to..." in `CLAUDE.md` is defeated by any sufficiently long conversation. Defense in depth, or no defense. |
| 3 | **Mandatory Review-Agent Pattern** — reviewer ≠ executor, always | Sub-agents grading their own output is the #1 source of confidently-wrong multi-agent reports. Reviewer must be a separate spawn with no stake. |
| 4 | **Post-Task 5D Reflection** + Monthly Auto-Evolution ⭐ | Errors → root cause (Process / Cognition / Tool / Communication / Reusable-workflow). Slogans get banned. Concrete mechanism changes get shipped. |
| 5 | **Long-Task Progress File Tracking** (inspired by Anthropic Harness) | Any task ≥10 tool calls or high-stakes writes a 6-section progress file. Next session resumes in 30 seconds. No more "paste the whole transcript back". |
| 6 | **Self-Creating Agent System** — `launchd` weekly scan ⭐ | High-frequency patterns auto-promote to sub-agents. Stale agents (≥90 days unused) auto-sink to candidates. The roster evolves without you babysitting it. |
| 7 | **Half-Sentence → Skill Semantic Routing Hook** | Skill activation should fire on *meaning*, not exact keyword match. `UserPromptSubmit` hook does fuzzy mapping. Over-trigger > miss-trigger. |

These seven genes compose. Remove any one and the system regresses to "Claude Code with extra files".

---

## Quick Start

Five minutes from `git clone` to first disciplined run.

```bash
# 1. Clone into your Claude Code config root
git clone https://github.com/gehryliuRMuniversity/helix.git ~/.claude-helix

# 2. Install hooks, agents, and the weekly evolution cron
cd ~/.claude-helix && ./install.sh

# 3. Start a Claude Code session — Helix auto-loads via SessionStart hook
claude
```

The installer is idempotent. It backs up your existing `~/.claude/CLAUDE.md` to `~/.claude/CLAUDE.md.bak.<timestamp>` before writing. Uninstall is `./install.sh --uninstall`.

---

## What's Inside

Five files do 90% of the work. The rest is convention.

| File | Purpose |
|------|---------|
| `README.md` | What you're reading. The pitch and the map. |
| `CLAUDE.md` | The 19 iron laws + 1 meta-law. Loaded on every session. |
| `agents/review-agent-template.md` | Drop-in reviewer spawn. Reads the executor's output, writes a P0/P1/P2 defect list, refuses to grade itself. |
| `scripts/weekly-scan.sh` | `launchd`-triggered Monday 09:00 scan. Promotes hot patterns to agents, sinks cold ones, pushes a summary if changes ≥1. |
| `EVOLUTION.md` | Append-only log of every rule that was added, modified, or sunset. Includes the failure that motivated each change. |

That's it. No `node_modules`. No build step. No telemetry. The harness is the convention, and the convention is text files.

---

## Inspirations

Helix stands on three shoulders, none of which it claims to replace:

- **Anthropic Harness Engineering** — for the `claude-progress.txt` pattern that inspired Gene 5, and the broader insight that context management is the bottleneck.
- **Nous Hermes Agent** — for the learning-loop framing behind Gene 4's reusable-workflow extraction.
- **obra/superpowers** — for proving that a `CLAUDE.md` plus a few skills can fundamentally change agent behavior, and for the tone we aim for: *"makes your coding agent behave like a disciplined software engineer, not an impatient intern."*

If you have not read those, read those first. Helix is what you build *after* you have internalized them and started losing sleep over the gaps.

---

## Roadmap

Three honest milestones. No vaporware.

- **v0.1 — Shipped.** The 7 genes, install script, weekly scan, review-agent template. Single-maintainer, English + Chinese docs.
- **v0.2 — Community contributions.** PR template for new iron laws (must include a failure case, no exceptions). Curated `genes/community/` folder. Monthly maintainer review.
- **v1.0 — Automated onboarding.** Interactive `helix init` that interviews your workflow, suggests which of the 19 laws to keep / sink / extend for your domain. Generates a custom `CLAUDE.md` instead of a one-size-fits-all copy.

No v2.0 plans. If Helix ever needs a v2, it has lost the plot.

---

## Star History

<!-- Will activate after repo creation:
[![Star History Chart](https://api.star-history.com/svg?repos=gehryliuRMuniversity/helix&type=Date)](https://star-history.com/#gehryliuRMuniversity/helix&Date)
-->

**Suggested GitHub topics:** `claude-code` · `ai-agents` · `agent-harness` · `prompt-engineering` · `llm-tools` · `self-evolving-systems` · `multi-agent-systems` · `context-engineering`

---

## License

MIT. Take it, fork it, harden it for your own war stories. The only ask: if you find a new failure mode, open an issue with the story. That is how the harness evolves.

---

## Maintainer

Built and battle-tested by [@gehryliuRMuniversity](https://github.com/gehryliuRMuniversity).
Reach out: `a5339666@163.com`.

Issues, PRs, and "this gene saved my Friday" stories all welcome. The first failure case you contribute earns a permanent line in `EVOLUTION.md`.

> The agent that catches its own drift is the only one worth shipping.
