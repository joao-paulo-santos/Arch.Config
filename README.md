# Arch.Config
My Arch-linux dotfiles, minimal professional hyprland setup

## Overview
[WIP]

### Waybar setup
[WIP]

### Shortcuts
[WIP]

### Rofi
- Custom [Smart Drun script](./rofi/scripts/rofi-smartdrun.js) (opened Windows > Launch > workspaces > math)

### Custom Background Manager

Dynamic wallpaper manager for Hyprland with multiple service backends and trigger modes. Hypr-bg-Manager, Available as standalone [AUR package](https://github.com/joao-paulo-santos/hypr-bg-manager).

Features:
- Per-workspace or global wallpaper modes
- Multiple services: swww, hyprpaper, swaybg, mpvpaper  
- Trigger modes: workspace change, timer, or both
- Auto-format detection and service-specific optimization

## Apps

Shell: Zsh
Terminal: Kitty
File Manager: Yazi
Media Player: mpv
image viewer: mirage

### Misc

Zoxide: cd jumper

## Quick Setup

For fresh Arch installations, use the [automated installer](system-installer/README.md) to install all packages and restore dotfiles:
```bash
# Direct install from GitHub
curl -sSL https://raw.githubusercontent.com/joao-paulo-santos/Arch.Config/main/system-installer/installer.sh | bash

# Or clone with submodules and run locally
git clone --recurse-submodules https://github.com/joao-paulo-santos/Arch.Config.git ~/.config
cd ~/.config/system-installer
./installer.sh
```

## Manual Setup

**Important**: Clone with submodules to get all components:
```bash
git clone --recurse-submodules https://github.com/joao-paulo-santos/Arch.Config.git ~/.config
```

Then symlink required files:
```bash
ln -s ~/.config/zsh/.zshrc ~/.zshrc

# for custom Rofi flags
rm -rf ~/.local/share/applications
ln -sfn "$HOME/.config/my-desktop-entries" "$HOME/.local/share/applications"
```