#!/bin/bash
# Power profile cycler for waybar
# Cycles: power-saver -> balanced -> performance -> power-saver

PROFILES=("power-saver" "balanced" "performance")
ICONS=("" "" "")
LABELS=("Power Saver" "Balanced" "Performance")

# Get current profile
current=$(powerprofilesctl get 2>/dev/null)

# Find current index
current_idx=1
for i in "${!PROFILES[@]}"; do
    if [ "${PROFILES[$i]}" = "$current" ]; then
        current_idx=$i
        break
    fi
done

# If called with --cycle, switch to next profile
if [ "$1" = "--cycle" ]; then
    next_idx=$(( (current_idx + 1) % ${#PROFILES[@]} ))
    powerprofilesctl set "${PROFILES[$next_idx]}"
    current_idx=$next_idx
fi

# Output JSON for waybar
icon="${ICONS[$current_idx]}"
label="${LABELS[$current_idx]}"
profile="${PROFILES[$current_idx]}"
printf '{"text": "%s", "tooltip": "Power Profile: %s\nClick to cycle", "class": "%s"}
' "$icon" "$label" "$profile"
