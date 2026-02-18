#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/setup_distro.sh"
source "$SCRIPT_DIR/setup_fns.sh"

begin "comms" "vesktop, ferdium"

# Vesktop - Wayland-native Discord with Vencord
if [[ "$OS" == "macos" ]]; then
    cask_install vesktop
else
    aur_install vesktop
fi

# Ferdium - Slack, WhatsApp, and other web apps in one place
if [[ "$OS" == "macos" ]]; then
    cask_install ferdium
else
    aur_install ferdium-bin
fi

finished "comms (vesktop/ferdium)"
