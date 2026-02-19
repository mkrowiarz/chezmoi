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

# =============================================================================
# direnv hook for fish (appended only if not already present)
# =============================================================================
FISH_CONFIG="$HOME/.config/fish/config.fish"
mkdir -p "$HOME/.config/fish"
grep -qxF 'direnv hook fish | source' "$FISH_CONFIG" \
    || echo 'direnv hook fish | source' >> "$FISH_CONFIG"

# =============================================================================
# Fisher + fish plugins
# =============================================================================
pkg_install fisher
fish -c "fisher update"

finished "core (base/jj/git/fonts/fish/starship/direnv/fisher)"
