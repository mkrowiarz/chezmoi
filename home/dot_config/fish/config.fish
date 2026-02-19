# Starship
if type -q starship
    starship init fish | source
end

# fish_add_path "/Users/michal/.bun/bin"
#mise activate fish | source

# Direnv
if type -q direnv
    direnv hook fish | source
end

export PATH="$HOME/.local/bin:$PATH"
