#!/bin/bash
# Plugins: jorgebucaran/fisher jethrokuan/z jethrokuan/fzf icezyclon/zoxide.fish

if ! command -v fish &> /dev/null; then
    exit 0
fi

# Remove CachyOS's broken done.fish plugin
if [[ -f /usr/share/cachyos-fish-config/conf.d/done.fish ]]; then
    sudo rm -f /usr/share/cachyos-fish-config/conf.d/done.fish 2>/dev/null || true
fi

echo "Installing/updating Fisher plugins..."
fish -c '
# Bootstrap Fisher if needed
if not functions -q fisher
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
    fisher install jorgebucaran/fisher
end

# Remove conflicting plugin files before installing
for f in conf.d/z.fish conf.d/fzf.fish conf.d/zoxide.fish
    set -l target ~/.config/fish/$f
    if test -f $target; and not test -L $target
        rm -f $target
    end
end

# Write desired plugins and install
printf "%s\n" jorgebucaran/fisher jethrokuan/z jethrokuan/fzf icezyclon/zoxide.fish > ~/.config/fish/fish_plugins
fisher update
'
