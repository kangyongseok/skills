#!/usr/bin/env bash
# fe-agent-pack uninstaller — removes ONLY the symlinks that point into this repo.
# Unrelated files and other symlinks in the config dir are never touched.
#
# Usage:
#   ./uninstall.sh
#   CLAUDE_HOME=/path ./uninstall.sh
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"

removed=0
for sub in agents commands skills; do
  target_dir="$CLAUDE_HOME/$sub"
  [ -d "$target_dir" ] || continue
  for entry in "$target_dir"/*; do
    [ -L "$entry" ] || continue
    cur="$(readlink "$entry")"
    if [[ "$cur" == "$REPO_DIR"/* ]]; then
      rm "$entry"
      echo "  - removed $(basename "$entry")"
      removed=$((removed + 1))
    fi
  done
done

echo "Removed $removed link(s) pointing into $REPO_DIR"
