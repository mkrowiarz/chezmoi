#!/bin/bash

ask_user() {
    read -p "? (Y/n): " choice
    case "$choice" in
        n|N ) return 1;;
        * ) return 0;;
    esac
}

begin() {
    if [[ "$(uname)" == "Darwin" ]]; then
        echo "==> $1: $2"
    else
        if command -v dialog >/dev/null 2>&1; then
            dialog --title " $1 " --infobox "\n$2\n" 5 60
            sleep 0.5
        else
            echo "==> $1: $2"
        fi
    fi
}

finished() {
    if [[ "$(uname)" == "Darwin" ]]; then
        echo "Done: $1"
    else
        if command -v dialog >/dev/null 2>&1; then
            dialog --title " Done " --infobox "\n✓ $1\n" 5 60
            sleep 0.3
        else
            echo "Done: $1"
        fi
    fi
}

# Symlink a directory, removing existing dir if present
# Usage: link_dir <source> <target>
link_dir() {
    local src="$1"
    local dst="$2"
    [ -d "$dst" ] && [ ! -L "$dst" ] && rm -rf "$dst"
    ln -sfn "$src" "$dst"
}
