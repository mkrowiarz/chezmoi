# eza aliases - auto-sourced on fish startup via conf.d
# Source: ~/.dotfiles/.config/fish/functions/eza-dev.fish

set -l eza_functions_file ~/.config/fish/functions/eza-dev.fish

if test -f $eza_functions_file
    source $eza_functions_file
else
    echo "Warning: eza-dev.fish not found at $eza_functions_file" >&2
end
