#!/bin/bash
# Bootstrap Fisher and install plugins (runs once on first chezmoi apply)

if ! command -v fish &> /dev/null; then
    exit 0
fi

echo "Bootstrapping Fisher plugins..."
fish -c '
# Remove all non-chezmoi fish plugin files to avoid Fisher "conflicting files" errors.
# chezmoi managed paths look like ".config/fish/functions/foo.fish"
set -l managed (chezmoi managed --include=files 2>/dev/null)
for dir in functions completions conf.d
    for f in ~/.config/fish/$dir/*.fish
        test -f "$f"; or continue
        # Convert absolute path to chezmoi-managed relative path (.config/fish/...)
        set -l rel (string replace -- "$HOME/" "" "$f")
        if not contains -- "$rel" $managed
            rm -f "$f"
        end
    end
end
rm -f ~/.config/fish/fish_plugins

# Install Fisher fresh
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
fisher install jorgebucaran/fisher

# Install plugins
fisher install jethrokuan/fzf
'
