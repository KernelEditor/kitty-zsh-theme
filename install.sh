#!/usr/bin/env bash
# Installs the meow theme into Oh My Zsh. Pass --ghostty to also install the Ghostty config.
set -euo pipefail

src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
zsh_dir="${ZSH:-$HOME/.oh-my-zsh}"
custom="${ZSH_CUSTOM:-$zsh_dir/custom}"
zshrc="${ZDOTDIR:-$HOME}/.zshrc"

if [[ ! -d "$zsh_dir" ]]; then
  echo "Oh My Zsh not found at $zsh_dir. Install it first: https://ohmyz.sh" >&2
  exit 1
fi

mkdir -p "$custom/themes" "$custom/plugins"
cp "$src/meow.zsh-theme" "$custom/themes/meow.zsh-theme"
cp "$src/meow-greeting.zsh" "$custom/meow-greeting.zsh"
echo "Installed theme and greeting into $custom"

for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
  if [[ ! -d "$custom/plugins/$plugin" ]]; then
    git clone --quiet --depth=1 "https://github.com/zsh-users/$plugin" "$custom/plugins/$plugin"
    echo "Downloaded $plugin"
  fi
done

if [[ -f "$zshrc" ]]; then
  backup="$zshrc.backup-$(date +%Y%m%d-%H%M%S)"
  cp "$zshrc" "$backup"
  echo "Backed up .zshrc to $backup"
  if grep -q '^ZSH_THEME=' "$zshrc"; then
    tmp="$(mktemp)"
    sed 's/^ZSH_THEME=.*/ZSH_THEME="meow"/' "$zshrc" > "$tmp"
    cat "$tmp" > "$zshrc"
    rm -f "$tmp"
    echo 'Set ZSH_THEME="meow"'
  else
    echo 'Add ZSH_THEME="meow" to .zshrc, above the line that sources oh-my-zsh.sh'
  fi
else
  echo "No .zshrc found. Add ZSH_THEME=\"meow\" to yours."
fi

if [[ "${1:-}" == "--ghostty" ]]; then
  ghostty_dir="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty"
  mkdir -p "$ghostty_dir"
  if [[ -e "$ghostty_dir/config" ]]; then
    cp "$src/ghostty/config" "$ghostty_dir/config.meow"
    echo "Ghostty config already exists, so the new one is at $ghostty_dir/config.meow"
  else
    cp "$src/ghostty/config" "$ghostty_dir/config"
    echo "Installed Ghostty config"
  fi
fi

echo
echo 'Done. Add the plugins to .zshrc if you have not yet:'
echo '  plugins=(git zsh-autosuggestions zsh-syntax-highlighting)'
echo 'Then open a new terminal or run: exec zsh'
