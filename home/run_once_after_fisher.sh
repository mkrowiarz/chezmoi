#!/bin/bash
# Bootstrap Fisher and install plugins (runs once on first chezmoi apply)

if ! command -v fish &> /dev/null; then
    exit 0
fi

echo "Bootstrapping Fisher plugins..."
fish -c '
# Nuke all existing Fisher state and plugin files to avoid conflicts
if functions -q fisher
    fisher list | while read -l plugin
        fisher remove $plugin 2>/dev/null
    end
    functions -e fisher
end
rm -f ~/.config/fish/fish_plugins
rm -f ~/.config/fish/completions/fisher.fish
rm -f ~/.config/fish/functions/fisher.fish

# Clean slate: install Fisher fresh
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
fisher install jorgebucaran/fisher

# Install plugins
fisher install jethrokuan/z
fisher install jethrokuan/fzf
fisher install icezyclon/zoxide.fish
'
