# dotfiles

Personal dotfiles managed with [chezmoi](https://chezmoi.io). Supports **Arch Linux** (CachyOS) and **macOS**.

## Structure

```
chezmoi/
├── home/                        # chezmoi source root (maps to ~/)
│   ├── .chezmoi.toml.tmpl       # generates chezmoi config with OS-aware variables
│   └── dot_config/
│       ├── fish/                # fish shell + conf.d + plugins
│       ├── wezterm/             # wezterm.lua.tmpl (fish path templated)
│       ├── starship.toml        # prompt config
│       ├── zellij/              # terminal multiplexer
│       └── astronvim_v5/        # neovim config (AstroNvim)
├── setup_distro.sh              # OS detection + pkg_install/aur_install/cask_install
├── setup_fns.sh                 # shared helpers: begin, finished, ask_user, link_dir
├── setup_core.sh                # fish, starship, fonts, git, jujutsu, direnv
├── setup_essentials.sh          # 1password, bitwarden, rbw, tailscale
├── setup_terminal.sh            # zellij, neovim (AstroNvim), vim
├── setup_comms.sh               # vesktop, ferdium
├── setup_desktop.sh             # hyprland stack, waybar, wezterm (coming soon)
└── setup_dev.sh                 # php, rust, python, node, podman (coming soon)
```

## Bootstrap

### Prerequisites

- **Arch**: `sudo pacman -S git chezmoi`
- **macOS**: `brew install git chezmoi`

### Fresh machine setup

```bash
# 1. Init chezmoi from this repo
chezmoi init git@github.com:mkrowiarz/chezmoi.git

# 2. Apply managed configs
chezmoi apply

# 3. Run setup scripts in order
cd ~/chezmoi
bash setup_core.sh          # base tools, shell, fonts
bash setup_essentials.sh    # passwords, VPN
bash setup_terminal.sh      # editor, multiplexer
bash setup_comms.sh         # communication apps
```

## Setup scripts

| Script | What it installs |
|-|-|
| `setup_core.sh` | fish, starship, nerd fonts, git, jujutsu, direnv, tealdeer |
| `setup_essentials.sh` | 1Password + CLI, Bitwarden, rbw, Tailscale |
| `setup_terminal.sh` | zellij, neovim (AstroNvim), vim |
| `setup_comms.sh` | Vesktop (Discord), Ferdium |
| `setup_desktop.sh` | Hyprland, waybar, wezterm, matugen, yazi *(coming soon)* |
| `setup_dev.sh` | PHP, Rust, Python, Node (fnm), Podman *(coming soon)* |

## Managed configs

| Config | Notes |
|-|-|
| `fish/` | config.fish, conf.d/, fish_variables, plugins |
| `wezterm/wezterm.lua` | templated — fish path per OS |
| `starship.toml` | prompt |
| `zellij/` | terminal multiplexer |
| `astronvim_v5/` | neovim config, applied to `~/.config/astronvim_v5` |

## Template variables

Available in any `.tmpl` file:

| Variable | Linux | macOS |
|-|-|-|
| `.os` | `linux` | `darwin` |
| `.fish` | `/usr/bin/fish` | `/opt/homebrew/bin/fish` |

## Adding new configs

```bash
# Add a file
chezmoi add ~/.config/something/config.toml

# Add as template (for OS-specific content)
chezmoi add --template ~/.config/something/config.toml

# Check what would change
chezmoi diff

# Apply
chezmoi apply
```
