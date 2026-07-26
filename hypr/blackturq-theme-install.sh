#!/bin/bash
# ────────────────────────────────────────────────────────────
# Blackturq Theme Installer for Arch Linux
# Based on: https://github.com/HANCORE-linux/omarchy-blackturq-theme
# ────────────────────────────────────────────────────────────

THEME_DIR="/home/valve/omarchy-blackturq-theme"

echo "=== Blackturq Theme Installer ==="
echo ""

# Colors
ACCENT="#8FECD5"
BG="#0a0a0a"

# Check and install for each app
install_discord_theme() {
    if command -v vesktop &>/dev/null || command -v discord &>/dev/null; then
        echo "[+] Installing Vencord/Discord theme..."
        VENCORD_DIR="$HOME/.config/vesktop/themes"
        mkdir -p "$VENCORD_DIR"
        cp "$THEME_DIR/vencord.theme.css" "$VENCORD_DIR/"
        cp "$THEME_DIR/system24-blackturq.theme.css" "$VENCORD_DIR/"
        echo "    Vencord theme installed at $VENCORD_DIR"
    else
        echo "[-] Vesktop/Discord not found. Install with: yay -S vesktop"
    fi
}

install_steam_theme() {
    if command -v steam &>/dev/null || [ -d "$HOME/.steam" ]; then
        echo "[+] Installing Steam theme (Adwaita-for-Steam)..."
        STEAM_DIR="$HOME/.steam/steam"
        SKIN_DIR="$STEAM_DIR/skins"
        mkdir -p "$SKIN_DIR"
        # Note: Steam skin requires Adwaita-for-Steam as base
        # Copy the CSS override
        cp "$THEME_DIR/steam.css" "$SKIN_DIR/blackturq-steam.css"
        echo "    Steam CSS override saved. You may need Adwaita-for-Steam skin."
    else
        echo "[-] Steam not found. Install with: pacman -S steam"
    fi
}

install_heroic_theme() {
    if command -v heroic &>/dev/null || [ -d "$HOME/.config/heroic" ]; then
        echo "[+] Installing Heroic Games Launcher theme..."
        HEROIC_DIR="$HOME/.config/heroic"
        mkdir -p "$HEROIC_DIR"
        cp "$THEME_DIR/heroic.css" "$HEROIC_DIR/blackturq.css"
        echo "    Heroic theme installed. Enable it in Heroic Settings > Appearance."
    else
        echo "[-] Heroic Games Launcher not found. Install with: yay -S heroic-games-launcher-bin"
    fi
}

install_neovim_theme() {
    if command -v nvim &>/dev/null; then
        echo "[+] Installing Neovim theme (aether.nvim)..."
        NVIM_DIR="$HOME/.config/nvim/lua/plugins"
        mkdir -p "$NVIM_DIR"
        cp "$THEME_DIR/neovim.lua" "$NVIM_DIR/blackturq-theme.lua"
        echo "    Neovim theme config saved. Requires LazyVim + aether.nvim plugin."
    else
        echo "[-] Neovim not found. Install with: pacman -S neovim"
    fi
}

install_cava_theme() {
    if command -v cava &>/dev/null; then
        echo "[+] Cava theme already installed at ~/.config/cava/config"
    else
        echo "[-] Cava not found. Install with: pacman -S cava"
    fi
}

install_walker_theme() {
    if command -v walker &>/dev/null; then
        echo "[+] Walker theme already installed at ~/.config/walker/style.css"
    else
        echo "[-] Walker not found. Install with: yay -S walker"
    fi
}

install_hyprlock_theme() {
    if command -v hyprlock &>/dev/null; then
        echo "[+] Hyprlock theme already installed at ~/.config/hypr/hyprlock.conf"
    else
        echo "[-] Hyprlock not found. Install with: pacman -S hyprlock"
    fi
}

install_icon_theme() {
    if [ -d "/usr/share/icons/Yaru-sage" ] || [ -d "$HOME/.local/share/icons/Yaru-sage" ]; then
        echo "[+] Yaru-sage icon theme is installed."
    else
        echo "[-] Yaru-sage icon theme not found."
        echo "    Install from AUR: yay -S yaru-sage-icon-theme"
        echo "    Or use breeze-icons (already installed) as alternative."
    fi
}

# Menu
echo "Select what to install:"
echo "  1) Discord/Vesktop theme"
echo "  2) Steam theme"
echo "  3) Heroic Games Launcher theme"
echo "  4) Neovim theme"
echo "  5) Check icon theme (Yaru-sage)"
echo "  6) Install ALL available"
echo "  0) Exit"
echo ""
read -p "Choice: " choice

case $choice in
    1) install_discord_theme ;;
    2) install_steam_theme ;;
    3) install_heroic_theme ;;
    4) install_neovim_theme ;;
    5) install_icon_theme ;;
    6)
        install_discord_theme
        install_steam_theme
        install_heroic_theme
        install_neovim_theme
        install_cava_theme
        install_walker_theme
        install_hyprlock_theme
        install_icon_theme
        ;;
    0) echo "Bye!" ; exit 0 ;;
    *) echo "Invalid choice" ; exit 1 ;;
esac

echo ""
echo "=== Done! ==="
