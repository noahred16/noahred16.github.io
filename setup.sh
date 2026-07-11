#!/usr/bin/env bash
# Symlinks dotfiles from this repo into the home directory.
# Safe to re-run: existing real files are backed up, existing symlinks are replaced.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
    local src="$1"
    local dest="$2"

    if [ -L "$dest" ]; then
        rm "$dest"
    elif [ -e "$dest" ]; then
        # a real file already exists, rename it aside with a timestamp instead of overwriting it
        mv "$dest" "$dest.bak.$(date +%Y%m%d%H%M%S)"
        echo "Backed up existing $dest"
    fi

    ln -s "$src" "$dest"
    echo "Linked $dest -> $src"
}

link "$SCRIPT_DIR/.bash_profile" "$HOME/.bash_profile"
link "$SCRIPT_DIR/.vimrc" "$HOME/.vimrc"
link "$SCRIPT_DIR/.gitconfig" "$HOME/.gitconfig"

# Make sure .bashrc sources .bash_profile so login settings apply to interactive shells
if ! grep -qs 'source ~/.bash_profile' "$HOME/.bashrc" 2>/dev/null; then
    echo 'source ~/.bash_profile' >> "$HOME/.bashrc"
    echo "Added 'source ~/.bash_profile' to $HOME/.bashrc"
fi

echo "Setup complete."
