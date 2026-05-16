#!/usr/bin/env bash
# Helix install script — idempotent, backs up existing config before overwriting
# Usage:
#   ./install.sh             # install or reinstall
#   ./install.sh --uninstall # remove Helix files (keep backups)

set -u

HELIX_HOME="${HELIX_HOME:-$HOME/.claude}"
HELIX_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

banner() {
  echo "================================================================"
  echo " Helix Installer — v0.1"
  echo " source: $HELIX_SRC"
  echo " target: $HELIX_HOME"
  echo "================================================================"
}

backup_existing() {
  local f="$1"
  if [ -f "$f" ]; then
    cp "$f" "${f}.bak.${TIMESTAMP}"
    echo "  backed up: $f → $(basename ${f}.bak.${TIMESTAMP})"
  fi
}

install_files() {
  mkdir -p "$HELIX_HOME/agents" "$HELIX_HOME/scripts"

  # 1. CLAUDE.md (with backup)
  backup_existing "$HELIX_HOME/CLAUDE.md"
  cp "$HELIX_SRC/CLAUDE.md" "$HELIX_HOME/CLAUDE.md"
  echo "  installed: ~/.claude/CLAUDE.md"

  # 2. review-agent-template (drop-in agent)
  cp "$HELIX_SRC/agents/review-agent-template.md" "$HELIX_HOME/agents/reviewer-correctness.md"
  echo "  installed: ~/.claude/agents/reviewer-correctness.md"

  # 3. weekly-scan.sh (chmod +x)
  cp "$HELIX_SRC/scripts/weekly-scan.sh" "$HELIX_HOME/scripts/weekly-scan.sh"
  chmod +x "$HELIX_HOME/scripts/weekly-scan.sh"
  echo "  installed: ~/.claude/scripts/weekly-scan.sh (executable)"
}

setup_schedule() {
  echo ""
  echo "Optional: schedule weekly-scan.sh to run Monday 09:00."
  echo "  macOS — launchd plist template:"
  echo ""
  echo "    cat > ~/Library/LaunchAgents/com.helix.weekly-scan.plist <<PLIST"
  echo "    <?xml version=\"1.0\" encoding=\"UTF-8\"?>"
  echo "    <!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">"
  echo "    <plist version=\"1.0\"><dict>"
  echo "      <key>Label</key><string>com.helix.weekly-scan</string>"
  echo "      <key>ProgramArguments</key><array>"
  echo "        <string>$HELIX_HOME/scripts/weekly-scan.sh</string>"
  echo "      </array>"
  echo "      <key>StartCalendarInterval</key><dict>"
  echo "        <key>Weekday</key><integer>1</integer>"
  echo "        <key>Hour</key><integer>9</integer><key>Minute</key><integer>0</integer>"
  echo "      </dict>"
  echo "    </dict></plist>"
  echo "    PLIST"
  echo "    launchctl load ~/Library/LaunchAgents/com.helix.weekly-scan.plist"
  echo ""
  echo "  Linux — cron entry:"
  echo "    (crontab -l 2>/dev/null; echo \"0 9 * * 1 $HELIX_HOME/scripts/weekly-scan.sh\") | crontab -"
}

uninstall() {
  echo "Removing Helix files (backups preserved)..."
  rm -f "$HELIX_HOME/agents/reviewer-correctness.md"
  rm -f "$HELIX_HOME/scripts/weekly-scan.sh"
  echo "  removed: agents/reviewer-correctness.md, scripts/weekly-scan.sh"
  echo "  CLAUDE.md NOT removed — restore manually from latest .bak.* if needed"
  echo "  launchd: launchctl unload ~/Library/LaunchAgents/com.helix.weekly-scan.plist"
}

main() {
  banner
  if [ "${1:-}" = "--uninstall" ]; then
    uninstall
    exit 0
  fi
  install_files
  setup_schedule
  echo ""
  echo "✅ Helix installed. Start a new Claude Code session to load."
  echo "   First run: try a multi-agent task and watch reviewer-correctness fire."
}

main "$@"
