# eza development shortcuts - list view focused
# Source this file or place in ~/.config/fish/functions/

function ls --description 'Better ls with list view'
    eza -l --icons --group-directories-first --color=auto $argv
end

function ll --description 'List view with git status'
    eza -l --icons --git --time-style=long-iso --group-directories-first $argv
end

function lt --description 'Tree list view (2 levels)'
    eza -l --tree --icons --level=2 --ignore-glob=".git|node_modules|__pycache__|target|venv|.venv" $argv
end

function la --description 'List all files sorted by modified time'
    eza -la --icons --sort=modified --reverse --group-directories-first $argv
end

function ltt --description 'Deep tree list view (3 levels)'
    eza -la --tree --icons --level=3 --ignore-glob=".git|node_modules|*.pyc|.pytest_cache|__pycache__|target|venv|.venv" $argv
end

function lst --description 'Tree view with dynamic levels (lst, lst1, lst2, lst3)'
    # Get the command name used to invoke
    set -l cmd (status current-command)
    
    # Extract level from command name (lst → default, lst1 → 1, etc.)
    set -l level 2  # default
    if string match -qr '^lst[1-3]$' $cmd
        set level (string replace 'lst' '' $cmd)
    end
    
    # Cap at max 3 for safety
    if test $level -gt 3
        set level 3
    end
    
    eza -l --tree --icons --git --group-directories-first --level=$level \
        --ignore-glob=".git|node_modules|__pycache__|target|venv|.venv" $argv
end

# Thin wrappers for direct level access
function lst1 --description 'Tree view level 1'; lst $argv; end
function lst2 --description 'Tree view level 2'; lst $argv; end
function lst3 --description 'Tree view level 3'; lst $argv; end
