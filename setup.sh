#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════════╗
# ║              HV-dotfiles — Setup Script                         ║
# ║  Arch Linux minimal → Hyprland desktop (Blackturq theme)        ║
# ║  Usage:                                                          ║
# ║    ./setup.sh          → Copy mode (copy files to ~/.config)    ║
# ║    ./setup.sh --symlink → Symlink mode (symlink to dotfiles dir) ║
# ╚══════════════════════════════════════════════════════════════════╝

set -euo pipefail

# ─────────────────────────────────────────────
#  COLORS & ICONS
# ─────────────────────────────────────────────
RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"

BLACK="\033[0;30m"
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
CYAN="\033[0;36m"
WHITE="\033[0;37m"
BRIGHT_CYAN="\033[1;36m"
BRIGHT_GREEN="\033[1;32m"
BRIGHT_YELLOW="\033[1;33m"
BRIGHT_RED="\033[1;31m"
BRIGHT_WHITE="\033[1;37m"

BG_DARK="\033[48;2;10;10;10m"

ICON_OK="✓"
ICON_ERR="✗"
ICON_INFO="•"
ICON_WARN="⚠"
ICON_ARROW="→"
ICON_PKG="📦"
ICON_CFG="⚙"
ICON_LINK="🔗"
ICON_COPY="📋"
ICON_BACK="💾"

# ─────────────────────────────────────────────
#  LOGGING HELPERS
# ─────────────────────────────────────────────
step_total=0
step_current=0

print_header() {
    echo ""
    echo -e "${BRIGHT_CYAN}${BOLD}╔══════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${BRIGHT_CYAN}${BOLD}║          HV-dotfiles Installer — Blackturq Theme         ║${RESET}"
    echo -e "${BRIGHT_CYAN}${BOLD}║            Arch Linux Minimal → Hyprland Desktop         ║${RESET}"
    echo -e "${BRIGHT_CYAN}${BOLD}╚══════════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

print_section() {
    echo ""
    echo -e "${BRIGHT_CYAN}${BOLD}┌─ $1 ${RESET}"
}

print_step() {
    step_current=$((step_current + 1))
    local pct=$(( step_current * 100 / step_total ))
    local filled=$(( pct / 5 ))
    local bar=""
    for ((i=0; i<20; i++)); do
        if [ $i -lt $filled ]; then
            bar="${bar}█"
        else
            bar="${bar}░"
        fi
    done
    echo -e "${DIM}  [${bar}] ${pct}%${RESET}  ${BRIGHT_WHITE}$1${RESET}"
}

ok()   { echo -e "  ${BRIGHT_GREEN}${ICON_OK}${RESET}  $1"; }
err()  { echo -e "  ${BRIGHT_RED}${ICON_ERR}${RESET}  $1"; }
info() { echo -e "  ${CYAN}${ICON_INFO}${RESET}  $1"; }
warn() { echo -e "  ${BRIGHT_YELLOW}${ICON_WARN}${RESET}  $1"; }

print_done() {
    echo ""
    echo -e "${BRIGHT_GREEN}${BOLD}╔══════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${BRIGHT_GREEN}${BOLD}║   ✓  Setup complete! Reboot or re-login to apply.        ║${RESET}"
    echo -e "${BRIGHT_GREEN}${BOLD}╚══════════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

# ─────────────────────────────────────────────
#  ARGUMENTS
# ─────────────────────────────────────────────
DEPLOY_MODE="copy"  # default: copy
if [[ "${1:-}" == "--symlink" ]]; then
    DEPLOY_MODE="symlink"
fi

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config.bak"
BACKUP_TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

# ─────────────────────────────────────────────
#  PACKAGE LISTS
# ─────────────────────────────────────────────

# Packages available in official Arch repos
PACMAN_PACKAGES=(
    # Hyprland & Wayland stack
    hyprland
    hyprutils
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    wayland
    wayland-protocols
    wlroots
    qt5-wayland
    qt6-wayland

    # Display / GPU (common - user may need to adjust for their GPU)
    mesa

    # Status bar
    waybar

    # Notifications
    mako
    libnotify

    # Screenshot
    grim
    slurp
    swappy

    # Clipboard
    wl-clipboard
    cliphist

    # Audio (PipeWire stack)
    pipewire
    pipewire-audio
    pipewire-alsa
    pipewire-pulse
    wireplumber

    # Bluetooth
    bluez
    bluez-utils

    # Brightness control
    brightnessctl

    # Media control
    playerctl

    # Network
    networkmanager

    # Fonts
    noto-fonts
    noto-fonts-emoji
    noto-fonts-cjk
    ttf-dejavu
    ttf-liberation
    fontconfig

    # GTK theming
    gtk3
    gtk4
    gnome-themes-extra
    adwaita-icon-theme

    # Terminal emulators
    ghostty

    # File manager
    dolphin

    # Tools
    btop
    htop
    fastfetch
    cava
    starship
    zsh
    zsh-completions
    zsh-autosuggestions
    zsh-syntax-highlighting
    git
    curl
    wget
    unzip
    ripgrep
    fd
    jq
    fzf
    imagemagick

    # Polkit (needed for privilege escalation in GUI)
    polkit
    polkit-kde-agent

    # SwayOSD (OSD for volume/brightness)
    swayosd

    # Hypr ecosystem tools
    hyprlock
    hypridle
    hyprpicker
)

# Packages from AUR
AUR_PACKAGES=(
    # Nerd Fonts
    ttf-jetbrains-mono-nerd
    ttf-nerd-fonts-symbols
    ttf-nerd-fonts-symbols-common

    # Wallpaper daemon (awww - swww fork used in config)
    awww-bin

    # Walker app launcher
    walker-bin

    # Kitty terminal
    kitty

    # Extra Hypr tools
    hyprlauncher
    hyprshot

    # Starship prompt (if not in pacman for your version)
    # starship  # already in pacman, keep as fallback comment

    # Additional themes
    catppuccin-gtk-theme-mocha
)

# ─────────────────────────────────────────────
#  CONFIG DIRECTORIES TO DEPLOY
# ─────────────────────────────────────────────
CONFIG_ITEMS=(
    "hypr"
    "waybar"
    "kitty"
    "ghostty"
    "mako"
    "walker"
    "cava"
    "btop"
    "fastfetch"
    "swayosd"
    "gtk-3.0"
    "gtk-4.0"
    "htop"
)

# Single-file configs (sit directly in ~/.config/)
CONFIG_FILES=(
    "starship.toml"
    "kdeglobals"
)

# ─────────────────────────────────────────────
#  STEP COUNTER CALCULATION
# ─────────────────────────────────────────────
step_total=$(( 3 + ${#CONFIG_ITEMS[@]} + ${#CONFIG_FILES[@]} ))

# ─────────────────────────────────────────────
#  PREREQUISITE CHECKS
# ─────────────────────────────────────────────
check_arch() {
    if ! command -v pacman &>/dev/null; then
        err "pacman not found. This script is for Arch Linux only."
        exit 1
    fi
    ok "Arch Linux detected"
}

check_not_root() {
    if [ "$EUID" -eq 0 ]; then
        err "Do not run this script as root! Use a normal user account."
        exit 1
    fi
    ok "Not root — safe to proceed"
}

check_internet() {
    if ! ping -c 1 archlinux.org &>/dev/null; then
        err "No internet connection. Make sure your network is active."
        exit 1
    fi
    ok "Internet connection available"
}

# ─────────────────────────────────────────────
#  YAY INSTALLATION
# ─────────────────────────────────────────────
install_yay() {
    if command -v yay &>/dev/null; then
        ok "yay is already installed ($(yay --version | head -1))"
        return
    fi

    info "Installing yay (AUR helper)..."

    local tmp_dir
    tmp_dir="$(mktemp -d)"
    trap "rm -rf $tmp_dir" EXIT

    sudo pacman -S --needed --noconfirm git base-devel

    git clone https://aur.archlinux.org/yay.git "$tmp_dir/yay"
    (cd "$tmp_dir/yay" && makepkg -si --noconfirm)

    if command -v yay &>/dev/null; then
        ok "yay installed successfully"
    else
        err "Failed to install yay. Install it manually and re-run the script."
        exit 1
    fi
}

# ─────────────────────────────────────────────
#  PACKAGE INSTALLATION
# ─────────────────────────────────────────────
install_pacman_packages() {
    print_section "${ICON_PKG} Installing packages from Pacman"

    info "Updating pacman database..."
    sudo pacman -Syu --noconfirm

    local failed=()
    for pkg in "${PACMAN_PACKAGES[@]}"; do
        if pacman -Qi "$pkg" &>/dev/null; then
            echo -e "    ${DIM}${ICON_OK} $pkg (already installed)${RESET}"
        else
            if sudo pacman -S --needed --noconfirm "$pkg" 2>/dev/null; then
                echo -e "    ${GREEN}${ICON_OK} $pkg${RESET}"
            else
                echo -e "    ${YELLOW}${ICON_WARN} $pkg (not found in official repos — will try via AUR)${RESET}"
                failed+=("$pkg")
            fi
        fi
    done

    # Add failed pacman packages to AUR list
    AUR_PACKAGES+=("${failed[@]}")
}

install_aur_packages() {
    print_section "${ICON_PKG} Installing packages from AUR"

    local failed=()
    for pkg in "${AUR_PACKAGES[@]}"; do
        if pacman -Qi "$pkg" &>/dev/null; then
            echo -e "    ${DIM}${ICON_OK} $pkg (already installed)${RESET}"
        else
            if yay -S --needed --noconfirm "$pkg" 2>/dev/null; then
                echo -e "    ${GREEN}${ICON_OK} $pkg${RESET}"
            else
                echo -e "    ${YELLOW}${ICON_WARN} $pkg (failed to install)${RESET}"
                failed+=("$pkg")
            fi
        fi
    done

    if [ ${#failed[@]} -gt 0 ]; then
        warn "The following packages failed to install: ${failed[*]}"
        warn "Install them manually if needed."
    fi
}

# ─────────────────────────────────────────────
#  SHELL SETUP
# ─────────────────────────────────────────────
setup_zsh() {
    print_section "🐚 Configuring Zsh + Starship"

    local current_shell
    current_shell="$(getent passwd "$USER" | cut -d: -f7)"

    if [[ "$current_shell" != "$(which zsh)" ]]; then
        info "Changing default shell to zsh..."
        chsh -s "$(which zsh)"
        ok "Shell changed to zsh (takes effect after logout/reboot)"
    else
        ok "Zsh is already the default shell"
    fi

    # Create minimal .zshrc if it doesn't exist
    if [ ! -f "$HOME/.zshrc" ]; then
        info "Creating ~/.zshrc..."
        cat > "$HOME/.zshrc" << 'ZSHRC'
# ── HV-dotfiles .zshrc ──────────────────────────────────────────────

# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY

# Completions
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select

# Plugins (if installed via pacman)
[[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

[[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Aliases
alias ls='ls --color=auto'
alias ll='ls -lah'
alias la='ls -A'
alias grep='grep --color=auto'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias ..='cd ..'
alias ...='cd ../..'
alias cls='clear'
alias update='yay -Syu'

# Environment
export EDITOR='nano'
export VISUAL='nano'
export TERMINAL='ghostty'
export BROWSER='firefox'

# Wayland
export WAYLAND_DISPLAY=wayland-0
export XDG_SESSION_TYPE=wayland

# Starship prompt
eval "$(starship init zsh)"
ZSHRC
        ok "~/.zshrc created"
    else
        # Add starship init if not already present
        if ! grep -q "starship init zsh" "$HOME/.zshrc"; then
            echo '' >> "$HOME/.zshrc"
            echo '# Starship prompt' >> "$HOME/.zshrc"
            echo 'eval "$(starship init zsh)"' >> "$HOME/.zshrc"
            ok "Starship init appended to .zshrc"
        else
            ok ".zshrc already exists and starship is configured"
        fi
    fi
}

# ─────────────────────────────────────────────
#  BACKUP HELPER
# ─────────────────────────────────────────────
backup_if_exists() {
    local target="$1"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        local backup_path="${BACKUP_DIR}/${BACKUP_TIMESTAMP}/$(basename "$target")"
        mkdir -p "$(dirname "$backup_path")"
        mv "$target" "$backup_path"
        warn "Backed up: $(basename "$target") → ~/.config.bak/${BACKUP_TIMESTAMP}/"
    elif [ -L "$target" ]; then
        # Remove existing symlink
        rm "$target"
    fi
}

# ─────────────────────────────────────────────
#  DEPLOY CONFIGS
# ─────────────────────────────────────────────
deploy_configs() {
    print_section "${ICON_CFG} Deploying configs to ~/.config"

    mkdir -p "$CONFIG_DIR"

    local mode_icon
    mode_icon=$( [[ "$DEPLOY_MODE" == "symlink" ]] && echo "$ICON_LINK" || echo "$ICON_COPY" )
    info "Mode: ${DEPLOY_MODE} ${mode_icon}"
    echo ""

    # Deploy directories
    for item in "${CONFIG_ITEMS[@]}"; do
        local src="$DOTFILES_DIR/$item"
        local dst="$CONFIG_DIR/$item"

        print_step "${item}"

        if [ ! -e "$src" ]; then
            warn "Source not found: $src — skipping"
            continue
        fi

        backup_if_exists "$dst"

        if [[ "$DEPLOY_MODE" == "symlink" ]]; then
            ln -sf "$src" "$dst"
            ok "Symlink: ~/.config/${item} ${ICON_ARROW} ${src}"
        else
            cp -r "$src" "$dst"
            ok "Copy: ~/.config/${item}"
        fi
    done

    # Deploy single files
    for file in "${CONFIG_FILES[@]}"; do
        local src="$DOTFILES_DIR/$file"
        local dst="$CONFIG_DIR/$file"

        print_step "${file}"

        if [ ! -e "$src" ]; then
            warn "Source not found: $src — skipping"
            continue
        fi

        backup_if_exists "$dst"

        if [[ "$DEPLOY_MODE" == "symlink" ]]; then
            ln -sf "$src" "$dst"
            ok "Symlink: ~/.config/${file} ${ICON_ARROW} ${src}"
        else
            cp "$src" "$dst"
            ok "Copy: ~/.config/${file}"
        fi
    done
}

# ─────────────────────────────────────────────
#  KDE COLOR SCHEME DEPLOY
# ─────────────────────────────────────────────
deploy_kde_theme() {
    print_section "🎨 Installing Blackturq KDE color scheme"
    local scheme_src="$DOTFILES_DIR/color-schemes/Blackturq.colors"
    local scheme_dst="$HOME/.local/share/color-schemes/Blackturq.colors"

    if [ ! -f "$scheme_src" ]; then
        warn "Color scheme source not found: $scheme_src — skipping"
        return
    fi

    mkdir -p "$HOME/.local/share/color-schemes"

    if [[ "$DEPLOY_MODE" == "symlink" ]]; then
        ln -sf "$scheme_src" "$scheme_dst"
        ok "Symlink: ~/.local/share/color-schemes/Blackturq.colors"
    else
        cp "$scheme_src" "$scheme_dst"
        ok "Installed: ~/.local/share/color-schemes/Blackturq.colors"
    fi

    # Reload KDE color scheme if plasma is running
    if command -v plasma-apply-colorscheme &>/dev/null; then
        plasma-apply-colorscheme Blackturq 2>/dev/null && ok "Color scheme applied to Plasma" || true
    elif command -v dbus-send &>/dev/null; then
        dbus-send --session --dest=org.kde.KWin /KWin org.kde.KWin.reloadConfig 2>/dev/null || true
        ok "KWin config reloaded"
    fi

    info "Restart Dolphin to see the new theme."
}

# ─────────────────────────────────────────────
#  GTK THEME DEPLOY
# ─────────────────────────────────────────────
deploy_gtk_theme() {
    print_section "🎨 Installing Blackturq GTK theme (for Electron/GTK apps)"
    local theme_src="$DOTFILES_DIR/themes/Blackturq"
    local theme_dst="$HOME/.local/share/themes/Blackturq"

    if [ ! -d "$theme_src" ]; then
        warn "GTK theme source not found: $theme_src — skipping"
        return
    fi

    mkdir -p "$HOME/.local/share/themes"

    if [[ "$DEPLOY_MODE" == "symlink" ]]; then
        ln -sf "$theme_src" "$theme_dst"
        ok "Symlink: ~/.local/share/themes/Blackturq"
    else
        cp -r "$theme_src" "$theme_dst"
        ok "Installed: ~/.local/share/themes/Blackturq"
    fi

    # Apply via gsettings (works for all GTK apps including Electron IDEs)
    if command -v gsettings &>/dev/null; then
        gsettings set org.gnome.desktop.interface gtk-theme 'Blackturq' 2>/dev/null && \
            ok "GTK theme set via gsettings: Blackturq"
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null && \
            ok "Color scheme set: prefer-dark"
        gsettings set org.gnome.desktop.interface icon-theme 'breeze-dark' 2>/dev/null || true
    else
        warn "gsettings not found — GTK theme applied via settings.ini only"
        info "Install glib2 or libglib2.0-bin to enable gsettings support."
    fi

    info "Re-open any Electron app (e.g., IDE) to see the updated file dialog."
}

# ─────────────────────────────────────────────
#  POST-INSTALL NOTES
# ─────────────────────────────────────────────
print_notes() {
    echo ""
    echo -e "${BRIGHT_CYAN}${BOLD}┌─ Important Notes ────────────────────────────────────────┐${RESET}"
    echo -e "${BRIGHT_CYAN}│${RESET}"
    echo -e "${BRIGHT_CYAN}│${RESET}  ${BRIGHT_WHITE}Services to enable manually:${RESET}"
    echo -e "${BRIGHT_CYAN}│${RESET}  ${CYAN}  sudo systemctl enable --now NetworkManager${RESET}"
    echo -e "${BRIGHT_CYAN}│${RESET}  ${CYAN}  sudo systemctl enable --now bluetooth${RESET}"
    echo -e "${BRIGHT_CYAN}│${RESET}  ${CYAN}  systemctl --user enable --now pipewire.service${RESET}"
    echo -e "${BRIGHT_CYAN}│${RESET}  ${CYAN}  systemctl --user enable --now pipewire-pulse.service${RESET}"
    echo -e "${BRIGHT_CYAN}│${RESET}  ${CYAN}  systemctl --user enable --now wireplumber.service${RESET}"
    echo -e "${BRIGHT_CYAN}│${RESET}"
    echo -e "${BRIGHT_CYAN}│${RESET}  ${BRIGHT_WHITE}Wallpaper:${RESET}"
    echo -e "${BRIGHT_CYAN}│${RESET}  ${CYAN}  The ~/Pictures/backgrounds/ folder was created automatically.${RESET}"
    echo -e "${BRIGHT_CYAN}│${RESET}  ${CYAN}  Place your wallpaper at ~/Pictures/backgrounds/omarchy-wp.png${RESET}"
    echo -e "${BRIGHT_CYAN}│${RESET}"
    echo -e "${BRIGHT_CYAN}│${RESET}  ${BRIGHT_WHITE}GPU Driver (choose based on your hardware):${RESET}"
    echo -e "${BRIGHT_CYAN}│${RESET}  ${CYAN}  NVIDIA  → sudo pacman -S nvidia nvidia-utils${RESET}"
    echo -e "${BRIGHT_CYAN}│${RESET}  ${CYAN}  AMD     → sudo pacman -S xf86-video-amdgpu vulkan-radeon${RESET}"
    echo -e "${BRIGHT_CYAN}│${RESET}  ${CYAN}  Intel   → sudo pacman -S xf86-video-intel vulkan-intel${RESET}"
    echo -e "${BRIGHT_CYAN}│${RESET}"
    echo -e "${BRIGHT_CYAN}│${RESET}  ${BRIGHT_WHITE}Login Manager (optional):${RESET}"
    echo -e "${BRIGHT_CYAN}│${RESET}  ${CYAN}  yay -S sddm && sudo systemctl enable sddm${RESET}"
    echo -e "${BRIGHT_CYAN}│${RESET}"
    if [ -d "$BACKUP_DIR/$BACKUP_TIMESTAMP" ]; then
    echo -e "${BRIGHT_CYAN}│${RESET}  ${BRIGHT_YELLOW}${ICON_BACK} Old config backed up to:${RESET}"
    echo -e "${BRIGHT_CYAN}│${RESET}  ${YELLOW}    ~/.config.bak/${BACKUP_TIMESTAMP}/${RESET}"
    echo -e "${BRIGHT_CYAN}│${RESET}"
    fi
    echo -e "${BRIGHT_CYAN}└──────────────────────────────────────────────────────────┘${RESET}"
    echo ""
}

# ─────────────────────────────────────────────
#  WALLPAPER DIRECTORY SETUP
# ─────────────────────────────────────────────
setup_wallpaper_dir() {
    print_section "🖼  Setting up wallpaper directory"
    local wallpaper_dir="$HOME/Pictures/backgrounds"
    if [ -d "$wallpaper_dir" ]; then
        ok "Directory already exists: ~/Pictures/backgrounds/"
    else
        mkdir -p "$wallpaper_dir"
        ok "Directory created: ~/Pictures/backgrounds/"
    fi
    info "Place your wallpaper at: ${DIM}${wallpaper_dir}/omarchy-wp.png${RESET}"
}

# ─────────────────────────────────────────────
#  MAIN
# ─────────────────────────────────────────────
main() {
    print_header

    echo -e "  ${BRIGHT_CYAN}Deploy mode:${RESET} ${BOLD}${DEPLOY_MODE}${RESET}"
    echo -e "  ${BRIGHT_CYAN}Dotfiles dir:${RESET} ${DIM}${DOTFILES_DIR}${RESET}"
    echo -e "  ${BRIGHT_CYAN}Target:${RESET} ${DIM}${CONFIG_DIR}${RESET}"
    echo ""

    # Confirm before proceeding
    echo -ne "  ${BRIGHT_YELLOW}Proceed with installation? [y/N] ${RESET}"
    read -r confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "  ${RED}Installation cancelled.${RESET}"
        exit 0
    fi

    print_section "🔍 Checking prerequisites"
    check_not_root
    check_arch
    check_internet

    install_yay

    install_pacman_packages

    install_aur_packages

    print_section "🐚 Shell setup"
    setup_zsh

    setup_wallpaper_dir

    deploy_kde_theme

    deploy_gtk_theme

    deploy_configs

    print_done
    print_notes
}

main "$@"
