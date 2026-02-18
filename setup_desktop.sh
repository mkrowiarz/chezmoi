#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/setup_distro.sh"
source "$SCRIPT_DIR/setup_fns.sh"

begin "desktop" "hyprland, wezterm, kitty, yazi, greetd"

# =============================================================================
# Hyprland stack (Linux only)
# =============================================================================
if [[ "$OS" == "linux" ]]; then
    pkg_install waybar dunst wofi swww wl-clipboard grim slurp wlogout \
        brightnessctl hypridle hyprlock nwg-displays btop kanshi matugen
    aur_install better-control-git
fi

# =============================================================================
# WezTerm
# =============================================================================
if [[ "$OS" == "macos" ]]; then
    cask_install wezterm
else
    aur_install wezterm
fi

# =============================================================================
# Kitty
# =============================================================================
pkg_install kitty

# =============================================================================
# Yazi file manager
# =============================================================================
pkg_install yazi

# =============================================================================
# Login manager (Linux only)
# greetd config is managed separately — copy manually after install
# =============================================================================
if [[ "$OS" == "linux" ]]; then
    pkg_install greetd greetd-tuigreet

    sudo mkdir -p /var/cache/tuigreet
    sudo chown greeter:greeter /var/cache/tuigreet
    sudo chmod 0755 /var/cache/tuigreet

    sudo systemctl disable sddm.service    2>/dev/null || true
    sudo systemctl disable gdm.service     2>/dev/null || true
    sudo systemctl disable lightdm.service 2>/dev/null || true
    sudo systemctl enable greetd.service
fi

# =============================================================================
# Wallpaper + matugen theming (Linux only)
# =============================================================================
if [[ "$OS" == "linux" ]] && [[ -f "$HOME/.config/background.jpg" ]]; then
    matugen image "$HOME/.config/background.jpg"
fi

finished "desktop (hyprland/wezterm/kitty/yazi/greetd)"
