#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/setup_distro.sh"
source "$SCRIPT_DIR/setup_fns.sh"

begin "dev" "language runtimes + tooling"

# =============================================================================
# PHP + Composer
# =============================================================================
if [[ "$OS" == "linux" ]]; then
    pkg_install php php-fpm composer php-intl php-sqlite php-gd xdebug
else
    pkg_install php composer
fi

# =============================================================================
# Rust via rustup
# =============================================================================
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"

# =============================================================================
# Python + uv
# =============================================================================
if [[ "$OS" == "linux" ]]; then
    pkg_install python python-pip
else
    pkg_install python
fi
curl -LsSf https://astral.sh/uv/install.sh | sh

# =============================================================================
# Node.js via fnm
# =============================================================================
curl -fsSL https://fnm.vercel.app/install | bash
export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env)"
fnm install 22 && fnm default 22

# =============================================================================
# CLI tools
# =============================================================================
pkg_install just ripgrep git-delta

# =============================================================================
# Harlequin SQL client
# =============================================================================
uv tool install 'harlequin[postgres,mysql,s3]'

# =============================================================================
# Podman (Linux only)
# Note: caddy-proxy setup run separately after podman is confirmed working
# =============================================================================
if [[ "$OS" == "linux" ]]; then
    pkg_install podman podman-compose
    systemctl --user enable --now podman.socket
fi

# =============================================================================
# Docker Desktop (macOS only)
# =============================================================================
if [[ "$OS" == "macos" ]]; then
    cask_install docker
fi

finished "dev (php/rust/python/node/podman/harlequin)"
