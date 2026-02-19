#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/setup_distro.sh"
source "$SCRIPT_DIR/setup_fns.sh"

begin "terminal" "zellij, neovim (AstroNvim), zed"

# =============================================================================
# Zellij - terminal multiplexer
# =============================================================================
pkg_install zellij

# =============================================================================
# Neovim + AstroNvim
# =============================================================================
pkg_install neovim ripgrep lua luarocks

# Backup existing nvim state so AstroNvim starts clean
mv ~/.local/share/nvim ~/.local/share/nvim.bak 2>/dev/null || true
mv ~/.local/state/nvim ~/.local/state/nvim.bak 2>/dev/null || true
mv ~/.cache/nvim       ~/.cache/nvim.bak        2>/dev/null || true

# chezmoi applies dot_config/astronvim_v5 -> ~/.config/astronvim_v5
# symlink it to nvim so neovim picks it up
ln -sfn "$HOME/.config/astronvim_v5" "$HOME/.config/nvim"

# =============================================================================
# Zed editor
# =============================================================================
if [[ "$OS" == "linux" ]]; then
    pkg_install zed
else
    cask_install zed
fi

finished "terminal (zellij/neovim/zed)"
