# Arch.Config
My Arch-linux setup

## Overview
[WIP]

### Waybar setup
[WIP]

### Shortcuts
[WIP]

### Rofi
[WIP]

## Quick Setup

For fresh Arch installations, use the [automated installer](system-installer/README.md) to install all packages and restore dotfiles:
```bash
# Direct install from GitHub
curl -sSL https://raw.githubusercontent.com/joao-paulo-santos/Arch.Config/main/system-installer/installer.sh | bash

# Or clone and run locally
cd ~/.config/system-installer
./installer.sh
```

## Manual Setup

Don't forget to symlink

```
ln -s ~/.config/zsh/.zshrc ~/.zshrc

# for custom Rofi flags
rm -rf ~/.local/share/applications
ln -sfn "$HOME/.config/my-desktop-entries" "$HOME/.local/share/applications"

```