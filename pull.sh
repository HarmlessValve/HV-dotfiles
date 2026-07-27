#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════════╗
# ║              HV-dotfiles — Pull Script                          ║
# ║  Updates the local HV-dotfiles repository with the active       ║
# ║  system configurations. Run this before committing to git!       ║
# ╚══════════════════════════════════════════════════════════════════╝

set -euo pipefail

# ─────────────────────────────────────────────
#  COLORS & ICONS
# ─────────────────────────────────────────────
RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"

GREEN="\033[0;32m"
YELLOW="\033[0;33m"
CYAN="\033[0;36m"
RED="\033[0;31m"
BRIGHT_CYAN="\033[1;36m"
BRIGHT_GREEN="\033[1;32m"
BRIGHT_YELLOW="\033[1;33m"
BRIGHT_RED="\033[1;31m"
BRIGHT_WHITE="\033[1;37m"

ICON_OK="✓"
ICON_ERR="✗"
ICON_INFO="•"
ICON_WARN="⚠"
ICON_PULL="⬇"

print_header() {
    echo ""
    echo -e "${BRIGHT_CYAN}${BOLD}╔══════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${BRIGHT_CYAN}${BOLD}║          HV-dotfiles Updater (Local → Repo)              ║${RESET}"
    echo -e "${BRIGHT_CYAN}${BOLD}╚══════════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

print_section() {
    echo ""
    echo -e "${BRIGHT_CYAN}${BOLD}┌─ $1 ${RESET}"
}

ok()   { echo -e "  ${BRIGHT_GREEN}${ICON_OK}${RESET}  $1"; }
warn() { echo -e "  ${BRIGHT_YELLOW}${ICON_WARN}${RESET}  $1"; }

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

# Directories in ~/.config/
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

# Files in ~/.config/
CONFIG_FILES=(
    "starship.toml"
    "kdeglobals"
)

pull_configs() {
    print_section "${ICON_PULL} Pulling configs from ~/.config"

    # Pull directories
    for item in "${CONFIG_ITEMS[@]}"; do
        local src="$CONFIG_DIR/$item"
        local dst="$DOTFILES_DIR/$item"

        if [ -d "$src" ]; then
            # Delete destination directory to ensure clean sync if files were removed
            rm -rf "$dst"
            cp -r "$src" "$dst"
            ok "Pulled directory: ${item}"
        else
            warn "Source not found: $src — skipping"
        fi
    done

    # Pull single files
    for file in "${CONFIG_FILES[@]}"; do
        local src="$CONFIG_DIR/$file"
        local dst="$DOTFILES_DIR/$file"

        if [ -f "$src" ]; then
            cp "$src" "$dst"
            ok "Pulled file: ${file}"
        else
            warn "Source not found: $src — skipping"
        fi
    done
}

pull_themes() {
    print_section "${ICON_PULL} Pulling themes"

    # KDE Color Scheme
    local kde_src="$HOME/.local/share/color-schemes/Blackturq.colors"
    local kde_dst="$DOTFILES_DIR/color-schemes/Blackturq.colors"
    if [ -f "$kde_src" ]; then
        mkdir -p "$(dirname "$kde_dst")"
        cp "$kde_src" "$kde_dst"
        ok "Pulled KDE color scheme: Blackturq.colors"
    else
        warn "KDE color scheme not found locally — skipping"
    fi

    # GTK Theme
    local gtk_src="$HOME/.local/share/themes/Blackturq"
    local gtk_dst="$DOTFILES_DIR/themes/Blackturq"
    if [ -d "$gtk_src" ]; then
        rm -rf "$gtk_dst"
        mkdir -p "$(dirname "$gtk_dst")"
        cp -r "$gtk_src" "$gtk_dst"
        ok "Pulled GTK theme: Blackturq"
    else
        warn "GTK theme not found locally — skipping"
    fi
}

main() {
    print_header

    echo -e "  ${BRIGHT_CYAN}Source:${RESET} Active system configurations"
    echo -e "  ${BRIGHT_CYAN}Target:${RESET} ${DIM}${DOTFILES_DIR}${RESET}"
    echo ""

    # Confirm before proceeding
    echo -ne "  ${BRIGHT_YELLOW}Pull active configurations into the repository? [y/N] ${RESET}"
    read -r confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "  ${RED}Pull cancelled.${RESET}"
        exit 0
    fi

    pull_configs
    pull_themes

    echo ""
    echo -e "${BRIGHT_GREEN}${BOLD}╔══════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${BRIGHT_GREEN}${BOLD}║   ✓  Pull complete! You can now commit your changes.     ║${RESET}"
    echo -e "${BRIGHT_GREEN}${BOLD}╚══════════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

main "$@"
