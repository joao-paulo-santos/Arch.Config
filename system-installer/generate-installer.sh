#!/bin/bash

# Generator script to create installer.sh from current system packages
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLER_FILE="$SCRIPT_DIR/installer.sh"
TEMP_INSTALLER="$SCRIPT_DIR/installer_temp.sh"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Generating installer script from current system...${NC}"

# Get explicitly installed packages (not dependencies)
echo "Extracting explicitly installed packages..."
EXPLICIT_PACKAGES=$(pacman -Qe | awk '{print $1}' | sort)

# Get AUR packages if yay/paru is available
AUR_PACKAGES=""
if command -v yay &> /dev/null; then
    echo "Detecting AUR packages via yay..."
    AUR_PACKAGES=$(yay -Qm | awk '{print $1}' | sort)
elif command -v paru &> /dev/null; then
    echo "Detecting AUR packages via paru..."
    AUR_PACKAGES=$(paru -Qm | awk '{print $1}' | sort)
fi

# Filter out AUR packages from explicit packages to avoid duplicates
OFFICIAL_PACKAGES=""
if [ -n "$AUR_PACKAGES" ]; then
    # Create temporary files for comparison
    echo "$EXPLICIT_PACKAGES" > /tmp/explicit_packages.txt
    echo "$AUR_PACKAGES" > /tmp/aur_packages.txt
    OFFICIAL_PACKAGES=$(comm -23 /tmp/explicit_packages.txt /tmp/aur_packages.txt)
    rm -f /tmp/explicit_packages.txt /tmp/aur_packages.txt
else
    OFFICIAL_PACKAGES="$EXPLICIT_PACKAGES"
fi

# Categorize packages (basic categorization)
categorize_packages() {
    local packages="$1"
    local category_name="$2"
    local pattern="$3"
    
    echo "$packages" | grep -E "$pattern" || true
}

# Extract package categories (using OFFICIAL_PACKAGES only, not AUR)
HYPRLAND_PACKAGES=$(echo "$OFFICIAL_PACKAGES" | grep -E "^(hypr.*|waybar|rofi|swww|swaybg|mpvpaper|satty|waytrogen)$" || true)
AUDIO_PACKAGES=$(echo "$OFFICIAL_PACKAGES" | grep -E "(pipewire|pulseaudio|alsa|pamixer|pavucontrol|wireplumber)" || true)
GRAPHICS_PACKAGES=$(echo "$OFFICIAL_PACKAGES" | grep -E "(nvidia|mesa|vulkan|intel-media-driver|gpu)" || true)
DEV_PACKAGES=$(echo "$OFFICIAL_PACKAGES" | grep -E "(^git$|^code$|^nvim$|^neovim$|nodejs|npm|python|gcc|make|cmake|base-devel)" || true)
TERMINAL_PACKAGES=$(echo "$OFFICIAL_PACKAGES" | grep -E "(kitty|alacritty|zsh|fish|tmux|htop|btop|neofetch|fastfetch)" || true)
FONT_PACKAGES=$(echo "$OFFICIAL_PACKAGES" | grep -E "(font|ttf-|noto|nerd)" || true)
NETWORK_PACKAGES=$(echo "$OFFICIAL_PACKAGES" | grep -E "(networkmanager|wifi|bluetooth|openssh)" || true)

# Remove categorized packages from the main list to avoid duplicates
REMAINING_PACKAGES=$(echo "$OFFICIAL_PACKAGES" | grep -vE "^(hypr.*|waybar|rofi|swww|swaybg|mpvpaper|satty|waytrogen|pipewire|pulseaudio|alsa|pamixer|pavucontrol|wireplumber|nvidia|mesa|vulkan|intel-media-driver|gpu|git|code|nvim|neovim|nodejs|npm|python|gcc|make|cmake|base-devel|kitty|alacritty|zsh|fish|tmux|htop|btop|neofetch|fastfetch|font|ttf-|noto|nerd|networkmanager|wifi|bluetooth|openssh)$" || echo "$OFFICIAL_PACKAGES")

# Start creating the installer script
cat > "$TEMP_INSTALLER" << 'EOF'
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

EOF

# Add package arrays to the installer
add_package_array() {
    local var_name="$1"
    local packages="$2"
    
    if [ -n "$packages" ]; then
        echo "" >> "$TEMP_INSTALLER"
        echo "# $var_name packages" >> "$TEMP_INSTALLER"
        echo -n "${var_name}_PACKAGES=(" >> "$TEMP_INSTALLER"
        echo "$packages" | tr '\n' ' ' | sed 's/ $//' >> "$TEMP_INSTALLER"
        echo ")" >> "$TEMP_INSTALLER"
    fi
}

# Add all package categories
add_package_array "HYPRLAND" "$HYPRLAND_PACKAGES"
add_package_array "AUDIO" "$AUDIO_PACKAGES"
add_package_array "GRAPHICS" "$GRAPHICS_PACKAGES"
add_package_array "DEV" "$DEV_PACKAGES"
add_package_array "TERMINAL" "$TERMINAL_PACKAGES"
add_package_array "FONT" "$FONT_PACKAGES"
add_package_array "NETWORK" "$NETWORK_PACKAGES"
add_package_array "OTHER" "$REMAINING_PACKAGES"

# Add AUR packages if any
if [ -n "$AUR_PACKAGES" ]; then
    echo "" >> "$TEMP_INSTALLER"
    echo "# AUR packages" >> "$TEMP_INSTALLER"
    echo -n "AUR_PACKAGES=(" >> "$TEMP_INSTALLER"
    echo "$AUR_PACKAGES" | tr '\n' ' ' | sed 's/ $//' >> "$TEMP_INSTALLER"
    echo ")" >> "$TEMP_INSTALLER"
fi

# Add installation commands
cat >> "$TEMP_INSTALLER" << 'EOF'

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
    
    # Clone the repository with submodules
    log_info "Cloning dotfiles from \$CONFIG_REPO"
    sudo -u "\$USERNAME" git clone --recurse-submodules "\$CONFIG_REPO" "\$CONFIG_DIR"
    
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
EOF

# Move temp file to final location
mv "$TEMP_INSTALLER" "$INSTALLER_FILE"
chmod +x "$INSTALLER_FILE"

echo -e "${GREEN}Installer script generated successfully!${NC}"
echo -e "${BLUE}Location: $INSTALLER_FILE${NC}"
echo ""
echo "Detected packages:"
echo "- Hyprland/Wayland: $(echo "$HYPRLAND_PACKAGES" | wc -w) packages"
echo "- Audio: $(echo "$AUDIO_PACKAGES" | wc -w) packages"
echo "- Graphics: $(echo "$GRAPHICS_PACKAGES" | wc -w) packages"
echo "- Development: $(echo "$DEV_PACKAGES" | wc -w) packages"
echo "- Terminal/CLI: $(echo "$TERMINAL_PACKAGES" | wc -w) packages"
echo "- Fonts: $(echo "$FONT_PACKAGES" | wc -w) packages"
echo "- Network: $(echo "$NETWORK_PACKAGES" | wc -w) packages"
echo "- Other: $(echo "$REMAINING_PACKAGES" | wc -w) packages"

if [ -n "$AUR_PACKAGES" ]; then
    echo "- AUR: $(echo "$AUR_PACKAGES" | wc -w) packages"
fi

echo ""
echo "Total explicitly installed packages: $(echo "$EXPLICIT_PACKAGES" | wc -w)"
echo ""
echo "Run './installer.sh' on a fresh Arch installation to restore your system."