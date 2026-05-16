---
name: New failure case
about: Report a Claude Code / agent failure mode Helix should address
title: "[failure] <one-line summary>"
labels: failure-case, needs-triage
assignees: ''
---

<!--
Failure cases are how Helix evolves. The more concrete you can be, the more
likely this becomes a new iron law. Anonymize names freely, keep the mechanics intact.
-->

## Failure mode

<!-- One paragraph. What did the agent do that it shouldn't have, or fail to do that it should have? -->



## Reproducer

<!-- Command, prompt, or conversation fragment that triggers the failure. -->
<!-- If it's a long transcript, paste the 5-10 turns around the failure point. -->

```
<paste here>
```

## Frequency

- [ ] One-time (saw it once, can't reproduce reliably)
- [ ] Occasional (happens sometimes under conditions I can describe below)
- [ ] Reliable (reproduces every time with the steps above)

**Conditions (if occasional):**

## Current workaround

<!-- How are you working around this today? "I manually check every output" counts. -->



## Proposed root cause

<!-- Your best guess. Pick one and justify in one sentence — we'll debate in comments. -->
- [ ] Process — workflow itself is wrong
- [ ] Cognition — agent misreads the situation
- [ ] Tool — tool returns bad data or is missing
- [ ] Communication — intent and interpretation diverge silently
- [ ] Reusable-workflow — pattern deserves to be a skill

**Why:**

## Which gene of Helix should address this?

<!-- See README.md for the 7 genes. Pick one, or propose a new gene. -->
- [ ] Gene 1 — Iron Laws
- [ ] Gene 2 — 4-Layer Hook Defense
- [ ] Gene 3 — Review-Agent Pattern
- [ ] Gene 4 — Post-Task 5D Reflection
- [ ] Gene 5 — Long-Task Progress File
- [ ] Gene 6 — Self-Creating Agent System
- [ ] Gene 7 — Semantic Routing Hook
- [ ] New gene needed — propose below

**Reasoning:**

## Environment

- Helix version:
- Claude Code version:
- OS:
