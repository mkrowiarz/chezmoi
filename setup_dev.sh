#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/setup_distro.sh"
source "$SCRIPT_DIR/setup_fns.sh"

begin "dev" "language runtimes + tooling"

# =============================================================================
# Rust via rustup
# =============================================================================
pkg_install rustup
rustup default stable

# =============================================================================
# Python + uv
# =============================================================================
if [[ "$OS" == "linux" ]]; then
    pkg_install python python-pip uv
else
    pkg_install python uv
fi

# =============================================================================
# Node.js via fnm
# =============================================================================
pkg_install fnm
eval "$(fnm env --shell bash)"
fnm install 25 && fnm default 25

# =============================================================================
# CLI tools
# =============================================================================
pkg_install just ripgrep git-delta lazygit lazydocker
sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b ~/.local/bin

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
    fish -c 'set -Ux PODMAN_COMPOSE_WARNING_LOGS false'

    # Allow rootless podman to bind ports 80/443
    echo 'net.ipv4.ip_unprivileged_port_start=80' | sudo tee /etc/sysctl.d/99-rootless-ports.conf
    sudo sysctl -p /etc/sysctl.d/99-rootless-ports.conf

    # caddy-proxy: shared reverse proxy for all *.localhost containers
    podman network create caddy 2>/dev/null || true
    systemctl --user enable --now caddy-proxy.service

    # Trust Caddy local CA (if available)
    CADDY_CA="$HOME/.local/share/containers/storage/volumes/caddy_data/_data/caddy/pki/authorities/local/root.crt"
    if [[ -f "$CADDY_CA" ]]; then
        sudo trust anchor --store "$CADDY_CA" && sudo update-ca-trust
    else
        echo "Note: Caddy CA not found yet. After caddy-proxy starts, run:"
        echo "  sudo trust anchor --store $CADDY_CA && sudo update-ca-trust"
    fi

elif [[ "$OS" == "macos" ]]; then
    cask_install docker
fi

# =============================================================================
# JetBrains Toolbox (optional: --with-jetbrains)
# =============================================================================
if [[ " $* " == *" --with-jetbrains "* ]]; then
    aur_install jetbrains-toolbox
fi

finished "dev (rust/python/node/podman/caddy-proxy/harlequin)"
