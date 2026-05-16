#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────
#  _   _      _ _        __        __        _    _
# | | | | ___| (_)_  __  \ \      / /__  ___| | _| |_   _
# | |_| |/ _ \ | \ \/ /   \ \ /\ / / _ \/ _ \ |/ / | | | |
# |  _  |  __/ | |>  <     \ V  V /  __/  __/   <| | |_| |
# |_| |_|\___|_|_/_/\_\     \_/\_/ \___|\___|_|\_\_|\__, |
#                                                   |___/
#              Agent Evolution Scan — v1.0
#       Authored by @gehryliuRMuniversity (Helix project)
# ─────────────────────────────────────────────────────────────────────
#
# What this does:
#   Walks ~/.claude/agents/ and any ./<project>/.claude/agents/ under CWD,
#   then detects four candidate types for autonomous lifecycle management:
#
#     SPAWN   project dir has no agent stub      → suggest project-orchestrator
#     DEMOTE  agent file unmodified > N days     → move to _archive/
#     DELETE  archived > M days, never invoked   → mark for deletion
#     MERGE   two agents with > 70% description  → suggest consolidation
#             token overlap
#
# Why this exists:
#   Static agent libraries (awesome-claude-code, cursor-rules, etc.) rot.
#   Helix treats the agent population as a living system — scanned weekly,
#   pruned automatically, with dry-run as the default so nothing surprises
#   you on Monday morning.
#
# Schedule:
#   macOS  — load via launchd (label: com.helix.weekly-scan)
#   Linux  — cron entry:  0 9 * * 1  /path/to/weekly-scan.sh
#
# Exit codes:
#   0  clean — no candidates found
#   1  candidates found (informational, not an error)
#   2  fatal — bad config, missing dirs, etc.
# ─────────────────────────────────────────────────────────────────────

set -u

# ─── Configuration (override via env) ───────────────────────────────
HELIX_AGENTS_DIR="${HELIX_AGENTS_DIR:-$HOME/.claude/agents}"
HELIX_SCAN_MODE="${HELIX_SCAN_MODE:-dry-run}"
HELIX_NOTIFY_WEBHOOK="${HELIX_NOTIFY_WEBHOOK:-}"
HELIX_DEMOTE_DAYS="${HELIX_DEMOTE_DAYS:-30}"
HELIX_DELETE_DAYS="${HELIX_DELETE_DAYS:-90}"
HELIX_MERGE_THRESHOLD="${HELIX_MERGE_THRESHOLD:-70}"
HELIX_PROJECT_ROOT="${HELIX_PROJECT_ROOT:-$PWD}"

print_banner() {
  echo "================================================================"
  echo " Helix Weekly Agent Evolution Scan"
  echo " mode=$HELIX_SCAN_MODE  demote>${HELIX_DEMOTE_DAYS}d  delete>${HELIX_DELETE_DAYS}d"
  echo " scan_root=$HELIX_AGENTS_DIR"
  echo " project_root=$HELIX_PROJECT_ROOT"
  echo "================================================================"
}

preflight() {
  if [ ! -d "$HELIX_AGENTS_DIR" ]; then
    echo "FATAL: agents dir not found: $HELIX_AGENTS_DIR" >&2
    exit 2
  fi
  case "$HELIX_SCAN_MODE" in
    dry-run|apply) ;;
    *) echo "FATAL: HELIX_SCAN_MODE must be 'dry-run' or 'apply'" >&2; exit 2 ;;
  esac
  mkdir -p "$HELIX_AGENTS_DIR/_archive" 2>/dev/null || true
}

FINDINGS_TMP="$(mktemp -t helix-findings.XXXXXX)"
trap 'rm -f "$FINDINGS_TMP"' EXIT

emit() { printf '%s\t%s\t%s\n' "$1" "$2" "$3" >> "$FINDINGS_TMP"; }

mtime_epoch() {
  local f="$1"
  stat -f %m "$f" 2>/dev/null || stat -c %Y "$f" 2>/dev/null || echo 0
}

days_since() {
  local f="$1"
  local now; now=$(date +%s)
  local m;   m=$(mtime_epoch "$f")
  [ "$m" -eq 0 ] && { echo 999999; return; }
  echo $(( (now - m) / 86400 ))
}

scan_demote() {
  for f in "$HELIX_AGENTS_DIR"/*.md; do
    [ -f "$f" ] || continue
    local age; age=$(days_since "$f")
    if [ "$age" -gt "$HELIX_DEMOTE_DAYS" ]; then
      emit "DEMOTE" "$f" "untouched ${age}d (>${HELIX_DEMOTE_DAYS}d threshold)"
    fi
  done
}

scan_delete() {
  local invlog="$HOME/.claude/logs/agent-invocations.log"
  for f in "$HELIX_AGENTS_DIR/_archive"/*.md; do
    [ -f "$f" ] || continue
    local age; age=$(days_since "$f")
    [ "$age" -le "$HELIX_DELETE_DAYS" ] && continue
    local name; name=$(basename "$f" .md)
    if [ -f "$invlog" ] && grep -q "$name" "$invlog" 2>/dev/null; then
      continue
    fi
    emit "DELETE" "$f" "archived ${age}d, no invocation trace"
  done
}

scan_spawn() {
  find "$HELIX_PROJECT_ROOT" -mindepth 1 -maxdepth 2 -type d -name ".claude" 2>/dev/null | while read -r dotclaude; do
    local proj_root; proj_root=$(dirname "$dotclaude")
    if [ ! -d "$dotclaude/agents" ]; then
      emit "SPAWN" "$proj_root" "project has .claude/ but no agents/ subdir"
    fi
  done
}

extract_description() {
  awk '/^description:/{sub(/^description:[[:space:]]*/,"");print;exit}' "$1" 2>/dev/null
}

token_overlap_pct() {
  local a="$1" b="$2"
  [ -z "$a" ] || [ -z "$b" ] && { echo 0; return; }
  local ta tb common total
  ta=$(echo "$a" | tr '[:upper:]' '[:lower:]' | tr -cs '[:alnum:]' '\n' | sort -u | grep -v '^$')
  tb=$(echo "$b" | tr '[:upper:]' '[:lower:]' | tr -cs '[:alnum:]' '\n' | sort -u | grep -v '^$')
  common=$(comm -12 <(echo "$ta") <(echo "$tb") | wc -l | tr -d ' ')
  total=$(echo "$ta"$'\n'"$tb" | sort -u | grep -cv '^$')
  [ "$total" -eq 0 ] && { echo 0; return; }
  echo $(( common * 100 / total ))
}

scan_merge() {
  local files=()
  for f in "$HELIX_AGENTS_DIR"/*.md; do
    [ -f "$f" ] && files+=("$f")
  done
  local n=${#files[@]}
  local i=0 j=0
  while [ "$i" -lt "$n" ]; do
    j=$(( i + 1 ))
    while [ "$j" -lt "$n" ]; do
      local da db pct
      da=$(extract_description "${files[$i]}")
      db=$(extract_description "${files[$j]}")
      pct=$(token_overlap_pct "$da" "$db")
      if [ "$pct" -ge "$HELIX_MERGE_THRESHOLD" ]; then
        emit "MERGE" "${files[$i]} <-> ${files[$j]}" "${pct}% description token overlap"
      fi
      j=$(( j + 1 ))
    done
    i=$(( i + 1 ))
  done
}

apply_changes() {
  [ "$HELIX_SCAN_MODE" != "apply" ] && return 0
  while IFS=$'\t' read -r kind path reason; do
    case "$kind" in
      DEMOTE)
        mv "$path" "$HELIX_AGENTS_DIR/_archive/" 2>/dev/null \
          && echo "  applied: demoted $(basename "$path")"
        ;;
      SPAWN)
        mkdir -p "$path/.claude/agents"
        cat > "$path/.claude/agents/project-orchestrator.md" <<'STUB'
---
name: project-orchestrator
description: Project-level coordinator. Reads project context and dispatches specialist agents.
tools: Read, Grep, Glob, Bash, Task
---
You are the orchestrator for this project. Read the project layout, identify
the task type, and dispatch the right specialist agents in parallel. Always
pair executors with at least one independent reviewer.
STUB
        echo "  applied: spawned stub at $path/.claude/agents/"
        ;;
      DELETE|MERGE) : ;;
    esac
  done < "$FINDINGS_TMP"
}

report() {
  local count; count=$(wc -l < "$FINDINGS_TMP" | tr -d ' ')
  echo ""
  echo "---- Findings ($count) ----"
  if [ "$count" -eq 0 ]; then
    echo "  (clean — no candidates)"
    return 0
  fi
  awk -F'\t' '{printf "  [%-6s] %s\n           reason: %s\n", $1, $2, $3}' "$FINDINGS_TMP"

  if [ -n "$HELIX_NOTIFY_WEBHOOK" ]; then
    local body; body=$(printf '{"text":"Helix weekly scan: %s candidates (mode=%s)"}' "$count" "$HELIX_SCAN_MODE")
    curl -fsS -m 10 -X POST -H 'Content-Type: application/json' \
      -d "$body" "$HELIX_NOTIFY_WEBHOOK" >/dev/null 2>&1 \
      && echo "  webhook: notified" \
      || echo "  webhook: send failed (non-fatal)"
  fi
  return 1
}

main() {
  print_banner
  preflight
  scan_demote
  scan_delete
  scan_spawn
  scan_merge
  apply_changes
  report
}

main "$@"
