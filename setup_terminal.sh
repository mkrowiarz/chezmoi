#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/setup_distro.sh"
source "$SCRIPT_DIR/setup_fns.sh"

# =============================================================================
# ZELLIJ - terminal multiplexer
# =============================================================================

begin "zellij" "terminal multiplexer"

pkg_install zellij

finished "zellij"

# =============================================================================
# NEOVIM + ASTRONVIM - primary editor
# =============================================================================

begin "neovim" "neovim + AstroNvim"

pkg_install neovim ripgrep lua luarocks

# Backup existing nvim state so AstroNvim starts clean
mv ~/.local/share/nvim ~/.local/share/nvim.bak 2>/dev/null || true
mv ~/.local/state/nvim ~/.local/state/nvim.bak 2>/dev/null || true
mv ~/.cache/nvim       ~/.cache/nvim.bak        2>/dev/null || true

# chezmoi applies dot_config/astronvim_v5 -> ~/.config/astronvim_v5
# symlink it to nvim so neovim picks it up
ln -sfn "$HOME/.config/astronvim_v5" "$HOME/.config/nvim"

finished "neovim"

# =============================================================================
# VIM - lightweight fallback
# =============================================================================

begin "vim" "vim + pathogen"

pkg_install vim

mkdir -p ~/.vim/autoload ~/.vim/bundle
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

finished "vim"
