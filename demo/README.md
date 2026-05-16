# Helix Demo Assets

> Demo gifs / asciinema casts to embed in the main README.
> Currently maintained as **scripts** — record them with `asciinema rec` on a clean machine.

## Why scripts not gifs

Demo scripts are reproducible. A gif gets stale the moment any behavior changes. Run the script, re-record. The script is the source of truth.

## How to record

```bash
# 1. Install asciinema (one-time)
brew install asciinema  # macOS
# or: pip install asciinema

# 2. Record a scene (each script is 30-90 seconds)
asciinema rec demo/scene-1-skill-trigger.cast --command='bash demo/scene-1-skill-trigger.sh'

# 3. Upload to asciinema.org (optional, gives embed URL)
asciinema upload demo/scene-1-skill-trigger.cast

# 4. Or convert to gif locally with agg
brew install agg
agg demo/scene-1-skill-trigger.cast demo/scene-1-skill-trigger.gif
```

## Three scenes to record

### Scene 1: SessionStart hook fires skill mapping
**Script:** `scene-1-skill-trigger.sh`
**What it shows:** User types a vague half-sentence → SessionStart hook injects skill→business-scenario map → Claude immediately picks the right skill instead of asking clarifying questions.
**Duration:** ~45s

### Scene 2: Mandatory review-agent catches premature completion
**Script:** `scene-2-review-agent.sh`
**What it shows:** Main thread dispatches 4 executor agents → 1 of them returns `status: complete` after only 2 of 5 steps → independent reviewer-correctness agent flags the gap → synthesizer applies the fix.
**Duration:** ~60s

### Scene 3: weekly-scan auto-creates a new agent stub
**Script:** `scene-3-weekly-scan.sh`
**What it shows:** A new project directory exists with `.claude/` but no `agents/` subdir → `weekly-scan.sh --apply` runs → auto-creates `project-orchestrator.md` stub.
**Duration:** ~30s

## Placeholders in main README

Until demos are recorded, the README references these will be empty. Once recorded, replace placeholder markdown with:

```markdown
[![asciicast](https://asciinema.org/a/XXXXXX.svg)](https://asciinema.org/a/XXXXXX)
```
