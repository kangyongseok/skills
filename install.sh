#!/usr/bin/env bash
# fe-agent-pack installer — idempotent symlinks into the Claude Code config dir.
# Portable personal FE asset pack. Model-agnostic, company-neutral.
#
# Usage:
#   ./install.sh                 # links into ~/.claude
#   CLAUDE_HOME=/path ./install.sh   # links into a custom config dir
#
# Safe: never clobbers unrelated files or symlinks. Only manages links that
# point back into this repo. Re-running is a no-op for already-linked assets.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"

link() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"

  if [ -L "$dest" ]; then
    local cur
    cur="$(readlink "$dest")"
    if [ "$cur" = "$src" ]; then
      echo "  = $(basename "$dest") (already linked)"
      return
    fi
    # Replace only if it points into our repo (our own stale/dangling link).
    if [[ "$cur" == "$REPO_DIR"/* ]]; then
      rm "$dest"
    else
      echo "  ! $(basename "$dest") is a symlink to something else ($cur) — skipping" >&2
      return
    fi
  elif [ -e "$dest" ]; then
    echo "  ! $(basename "$dest") exists and is not a symlink — skipping" >&2
    return
  fi

  ln -s "$src" "$dest"
  echo "  + $(basename "$dest") -> $src"
}

echo "Installing fe-agent-pack"
echo "  from: $REPO_DIR"
echo "  into: $CLAUDE_HOME"

# Agents (single .md files)
for f in "$REPO_DIR"/agents/*.md; do
  [ -e "$f" ] || continue
  link "$f" "$CLAUDE_HOME/agents/$(basename "$f")"
done

# Commands (single .md files)
for f in "$REPO_DIR"/commands/*.md; do
  [ -e "$f" ] || continue
  link "$f" "$CLAUDE_HOME/commands/$(basename "$f")"
done

# Skills (directories containing SKILL.md)
for d in "$REPO_DIR"/skills/*/; do
  [ -d "$d" ] || continue
  link "${d%/}" "$CLAUDE_HOME/skills/$(basename "$d")"
done

echo "Done. Restart or re-scan skills to pick up new assets."
