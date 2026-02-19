#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/setup_distro.sh"
source "$SCRIPT_DIR/setup_fns.sh"

begin "core" "base packages, git, fonts, fish, starship"

# =============================================================================
# Base packages
# =============================================================================
pkg_install fish htop git curl tealdeer direnv ncdu fd fzf bat jq zoxide

# =============================================================================
# Jujutsu (jj) version control
# =============================================================================
if [[ "$OS" == "linux" ]]; then
    pkg_install jujutsu
else
    pkg_install jj
fi

# =============================================================================
# Git config
# =============================================================================
current_email=$(git config --global user.email 2>/dev/null)
current_name=$(git config --global user.name 2>/dev/null)

printf "Git email [%s]: " "$current_email"
read -r git_email
printf "Git name [%s]: " "$current_name"
read -r git_name

[ -n "$git_email" ] && git config --global user.email "$git_email"
[ -n "$git_name" ]  && git config --global user.name "$git_name"
git config --global core.editor "nvim"

# =============================================================================
# Nerd fonts via getnf
# =============================================================================
mkdir -p "$HOME/.local/bin"
curl -fsSL https://raw.githubusercontent.com/getnf/getnf/main/install.sh | bash

if "$HOME/.local/bin/getnf" -i "FiraCode FiraMono JetBrainsMono"; then
    [[ "$OS" == "linux" ]] && fc-cache -f
elif [[ "$OS" == "macos" ]]; then
    echo "getnf failed, falling back to brew casks..."
    cask_install font-fira-code-nerd-font font-fira-mono-nerd-font font-jetbrains-mono-nerd-font
fi

# =============================================================================
# Fish as default shell
# =============================================================================
FISH_PATH="$(command -v fish)"
grep -qxF "$FISH_PATH" /etc/shells || echo "$FISH_PATH" | sudo tee -a /etc/shells
if [[ "$OS" == "macos" ]]; then
    chsh -s "$FISH_PATH"
else
    sudo chsh -s "$FISH_PATH" "$(whoami)"
fi

# =============================================================================
# Starship prompt
# =============================================================================
pkg_install starship

# Fisher + fish plugins are bootstrapped by chezmoi's run_onchange_after_fisher script

finished "core (base/jj/git/fonts/fish/starship/direnv/fisher)"
