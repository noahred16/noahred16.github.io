#!/usr/bin/env bash
# Installs command line tools via apt (Linux) or Homebrew (macOS).
set -euo pipefail

TOOLS=(
    htop
    ack
    btop
    fzf
    tmux
    ripgrep
    fd-find
    jq
    tree
    ncdu
)

# Package name overrides for macOS (Homebrew), keyed by the apt name above
declare -A MAC_OVERRIDES=(
    [fd-find]=fd
)

if command -v apt-get &>/dev/null; then
    sudo apt-get update
    sudo apt-get install -y "${TOOLS[@]}"
elif command -v brew &>/dev/null; then
    BREW_TOOLS=()
    for tool in "${TOOLS[@]}"; do
        BREW_TOOLS+=("${MAC_OVERRIDES[$tool]:-$tool}")
    done
    brew install "${BREW_TOOLS[@]}"
else
    echo "Warning: neither apt-get nor brew found. This script only supports apt-based Linux and macOS (Homebrew)." >&2
    exit 1
fi

echo "Tools installed: ${TOOLS[*]}"
