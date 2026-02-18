#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/setup_distro.sh"
source "$SCRIPT_DIR/setup_fns.sh"

begin "essentials" "1password, bitwarden, rbw, tailscale"

# =============================================================================
# 1Password + CLI
# =============================================================================
if [[ "$OS" == "linux" ]]; then
    aur_install 1password 1password-cli
else
    cask_install 1password 1password-cli
fi

# =============================================================================
# Bitwarden + rbw (unofficial CLI)
# =============================================================================
if [[ "$OS" == "linux" ]]; then
    aur_install bitwarden rbw
else
    cask_install bitwarden
    pkg_install rbw
fi

# =============================================================================
# Tailscale
# =============================================================================
if [[ "$OS" == "linux" ]]; then
    pkg_install tailscale
    sudo systemctl enable --now tailscaled
else
    cask_install tailscale
fi

# =============================================================================
# 1Password SSH agent
# =============================================================================
if [[ "$OS" == "linux" ]]; then
    FISH_CONF="$HOME/.config/fish/conf.d/1password.fish"
    mkdir -p "$(dirname "$FISH_CONF")"
    grep -qxF 'set -gx SSH_AUTH_SOCK ~/.1password/agent.sock' "$FISH_CONF" 2>/dev/null \
        || echo 'set -gx SSH_AUTH_SOCK ~/.1password/agent.sock' >> "$FISH_CONF"
fi

finished "essentials (1password/bitwarden/rbw/tailscale)"
