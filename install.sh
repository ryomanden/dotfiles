#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

echo "▶ dotfiles dir: $DOTFILES_DIR"
echo "▶ backup dir:   $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

backup_if_exists() {
  local target="$1"
  if [ -e "$target" ] || [ -L "$target" ]; then
    echo "  ↪ backup: $target"
    mkdir -p "$BACKUP_DIR$(dirname "$target")"
    mv "$target" "$BACKUP_DIR/$target"
  fi
}

link() {
  local src="$1"
  local dst="$2"

  backup_if_exists "$dst"
  ln -snf "$src" "$dst"
  echo "  ✔ linked $dst → $src"
}

echo "▶ Linking dotfiles..."

# zsh
link "$DOTFILES_DIR/zsh/zshrc" "$HOME/.zshrc"
link "$DOTFILES_DIR/zsh/zimrc" "$HOME/.zimrc"
link "$DOTFILES_DIR/zsh/zprofile" "$HOME/.zprofile"

# git
link "$DOTFILES_DIR/git/gitconfig" "$HOME/.gitconfig"

# vim（vim/ と vimrc があるので vim/vimrc を優先）
if [ -f "$DOTFILES_DIR/vim/vimrc" ]; then
  link "$DOTFILES_DIR/vim/vimrc" "$HOME/.vimrc"
elif [ -f "$DOTFILES_DIR/vimrc" ]; then
  link "$DOTFILES_DIR/vimrc" "$HOME/.vimrc"
fi

# XDG config
mkdir -p "$HOME/.config"
for dir in "$DOTFILES_DIR/config/"*; do
  name="$(basename "$dir")"
  link "$dir" "$HOME/.config/$name"
done

echo
echo "▶ Done!"
echo
echo "ℹ Notes:"
echo "- Secrets (tokens, credentials) should be loaded via 1Password"
echo "- iTerm profiles are NOT auto-installed"
echo "- Restart your terminal or run: exec zsh"