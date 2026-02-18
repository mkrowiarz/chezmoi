#!/bin/bash
# setup_distro.sh - OS detection and package helpers for Arch Linux and macOS

OS=""
AUR_HELPER=""

detect_os() {
    case "$(uname -s)" in
        Darwin)
            OS="macos"
            detect_homebrew
            ;;
        Linux)
            OS="linux"
            detect_distro
            ;;
        *)
            echo "ERROR: Unsupported OS '$(uname -s)'."
            exit 1
            ;;
    esac
}

detect_distro() {
    if [ ! -f /etc/os-release ]; then
        echo "ERROR: Cannot detect distro. /etc/os-release not found."
        exit 1
    fi
    . /etc/os-release
    case "$ID" in
        arch|cachyos|manjaro|endeavouros|garuda)
            detect_aur_helper
            echo "Detected: $ID (AUR_HELPER=${AUR_HELPER:-none})"
            ;;
        *)
            echo "ERROR: Unsupported distro '$ID'. This setup is for Arch-based systems only."
            exit 1
            ;;
    esac
}

detect_aur_helper() {
    if command -v yay &>/dev/null; then
        AUR_HELPER="yay"
    elif command -v paru &>/dev/null; then
        AUR_HELPER="paru"
    else
        echo "WARNING: No AUR helper found. Install yay or paru for full AUR functionality."
    fi
}

detect_homebrew() {
    if command -v brew &>/dev/null; then
        echo "Detected: macOS (Homebrew found)"
        return
    fi
    echo "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add brew to PATH for the rest of this session (Apple Silicon path)
    if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
}

pkg_update() {
    case "$OS" in
        macos) brew update ;;
        linux) sudo pacman -Sy ;;
    esac
}

pkg_upgrade() {
    case "$OS" in
        macos) brew upgrade ;;
        linux) sudo pacman -Syu --noconfirm ;;
    esac
}

pkg_install() {
    case "$OS" in
        macos) brew install "$@" ;;
        linux) sudo pacman -S --noconfirm --needed "$@" ;;
    esac
}

# AUR packages on Linux; falls back to brew install on macOS (no AUR equivalent)
aur_install() {
    case "$OS" in
        macos)
            brew install "$@"
            ;;
        linux)
            if [ -z "$AUR_HELPER" ]; then
                echo "WARNING: No AUR helper available. Skipping: $*"
                return 1
            fi
            "$AUR_HELPER" -S --noconfirm --needed "$@"
            ;;
    esac
}

# Cask packages (macOS GUI apps); on Linux installs via AUR helper or pacman
cask_install() {
    case "$OS" in
        macos)
            brew install --cask "$@"
            ;;
        linux)
            if [ -n "$AUR_HELPER" ]; then
                "$AUR_HELPER" -S --noconfirm --needed "$@"
            else
                sudo pacman -S --noconfirm --needed "$@"
            fi
            ;;
    esac
}

detect_os
