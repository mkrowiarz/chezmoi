#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/setup_distro.sh"
source "$SCRIPT_DIR/setup_fns.sh"

begin "dev" "language runtimes + tooling"

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
pkg_install just ripgrep git-delta lazygit lazydocker

# =============================================================================
# Harlequin SQL client
# =============================================================================
uv tool install 'harlequin[postgres,mysql,s3]'

# =============================================================================
# Podman + caddy-proxy local dev stack (*.localhost subdomains)
# No DNS config needed — *.localhost resolves to 127.0.0.1 natively (RFC 6761)
# =============================================================================
if [[ "$OS" == "linux" ]]; then
    # Podman
    pkg_install podman
    systemctl --user enable --now podman.socket

    # Allow rootless podman to bind ports 80/443
    echo 'net.ipv4.ip_unprivileged_port_start=80' | sudo tee /etc/sysctl.d/99-rootless-ports.conf
    sudo sysctl -p /etc/sysctl.d/99-rootless-ports.conf

    # caddy-proxy: shared reverse proxy for all *.localhost containers
    podman network create caddy 2>/dev/null || true
    systemctl --user enable --now caddy-proxy.service

    # Trust Caddy local CA
    echo "Waiting for Caddy to generate local CA..."
    sleep 5
    CADDY_CA="$HOME/.local/share/containers/storage/volumes/caddy_data/_data/caddy/pki/authorities/local/root.crt"
    sudo trust anchor --store "$CADDY_CA" && sudo update-ca-trust || \
        echo "Note: run 'sudo trust anchor --store $CADDY_CA && sudo update-ca-trust' manually"

elif [[ "$OS" == "macos" ]]; then
    cask_install docker
fi

finished "dev (rust/python/node/podman/caddy-proxy/harlequin)"
