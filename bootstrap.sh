#!/usr/bin/env bash
# One-shot dev-environment bootstrap.
#   dotfiles (zsh) + git aliases + editor extensions + Claude Code assets.
# Idempotent and safe: existing real files are backed up before linking;
# secrets are never included (you fill in ~/.secrets.zsh yourself).
#
# Usage:
#   ./bootstrap.sh
#   CLAUDE_HOME=/custom ./bootstrap.sh   # forwarded to install.sh
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

link_dotfile() {
  local src="$1" dest="$2"
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    echo "  = $(basename "$dest") (already linked)"; return
  fi
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    mkdir -p "$BACKUP_DIR"; mv "$dest" "$BACKUP_DIR/"; echo "  backed up $(basename "$dest") -> $BACKUP_DIR/"
  fi
  ln -sfn "$src" "$dest"; echo "  + $(basename "$dest") -> $src"
}

resolve_editor() {
  local name="$1" p=""
  if command -v "$name" >/dev/null 2>&1; then command -v "$name"; return; fi
  case "$name" in
    code)   p="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" ;;
    cursor) p="/Applications/Cursor.app/Contents/Resources/app/bin/cursor" ;;
  esac
  [ -x "$p" ] && echo "$p" || echo ""
}

install_exts() {
  local name="$1" list="$2" bin
  if [ "${SKIP_EDITOR_EXT:-0}" = "1" ]; then echo "  $name: skipped (SKIP_EDITOR_EXT=1)"; return; fi
  bin="$(resolve_editor "$name")"
  if [ -z "$bin" ]; then echo "  $name CLI not found — skipping (open $name and run 'Shell Command: Install ... in PATH')"; return; fi
  [ -f "$list" ] || { echo "  no list for $name"; return; }
  local n=0
  while IFS= read -r ext; do
    [ -n "$ext" ] || continue
    "$bin" --install-extension "$ext" --force >/dev/null 2>&1 && { echo "  + $ext"; n=$((n+1)); } || echo "  ! failed $ext"
  done < "$list"
  echo "  $name: $n extension(s) processed"
}

echo "==> [1/4] dotfiles (zsh)"
link_dotfile "$REPO_DIR/dotfiles/zshrc"    "$HOME/.zshrc"
link_dotfile "$REPO_DIR/dotfiles/zprofile" "$HOME/.zprofile"
link_dotfile "$REPO_DIR/dotfiles/p10k.zsh" "$HOME/.p10k.zsh"
if [ ! -f "$HOME/.secrets.zsh" ]; then
  cp "$REPO_DIR/dotfiles/secrets.zsh.example" "$HOME/.secrets.zsh"
  echo "  created ~/.secrets.zsh from template — FILL IN your tokens (never committed)"
else
  echo "  = ~/.secrets.zsh (kept existing)"
fi

echo "==> [2/4] git aliases + color"
git config --global include.path "$REPO_DIR/git/aliases.gitconfig"
echo "  wired include.path -> git/aliases.gitconfig"
echo "  (set your identity: git config --global user.name '...' && git config --global user.email '...')"

echo "==> [3/4] editor extensions"
install_exts code   "$REPO_DIR/editors/vscode-extensions.txt"
install_exts cursor "$REPO_DIR/editors/cursor-extensions.txt"

echo "==> [4/4] Claude Code skills / agents / commands"
"$REPO_DIR/install.sh"

echo
echo "Bootstrap complete."
[ -d "$BACKUP_DIR" ] && echo "Backups of replaced files: $BACKUP_DIR"
echo "Next: fill in ~/.secrets.zsh, then 'exec zsh' to reload your shell."
