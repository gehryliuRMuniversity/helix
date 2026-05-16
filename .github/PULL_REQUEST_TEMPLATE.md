<!--
Helix PRs are reviewed against the 5-section bar in CONTRIBUTING.md.
Fill every section. PRs missing a section get a single comment and stay open.
-->

## Type

<!-- Pick one. Delete the others. -->
- [ ] Bug fix
- [ ] New iron law
- [ ] New failure case
- [ ] Docs / typo / clarification
- [ ] Refactor (no behavior change)

## Failure case this addresses

<!-- Real incident or reproducible scenario. Anonymize freely, keep the chain of events concrete. -->
<!-- Required for: new iron law, new failure case, bug fix. Optional for docs. -->



## Root cause classification

<!-- Pick one and defend in one sentence. -->
- [ ] Process — workflow itself was wrong
- [ ] Cognition — agent misread the situation despite correct process
- [ ] Tool — tool returned bad data, was missing, or misused
- [ ] Communication — user intent and agent interpretation diverged
- [ ] Reusable-workflow — spans ≥3 tool calls + ≥2 information sources

**Defense:**

## What changed

<!-- Concrete diff highlights. Bullet list, not prose. -->



## Test plan

<!-- How will the reviewer verify this works? -->
<!-- Negative test (reproduce original failure, show it's prevented) or positive test (transcript where rule fires without false positives). -->



---

## Self-check before requesting review

- [ ] Failure case is reproducible or sourced from a real incident
- [ ] Rule justifies its layer placement (CLAUDE.md / hook / agent) per Iron Law 8
- [ ] **Net-add-or-subtract declared**: this PR adds `X` lines/rules / removes `Y` lines/rules (Iron Law 14 — no only-grow)
- [ ] No PII in diff or commit messages (real names, employers, internal codenames)
- [ ] `scripts/redact.py` passes locally
- [ ] `EVOLUTION.md` updated (for any rule change)
- [ ] `CHANGELOG` entry added with the failure-case one-liner
