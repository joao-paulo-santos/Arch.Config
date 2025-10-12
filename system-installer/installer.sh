#!/bin/bash

# Arch Linux System Installer Script
# Auto-generated from current system packages

set -e  # Exit on any error

# Default values
DEFAULT_CONFIG_REPO="https://github.com/joao-paulo-santos/Arch.Config.git"
DEFAULT_USERNAME="$USER"

# Parse command line arguments
CONFIG_REPO="$DEFAULT_CONFIG_REPO"
USERNAME="$DEFAULT_USERNAME"
SKIP_DOTFILES=false
SKIP_SLEEP_SCRIPTS=false

show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -u, --username USER     Username for config customization (default: current user)"
    echo "  -r, --repo URL          Git repository URL for dotfiles (default: $DEFAULT_CONFIG_REPO)"
    echo "  -s, --skip-dotfiles     Skip dotfiles installation, only install packages"
    echo "  --skip-sleep-scripts    Skip systemd sleep script installation (for non-systemd systems)"
    echo "  -h, --help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                                          # Use defaults"
    echo "  $0 -u myuser -r https://github.com/me/dotfiles.git"
    echo "  $0 --skip-dotfiles                         # Only install packages"
    echo "  $0 --skip-sleep-scripts                    # Skip sleep scripts (for non-systemd)"
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -u|--username)
            USERNAME="$2"
            shift 2
            ;;
        -r|--repo)
            CONFIG_REPO="$2"
            shift 2
            ;;
        -s|--skip-dotfiles)
            SKIP_DOTFILES=true
            shift
            ;;
        --skip-sleep-scripts)
            SKIP_SLEEP_SCRIPTS=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   log_error "This script should not be run as root"
   exit 1
fi

# Check if pacman is available
if ! command -v pacman &> /dev/null; then
    log_error "pacman not found. This script is for Arch Linux systems."
    exit 1
fi

log_info "Starting Arch Linux system installation for user: $USERNAME"
log_info "Dotfiles repository: $CONFIG_REPO"

# Update system first
log_info "Updating system packages..."
sudo pacman -Syu --noconfirm

# Function to install packages with error handling
install_packages() {
    local category="$1"
    shift
    local packages=("$@")
    
    if [ ${#packages[@]} -eq 0 ]; then
        log_warning "No packages found for $category"
        return
    fi
    
    log_info "Installing $category packages: ${packages[*]}"
    
    for package in "${packages[@]}"; do
        if pacman -Qi "$package" &>/dev/null; then
            log_warning "$package is already installed"
        else
            log_info "Installing $package..."
            if sudo pacman -S --noconfirm "$package"; then
                log_success "Successfully installed $package"
            else
                log_error "Failed to install $package"
            fi
        fi
    done
}

# Function to install AUR packages
install_aur_packages() {
    local category="$1"
    shift
    local packages=("$@")
    
    if [ ${#packages[@]} -eq 0 ]; then
        log_warning "No AUR packages found for $category"
        return
    fi
    
    # Check if AUR helper is available
    if command -v yay &> /dev/null; then
        AUR_HELPER="yay"
    elif command -v paru &> /dev/null; then
        AUR_HELPER="paru"
    else
        log_error "No AUR helper (yay/paru) found. Installing yay first..."
        # Install yay
        cd /tmp
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ..
        rm -rf yay
        AUR_HELPER="yay"
    fi
    
    log_info "Installing $category AUR packages using $AUR_HELPER: ${packages[*]}"
    
    for package in "${packages[@]}"; do
        if pacman -Qi "$package" &>/dev/null; then
            log_warning "$package is already installed"
        else
            log_info "Installing AUR package $package..."
            if $AUR_HELPER -S --noconfirm "$package"; then
                log_success "Successfully installed $package"
            else
                log_error "Failed to install AUR package $package"
            fi
        fi
    done
}


# HYPRLAND packages
HYPRLAND_PACKAGES=(hypridle hyprland hyprpaper hyprshot rofi rofi-calc satty swaybg swww waybar waytrogen)

# AUDIO packages
AUDIO_PACKAGES=(pavucontrol pipewire-pulse)

# GRAPHICS packages
GRAPHICS_PACKAGES=(nvidia-open nvidia-open-lts nvidia-settings nvidia-utils vulkan-tools)

# DEV packages
DEV_PACKAGES=(amd-ucode awakened-poe-trade-git base-devel git github-desktop-bin neovim nodejs npm visual-studio-code-bin)

# TERMINAL packages
TERMINAL_PACKAGES=(htop kitty zsh)

# FONT packages
FONT_PACKAGES=(noto-fonts-emoji ttf-jetbrains-mono-nerd ttf-liberation)

# NETWORK packages
NETWORK_PACKAGES=(networkmanager openssh)

# OTHER packages
OTHER_PACKAGES=(acpid base brave-bin brightnessctl ddcutil discord dolphin dotnet-sdk efibootmgr gnome-keyring gptfdisk jdk-openjdk jdk21-openjdk jq linux linux-firmware linux-lts linux-lts-headers man-db man-pages nano nm-connection-editor ntfs-3g parted reflector rtkit socat steam steam-native-runtime sudo swaync texinfo ufw usbutils wl-clipboard yay yay-debug)

# AUR packages
AUR_PACKAGES=(awakened-poe-trade-git brave-bin github-desktop-bin github-desktop-bin-debug swengine-debug visual-studio-code-bin waytrogen yay yay-debug)

# Install packages by category
if [ -n "${HYPRLAND_PACKAGES:-}" ]; then
    install_packages "Hyprland/Wayland" "${HYPRLAND_PACKAGES[@]}"
fi

if [ -n "${AUDIO_PACKAGES:-}" ]; then
    install_packages "Audio" "${AUDIO_PACKAGES[@]}"
fi

if [ -n "${GRAPHICS_PACKAGES:-}" ]; then
    install_packages "Graphics" "${GRAPHICS_PACKAGES[@]}"
fi

if [ -n "${NETWORK_PACKAGES:-}" ]; then
    install_packages "Network" "${NETWORK_PACKAGES[@]}"
fi

if [ -n "${DEV_PACKAGES:-}" ]; then
    install_packages "Development" "${DEV_PACKAGES[@]}"
fi

if [ -n "${TERMINAL_PACKAGES:-}" ]; then
    install_packages "Terminal/CLI" "${TERMINAL_PACKAGES[@]}"
fi

if [ -n "${FONT_PACKAGES:-}" ]; then
    install_packages "Fonts" "${FONT_PACKAGES[@]}"
fi

if [ -n "${OTHER_PACKAGES:-}" ]; then
    install_packages "Other" "${OTHER_PACKAGES[@]}"
fi

# Install AUR packages
if [ -n "${AUR_PACKAGES:-}" ]; then
    install_aur_packages "AUR" "${AUR_PACKAGES[@]}"
fi

log_success "Package installation completed!"

# Dotfiles installation
if [ "$SKIP_DOTFILES" = false ]; then
    log_info "Installing dotfiles configuration..."
    
    # Setup dotfiles
    CONFIG_DIR="/home/$USERNAME/.config"
    BACKUP_DIR="/home/$USERNAME/.config-backup-$(date +%Y%m%d-%H%M%S)"
    
    # Backup existing .config if it exists and is not empty
    if [ -d "$CONFIG_DIR" ] && [ "$(ls -A "$CONFIG_DIR" 2>/dev/null)" ]; then
        log_info "Backing up existing .config to $BACKUP_DIR"
        sudo -u "$USERNAME" mv "$CONFIG_DIR" "$BACKUP_DIR"
    fi
    
    # Clone the repository
    log_info "Cloning dotfiles from $CONFIG_REPO"
    sudo -u "$USERNAME" git clone "$CONFIG_REPO" "$CONFIG_DIR"
    
    # Set proper ownership
    chown -R "$USERNAME:$USERNAME" "$CONFIG_DIR"
    
    # Setup symlinks for configs that need to be in specific locations
    log_info "Setting up configuration symlinks..."
    
    # ZSH configuration
    if [ -f "$CONFIG_DIR/zsh/.zshrc" ]; then
        sudo -u "$USERNAME" ln -sf "$CONFIG_DIR/zsh/.zshrc" "/home/$USERNAME/.zshrc"
        log_success "Linked .zshrc"
    fi
    
    # Desktop entries for custom rofi flags
    if [ -d "$CONFIG_DIR/my-desktop-entries" ]; then
        sudo -u "$USERNAME" rm -rf "/home/$USERNAME/.local/share/applications"
        sudo -u "$USERNAME" ln -sfn "$CONFIG_DIR/my-desktop-entries" "/home/$USERNAME/.local/share/applications"
        log_success "Linked custom desktop entries"
    fi
    
    # Make scripts executable
    find "$CONFIG_DIR" -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null || true
    find "$CONFIG_DIR" -name "*.js" -type f -exec chmod +x {} \; 2>/dev/null || true
    
    # Set up additional user-specific configurations
    log_info "Setting up user-specific configurations for $USERNAME..."
    
    # Create standard user directories
    sudo -u "$USERNAME" mkdir -p "/home/$USERNAME/Pictures"
    sudo -u "$USERNAME" mkdir -p "/home/$USERNAME/Documents" 
    sudo -u "$USERNAME" mkdir -p "/home/$USERNAME/Downloads"
    sudo -u "$USERNAME" mkdir -p "/home/$USERNAME/.local/share"
    sudo -u "$USERNAME" mkdir -p "/home/$USERNAME/.local/bin"
    
    # Set up wallpaper directories
    if [ -d "$CONFIG_DIR/hypr" ]; then
        sudo -u "$USERNAME" mkdir -p "/home/$USERNAME/.config/hypr/bg/default"
        log_info "Created wallpaper directories"
    fi
    
    log_success "Dotfiles configuration completed!"
else
    log_info "Skipping dotfiles installation (--skip-dotfiles flag used)"
fi

# Post-installation setup
log_info "Running post-installation setup..."

# Enable important services
log_info "Enabling essential services..."
sudo systemctl enable NetworkManager 2>/dev/null || true
sudo systemctl enable bluetooth 2>/dev/null || true

# Set up wake-on-resume scripts
if [ "\$SKIP_SLEEP_SCRIPTS" = false ] && [ -f "/home/\$USERNAME/.config/system-installer/run-on-wake.sh" ]; then
    log_info "Setting up wake-on-resume script..."
    WAKE_SCRIPT_TARGET="/lib/systemd/system-sleep/run-on-wake.sh"
    WAKE_SCRIPT_SOURCE="/home/\$USERNAME/.config/system-installer/run-on-wake.sh"
    
    # Check if systemd sleep directory exists
    if [ ! -d "/lib/systemd/system-sleep" ]; then
        log_warning "systemd sleep directory not found - skipping sleep scripts (use --skip-sleep-scripts to silence this)"
    else
        # Create the symlink
        if sudo ln -sf "\$WAKE_SCRIPT_SOURCE" "\$WAKE_SCRIPT_TARGET" 2>/dev/null; then
            log_success "Wake-on-resume script installed"
            
            # Make on-wake and on-sleep scripts executable
            for script_dir in "on-wake" "on-sleep"; do
                if [ -d "/home/\$USERNAME/.config/system-installer/\$script_dir" ]; then
                    find "/home/\$USERNAME/.config/system-installer/\$script_dir" -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null || true
                    script_count=\$(find "/home/\$USERNAME/.config/system-installer/\$script_dir" -name "*.sh" -type f | wc -l)
                    log_info "Made \$script_count \$script_dir scripts executable"
                fi
            done
        else
            log_warning "Failed to install wake-on-resume script (requires sudo)"
        fi
    fi
elif [ "\$SKIP_SLEEP_SCRIPTS" = true ]; then
    log_info "Skipping sleep scripts installation (--skip-sleep-scripts flag used)"
fi

# Install oh-my-zsh if zsh is being used and .zshrc references it
if [ -f "/home/$USERNAME/.zshrc" ] && grep -q "oh-my-zsh" "/home/$USERNAME/.zshrc" 2>/dev/null; then
    if [ ! -d "/home/$USERNAME/.oh-my-zsh" ]; then
        log_info "Installing oh-my-zsh for $USERNAME..."
        sudo -u "$USERNAME" sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        log_success "oh-my-zsh installed"
    fi
fi

# Set zsh as default shell if installed
if command -v zsh &> /dev/null; then
    if [ "$(getent passwd "$USERNAME" | cut -d: -f7)" != "/usr/bin/zsh" ]; then
        log_info "Setting zsh as default shell for $USERNAME..."
        sudo chsh -s /usr/bin/zsh "$USERNAME"
        log_success "Default shell set to zsh"
    fi
fi

log_success "System installation completed!"
log_info "Configuration installed for user: $USERNAME"
log_info "Dotfiles repository: $CONFIG_REPO"
echo ""
log_info "Next steps:"
echo "  1. Reboot your system"
echo "  2. Log in as $USERNAME"
echo "  3. Start Hyprland from TTY1"
echo "  4. Enjoy your configured Arch Linux system!"
echo ""
if [ "$SKIP_DOTFILES" = false ]; then
    echo "Your dotfiles have been cloned to ~/.config"
    if [ -d "$BACKUP_DIR" ]; then
        echo "Backup of previous config: $BACKUP_DIR"
    fi
fi
