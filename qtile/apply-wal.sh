#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
    echo "Usage: apply-wal.sh /path/to/wallpaper" >&2
    exit 1
fi

wall="$1"

# Run pywal and fire the postrun hook (refreshes KDE colors, Papirus folders, etc.)
wal -i "$wall" -o "$HOME/.config/wal/postrun"

# Remember the wallpaper for the existing autostart restore logic.
mkdir -p "$HOME/.cache"
printf "%s\n" "$wall" >"$HOME/.cache/wall_qtile"

# Reload Qtile so widgets pick up the new palette.
qtile cmd-obj -o cmd -f reload_config
