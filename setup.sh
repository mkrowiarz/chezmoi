#!/bin/bash
# setup.sh - Master entry point for dotfiles setup
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/setup_distro.sh"
source "$SCRIPT_DIR/setup_fns.sh"

SECTIONS=(core essentials desktop terminal dev comms)
DESCRIPTIONS=(
    "fish, starship, fonts, git, jujutsu, direnv, fisher"
    "1password, bitwarden, rbw, tailscale"
    "hyprland, wezterm, kitty, yazi, greetd, matugen"
    "zellij, neovim (AstroNvim)"
    "rust, python, node, podman, harlequin"
    "vesktop, ferdium"
)

run_section() {
    local section="$1"
    bash "$SCRIPT_DIR/setup_${section}.sh"
}

# Apply chezmoi configs before running any section
echo ""
echo "  Applying chezmoi configs..."
chezmoi apply
echo ""

# Run all sections
if [[ "$1" == "--all" ]]; then
    for section in "${SECTIONS[@]}"; do
        run_section "$section"
    done
    exit 0
fi

# Interactive menu
echo ""
echo "  Dotfiles Setup"
echo "  =============="
echo ""
for i in "${!SECTIONS[@]}"; do
    printf "  [%d] %s — %s\n" "$((i+1))" "${SECTIONS[i]}" "${DESCRIPTIONS[i]}"
done
echo "  [a] all"
echo "  [q] quit"
echo ""

while true; do
    printf "Select sections (e.g. 1 3 4 or a): "
    read -r input

    [[ "$input" == "q" ]] && exit 0

    if [[ "$input" == "a" ]]; then
        for section in "${SECTIONS[@]}"; do
            run_section "$section"
        done
        break
    fi

    for token in $input; do
        if [[ "$token" =~ ^[0-9]+$ ]] && (( token >= 1 && token <= ${#SECTIONS[@]} )); then
            run_section "${SECTIONS[$((token-1))]}"
        else
            echo "  Invalid: $token"
        fi
    done
    break
done

echo ""
echo "Done! Log out and back in for shell changes to take effect."
