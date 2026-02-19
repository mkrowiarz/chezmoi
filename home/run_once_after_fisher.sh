#!/bin/bash
# Bootstrap Fisher and install plugins (runs once on first chezmoi apply)

if ! command -v fish &> /dev/null; then
    exit 0
fi

echo "Bootstrapping Fisher plugins..."
fish -c '
# Install Fisher if needed
if not functions -q fisher
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
    fisher install jorgebucaran/fisher
end

# Remove any conflicting files from previous chezmoi-managed installs
for f in conf.d/z.fish conf.d/fzf.fish conf.d/zoxide.fish
    set -l target ~/.config/fish/$f
    if test -f $target; and not test -L $target
        rm -f $target
    end
end

# Write plugin list and install
printf "%s\n" jorgebucaran/fisher jethrokuan/z jethrokuan/fzf icezyclon/zoxide.fish > ~/.config/fish/fish_plugins
fisher update
'
