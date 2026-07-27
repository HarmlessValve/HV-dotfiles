#!/bin/bash

DIR="$HOME/Pictures/Screenshots"
MODE=$1

# Hitung jumlah file sebelum screenshot
PREV_COUNT=$(ls -1 "$DIR" 2>/dev/null | wc -l)

if [ "$MODE" == "full" ]; then
    grim - | swappy -f -
elif [ "$MODE" == "area" ]; then
    grim -g "$(slurp)" - | swappy -f -
else
    echo "Usage: $0 {full|area}"
    exit 1
fi

# Hitung jumlah file sesudah screenshot
NEW_COUNT=$(ls -1 "$DIR" 2>/dev/null | wc -l)

if [ "$NEW_COUNT" -gt "$PREV_COUNT" ]; then
    # Ambil file terbaru untuk ditampilkan di notifikasi
    LATEST_FILE=$(ls -t "$DIR" | head -n 1)
    notify-send -i "$DIR/$LATEST_FILE" "Screenshot Saved" "Saved to $DIR/$LATEST_FILE"
fi
