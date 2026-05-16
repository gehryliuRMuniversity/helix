# EVOLUTION.md — How Helix Grew From 30 Corrections to a Self-Evolving Harness

> A real-time timeline of how an opinionated AI agent harness emerged from 2 days of intensive user correction loops.

## Why this matters

Most AI harnesses ship as static documents — a polished `CLAUDE.md`, a clean rules file, a tidy README. You read them and assume someone sat down, thought hard, and produced wisdom.

Helix is the opposite. Every rule in it has a scar. Every law was triggered by a specific failure, named on the spot, and welded into the harness before the next task started. This file is the public timeline of that process — not a retrospective polish, but the raw sequence of corrections, reflections, and mechanism patches that produced a self-evolving agent in 48 hours.

You're not reading a manifesto. You're reading the autopsy of 30 mistakes, in order. The point is to show that good agent rules are not designed — they're **excavated** from real friction.

## Day 1: The Wake-Up Call

The first day was about realizing that "smart model" and "useful collaborator" are two different problems.

- **09:00 — First incident.** Agent dispatched into a long, multi-file refactor. After touching ~40 files it confidently reported "done." Spot-check: three files still had the old API. The agent had pattern-matched "looks done" without verification.
- **10:30 — User pushback.** "Why didn't you grep for the old symbol before claiming done?" No good answer. Root cause logged: **Type B (cognitive bias)** — optimism over evidence.
- **12:00 — First reflection.** Drafted Rule: *Verification before completion.* Required: run the check command, paste the output, then claim success. No claims without artifacts.
- **14:00 — First mechanism patch.** Realized a rule in `CLAUDE.md` won't fire if the agent forgets to re-read it. Added a `SessionStart` hook that injects a skill-discovery checklist into every new session. Text reminders are passive; hooks are active.
- **15:30 — Second incident.** Two parallel sub-agents stomped on each other's edits. No coordination, no merge logic. Both reported success. The final file was a Frankenstein.
- **17:00 — Premature completion pattern.** Noticed: the agent kept reporting "done" the moment the *last tool call* succeeded, not when the *outcome* was verified. Independent failure mode from #1, but same family.
- **19:00 — Silent background task.** Kicked off a long-running job. Agent moved on. Job died 15 minutes later. Nobody noticed for an hour.
- **22:00 — Day 1 reflection.** 9 candidate rules drafted. 4 hook patches deployed. First version of the "Iron Laws" list compiled. The shape of the problem was clear: **the agent's failure modes weren't random — they clustered into a small number of recurring patterns.**

## Day 2: The Meta-Awakening

Day 2 stopped being about individual bugs and started being about the *generator* of those bugs.

- **09:00 — The meta-question.** User: "You keep failing the same way. What's the root mechanism?" That question reframed everything. Individual rules were treating symptoms.
- **11:00 — First meta-insight: rules without enforcement get ignored.** A rule sitting in a markdown file is a wish. Introduced the **4-Layer Hook Defense**: L1 text reminder → L2 memory mapping → L3 SessionStart hook → L4 UserPromptSubmit hook. If a rule matters, it gets enforced at the harness level, not the doc level.
- **13:00 — Second meta-insight: rules grow forever unless culled.** The rules file was already 21 items and bloating. Introduced the **net-add-or-subtract law**: every new rule must justify whether it replaces, merges, or supersedes an existing one. 30-day untouched → demotion. 90-day untouched → deletion candidate. Subtracting a rule counts as progress.
- **15:00 — Third meta-insight: agents can't review themselves.** When the same agent that wrote the code also reviewed it, it rationalized its own choices 100% of the time. Introduced the **Mandatory Review-Agent Pattern**: any dispatched parallel work requires ≥1 independent reviewer agent. Reviewer cannot be one of the executors.
- **17:00 — Fourth meta-insight: templates kill thinking.** Caught the agent applying the *same* 8-point checklist to wildly different tasks. It was substituting structure for thought. Drafted the **Meta-Law**: research → think holistically → execute. The *shape* of the three phases is fixed; the *content* must be regenerated for each task. No pre-baked scenario lists.
- **18:30 — Fifth insight: long tasks need a progress file.** Sessions died, context rotted, hand-offs lost state. Adopted a `progress.md` convention per long task — goal / done / in-flight / todo / blockers / key decisions. Any future session can resume in 30 seconds.
- **20:00 — Day 2 reflection.** 1 meta-law + 10 refined laws committed. The 4-layer hook system operational. The harness now had a vocabulary for talking about its own failures, not just patches for them.

## The 19 Iron Laws (Concise List)

A one-line per law. Full text and rationale live in `CLAUDE.md`.

1. **Identify the scenario before acting**
2. **Cautious externally, bold internally**
3. **Multiple options demand a comparison table**
4. **Use natural-language choices**
5. **Self-check on task completion**
5b. **Post-task self-reflection** (4-axis errors/root cause/next-time/reusable workflow)
6. **Bump versions on every edit** (4-place sync)
7. **Important artifacts double-stored**
7c. **Long tasks track via `progress.md`**
8. **Mechanism design beats willpower** (4-layer hook defense)
9. **High-stakes domains: be the expert, not the pleaser**
10. **Monetizable projects: revenue gates every action**
11. **Auto-apply reflections; don't await approval**
11b. **72h rollback window**
12. **Decide after research; stop pushing back to user**
13. **Parallel agents + mandatory independent reviewer** (review ≠ executor)
13b. **In-project core principles outrank in-project plans**
14. **Rules file is net-add-or-subtract**
15. **PM decision 6-field is a mental frame, not a doc section**
16. **Agents auto-evolve weekly without reporting**
17. **Background jobs alert on failure within 24h**
18. **Async tasks require periodic check-in**
19. **Think before asking the user**

## The 4 Architectural Genes That Emerged

1. **Meta-Law (research → think holistically → execute)** — fixed structure, regenerated content.
2. **4-Layer Hook Defense** — text reminders fail; mechanism enforcement compounds.
3. **Mandatory Review-Agent Pattern** — self-review has structural blind spots.
4. **Reusable Workflow Extraction** — Day-N learnings → permanent skills.

## Key Inflection Points

> **"Stop using templates instead of thinking."** — the moment the meta-law was born.

> **"Mechanism design beats willpower."** — why text reminders were demoted from primary defense to fallback.

> **"The review agent cannot be the executor."** — the structural reason solo agents lie to themselves.

## What's Next

Day 3+ is already in motion: error-mode taxonomy expansion, cross-session memory consolidation, and a planned experiment in letting the harness propose its own rule deletions.

If you're running an agent harness and have failure modes worth contributing — open an issue. The most useful PRs to this project are not new features. They're new *corrections*.

---

> Author: [@gehryliuRMuniversity](https://github.com/gehryliuRMuniversity) · Contact: a5339666@163.com
