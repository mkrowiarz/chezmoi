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
# Podman + caddy-proxy local dev stack (*.test → localhost)
# =============================================================================
if [[ "$OS" == "linux" ]]; then
    # Podman
    pkg_install podman
    systemctl --user enable --now podman.socket

    # Allow rootless podman to bind ports 80/443
    echo 'net.ipv4.ip_unprivileged_port_start=80' | sudo tee /etc/sysctl.d/99-rootless-ports.conf
    sudo sysctl -p /etc/sysctl.d/99-rootless-ports.conf

    # dnsmasq via NetworkManager for *.test → 127.0.0.1
    # chezmoi applies NM config to ~/.config/NetworkManager/
    # NM reads from /etc/NetworkManager/ so we copy them there
    sudo mkdir -p /etc/NetworkManager/conf.d /etc/NetworkManager/dnsmasq.d
    sudo cp "$HOME/.config/NetworkManager/conf.d/dnsmasq.conf" /etc/NetworkManager/conf.d/dnsmasq.conf
    sudo cp "$HOME/.config/NetworkManager/dnsmasq.d/test-local.conf" /etc/NetworkManager/dnsmasq.d/test-local.conf
    sudo systemctl restart NetworkManager

    # caddy-proxy: shared reverse proxy for all *.test containers
    podman network create caddy 2>/dev/null || true
    mkdir -p "$HOME/.local/share/caddy-proxy"
    systemctl --user enable --now caddy-proxy.service

    # Trust Caddy local CA (run after first start so cert is generated)
    echo "Waiting for Caddy to generate local CA..."
    sleep 5
    podman exec caddy-proxy caddy trust 2>/dev/null || \
        echo "Note: run 'podman exec caddy-proxy caddy trust' manually if trust fails"

elif [[ "$OS" == "macos" ]]; then
    cask_install docker

    # DNS for *.test on macOS via /etc/resolver/
    sudo mkdir -p /etc/resolver
    sudo cp "$HOME/.config/resolver/test" /etc/resolver/test
fi

finished "dev (php/rust/python/node/podman/caddy-proxy/harlequin)"
