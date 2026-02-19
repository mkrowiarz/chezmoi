#!/bin/bash
# Remove CachyOS's broken done.fish plugin (can come back after pacman updates)

if [[ -f /usr/share/cachyos-fish-config/conf.d/done.fish ]]; then
    sudo rm -f /usr/share/cachyos-fish-config/conf.d/done.fish 2>/dev/null || true
fi
