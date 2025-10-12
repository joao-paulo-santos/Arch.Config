# Arch Linux System Installer

Automated installer script for restoring your Arch Linux system packages after a fresh installation.

## Files

- `installer.sh` - Main installer script (auto-generated)
- `generate-installer.sh` - Generator script that creates installer.sh from current system
- `README.md` - This file

## Usage

### Generating the Installer

Run this on your current system to generate/update the installer:

```bash
./generate-installer.sh
```

This will:
- Extract all explicitly installed packages
- Categorize packages by type (Hyprland, Audio, Graphics, etc.)
- Detect AUR packages
- Generate a new `installer.sh` script

### Using the Installer

```bash
./installer.sh [OPTIONS]
```

#### Options:
- `-u, --username USER` - Username for config customization (default: current user)
- `-r, --repo URL` - Git repository URL for dotfiles (default: https://github.com/joao-paulo-santos/Arch.Config.git)
- `-s, --skip-dotfiles` - Skip dotfiles installation, only install packages
- `-h, --help` - Show help message

#### Examples:

```bash
# Use defaults (current user, default repo)
./installer.sh

# Install for specific user with custom repo
./installer.sh -u alice -r https://github.com/alice/dotfiles.git

# Only install packages, skip dotfiles
./installer.sh --skip-dotfiles

# Skip sleep scripts (for non-systemd systems like OpenRC, runit)
./installer.sh --skip-sleep-scripts

# Combine flags
./installer.sh --skip-dotfiles --skip-sleep-scripts

# Install for user 'bob' with default repo
./installer.sh -u bob
```

### Quick Install on Fresh Arch

On a fresh Arch Linux installation:

1. **Basic Arch Installation**: Complete the basic Arch installation (base system, bootloader, user account)

2. **Download and run installer**:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/joao-paulo-santos/Arch.Config/main/system-installer/installer.sh -o installer.sh
   chmod +x installer.sh
   ./installer.sh -u $(whoami)
   ```

3. **Reboot** and enjoy your restored system!

## What the Installer Does

The installer automatically:

1. **Updates the system**: `pacman -Syu`
2. **Installs all packages** organized by category
3. **Installs AUR packages** (installs yay if needed)
4. **Clones your dotfiles**: From your GitHub repository
5. **Sets up configurations**: 
   - Backs up existing `.config` (if any)
   - Replaces `.config` with your repository
   - Symlinks `.zshrc` from `.config/zsh/.zshrc`
   - Symlinks custom desktop entries
   - Makes all scripts executable
6. **Enables services**: NetworkManager, Bluetooth...
7. **Installs Oh My Zsh**: If not already present
8. **Changes default shell**: To zsh
9. **Creates directories**: Wallpapers, local bin, etc.

## What Gets Installed

The installer automatically categorizes and installs:

- **Hyprland/Wayland**: Window manager, status bar, launchers, wallpaper tools
- **Audio**: PipeWire, audio controls, volume managers
- **Graphics**: GPU drivers, graphics libraries
- **Development**: Git, code editors, programming languages, build tools
- **Terminal/CLI**: Terminal emulator, shell, CLI utilities
- **Fonts**: System fonts, icon fonts, Nerd Fonts
- **Network**: NetworkManager, wireless tools, SSH
- **AUR Packages**: Community packages via yay/paru
- **Other**: Everything else you had installed

## Customization

Edit `generate-installer.sh` to:
- Change the dotfiles repository URL
- Add new package categories
- Change categorization patterns
- Exclude certain packages
- Add post-installation scripts

## Re-generating

Run `./generate-installer.sh` whenever you:
- Install new packages you want to keep
- Want to update the installer with current system state
- Make changes to package categorization
- Update dotfiles repository settings

## Manual Steps After Installation

The installer now handles most setup automatically, but you may still want to:
- Configure Git credentials: `git config --global user.name/user.email`
- Set up SSH keys for GitHub/services
- Import browser bookmarks/settings
- Configure monitor-specific settings

## Sleep/Wake Scripts

The installer automatically sets up scripts that run when your system goes to sleep and wakes from sleep/suspend. 

### Wake Scripts (on-wake/)
These run after the system resumes and are useful for:
- Refreshing wallpapers
- Restarting services that might hang after suspend
- Updating system time and network connections
- Clearing stale lock files

### Pre-Sleep Scripts (on-sleep/)
These run before the system goes to sleep and are useful for:
- Saving session state and open applications
- Stopping services gracefully
- Syncing important data and history
- Preparing the system for sleep

**Locations**: 
- Wake scripts: `~/.config/system-installer/on-wake/`
- Pre-sleep scripts: `~/.config/system-installer/on-sleep/`

**Logs**: `/var/log/run-on-wake.log`

See [run-on-wake-README.md](run-on-wake-README.md) for complete documentation on adding your own scripts.