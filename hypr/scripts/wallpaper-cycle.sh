#!/bin/bash
# Wallpaper cycler for awww (swww fork)
# Cycles through wallpapers in ~/Pictures/backgrounds/ with transitions

WALLPAPER_DIR="$HOME/Pictures/backgrounds"
STATE_FILE="$HOME/.cache/awww-current-wallpaper"

# Get list of wallpapers
mapfile -t wallpapers < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | sort)

if [ ${#wallpapers[@]} -eq 0 ]; then
    echo "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

# Get current wallpaper
current=""
if [ -f "$STATE_FILE" ]; then
    current=$(cat "$STATE_FILE")
fi

# Pick next wallpaper (cycle through list)
next_index=0
for i in "${!wallpapers[@]}"; do
    if [ "${wallpapers[$i]}" = "$current" ]; then
        next_index=$(( (i + 1) % ${#wallpapers[@]} ))
        break
    fi
done

next_wallpaper="${wallpapers[$next_index]}"

# Random transition effect
transitions=("fade" "wipe" "wave" "left" "right" "center" "any" "outer")
transition="${transitions[$((RANDOM % ${#transitions[@]}))]}"

# Set wallpaper with transition
awww img --transition-type "$transition" --transition-duration 1.5 --transition-fps 60 "$next_wallpaper"

# Save current wallpaper
mkdir -p "$(dirname "$STATE_FILE")"
echo "$next_wallpaper" > "$STATE_FILE"

echo "Wallpaper: $(basename "$next_wallpaper") | Transition: $transition"
