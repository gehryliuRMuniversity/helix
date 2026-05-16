# The Review Agent Pattern

> A coordination primitive for Claude Code multi-agent workflows.
> Authored by [@gehryliuRMuniversity](https://github.com/gehryliuRMuniversity) — part of the Helix project.

## Why: the 19-agent trap

Claude Code's `dispatch_in_parallel` is powerful, but in production we keep seeing the same three failure modes:

1. **Premature done.** A sub-agent hits a stubborn error on step 4 of 7, decides the remaining work is "out of scope," and reports `status: complete`. The main thread trusts it. Three days later a reviewer notices the gap.
2. **Self-review blindness.** When you ask the same agent to "double-check your work," it confirms its own assumptions. Hermes-style internal reflection misses the bugs a fresh pair of eyes would catch in 30 seconds.
3. **Silent rationalization.** Dispatched agents under token pressure narrate their cut corners as design decisions. The synthesizer reads polished prose and assumes the work is sound.

The common root cause: **the agent that produced the artifact is the wrong agent to judge it.**

## The Pattern: 4+2+1 / 6+1+1

Helix workflows pin every batch of executor agents to at least one *independent* Review Agent, then a separate Synthesizer applies the diff.

```
                       ┌────────────────────────┐
                       │   Main Thread (you)    │
                       └───────────┬────────────┘
                                   │ dispatch
              ┌────────────┬───────┴───────┬────────────┐
              ▼            ▼               ▼            ▼
        ┌─────────┐  ┌─────────┐    ┌─────────┐  ┌─────────┐
        │Executor1│  │Executor2│    │Executor3│  │Executor4│
        └────┬────┘  └────┬────┘    └────┬────┘  └────┬────┘
             └────────────┴───────┬──────┴────────────┘
                                  │  artifacts
                       ┌──────────┴──────────┐
                       ▼                     ▼
                ┌─────────────┐       ┌─────────────┐
                │  Reviewer A │       │  Reviewer B │   (independent
                │ (correctness)│      │ (red team)  │    — never an
                └──────┬──────┘       └──────┬──────┘    executor)
                       └──────────┬──────────┘
                                  ▼
                          ┌───────────────┐
                          │  Synthesizer  │  (applies fixes,
                          └───────────────┘   does NOT re-review)
```

The shape scales: 4 executors + 2 reviewers + 1 synthesizer for a typical PRD pass; 6+1+1 for heavier design reviews; N+1+1 minimum.

## Review Agent Anatomy

Drop this into `.claude/agents/reviewer-correctness.md`:

```markdown
---
name: reviewer-correctness
description: Independent correctness reviewer. Use after one or more executor agents produce an artifact (PRD, code diff, plan, analysis). Never use as an executor.
tools: Read, Grep, Glob, Bash
---

You are an independent reviewer. You did not produce the artifact under review,
and you have no stake in defending it.

Your job, in this order:
1. Read the artifact and the original task brief.
2. Find concrete defects — wrong numbers, broken cross-references, missing
   acceptance criteria, contradictions between sections, claims unsupported
   by evidence. Cite line numbers or section IDs.
3. Classify each defect P0 / P1 / P2 with a one-sentence justification.
4. For every P0 and P1, write a *specific repair instruction* the synthesizer
   can apply mechanically. Not "improve the metrics section" — instead
   "in §5.3.2 change the target metric from 55% to 70% to match the dictionary."
5. End with a single score X/10 and the top 3 risks if shipped as-is.

Hard rules:
- Do not rewrite the artifact yourself. Output review notes only.
- Do not soften findings to be polite. If §4 contradicts §7, say so plainly.
- If you cannot verify a claim, mark it "unverified" rather than approving it.
- Never invoke any executor agent. You read and judge; you do not produce.
```

## How to dispatch

```
# Step 1 — fan out executors in parallel
dispatch_in_parallel([
  Task(agent="prd-writer",        prompt="Draft sections 1-4 of the PRD..."),
  Task(agent="prd-writer",        prompt="Draft sections 5-8 of the PRD..."),
  Task(agent="compliance-checker",prompt="Map every requirement to a regulation..."),
])

# Step 2 — once all artifacts land, dispatch reviewers (independent agents)
dispatch_in_parallel([
  Task(agent="reviewer-correctness", prompt="Review the merged draft at <path>"),
  Task(agent="reviewer-redteam",     prompt="Attack the draft at <path> — find weakest claims"),
])

# Step 3 — synthesizer applies the review diff, then stops
Task(agent="synthesizer",
     prompt="Apply every P0 and P1 fix from the reviewer reports. Do not re-review.")
```

## Battle-tested

This pattern has carried 100K+ word PRD reviews across multiple revision rounds where single-agent passes consistently missed cross-section metric drift, dead anchors, and citation errors. The same shape works for code review batches, design critique, and research synthesis.

## Don't do this

- **Reviewer = Executor.** Asking the writer to grade its own paper. The model will not contradict itself in the same context window.
- **Skip the reviewer because "the executor seemed thorough."** Thoroughness is the most convincing form of being wrong.
- **Let the synthesizer re-review while applying fixes.** It will quietly drop findings it disagrees with. Synthesizer applies; it does not adjudicate.
