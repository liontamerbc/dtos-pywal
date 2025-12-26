#####################################
#    _____  _______  ____   _____   #
#   |  __ \|__   __|/ __ \ / ____|  #
#   | |  | |  | |  | |  | | (___    #
#   | |  | |  | |  | |  | |\___ \   #
#   | |__| |  | |  | |__| |____) |  #
#   |_____/   |_|   \____/|_____/   #
#                                   #
#            DTOS-Pywal              #
#####################################

# DTOS-Pywal README

DTOS-Pywal is a modern, offline-capable, Derek Taylor–style desktop setup for
Arch-based systems. It provides:

- Qtile (DT-inspired configuration)
- AwesomeWM (DT-inspired configuration)
- dmscripts (local copy)
- shell-color-scripts (local copy)
- paru (AUR helper)
- Optional SDDM enablement

A clean, minimal, keyboard-driven workflow that *you* control.

---

## Included In This Pack

```
DTOS-Pywal/
 ├── install.sh
 ├── awesome/
 ├── qtile/
 ├── dmscripts/
 └── shell-color-scripts/
```

---

## Installation

```bash
unzip DTOS-Pywal.zip
cd DTOS-Pywal
chmod +x install.sh
./install.sh
```

---

## After Installation

### Pywal (wallpaper-driven colors)
- Run `wal -i ~/Pictures/wallpapers/<file>` or `~/.config/qtile/apply-wal.sh <file>` to recolor the desktop from a wallpaper.
- Hooks live in `~/.config/wal` (postrun syncs GTK/KDE and Papirus icons); they are copied by the installer/customizer.
- `.Xresources` and Alacritty import wal palettes, falling back to the bundled DT theme if the wal cache is missing.

### Wallpapers
Place wallpapers in:
```
~/Pictures/wallpapers
```

### SDDM Themes
Place themes in:
```
/usr/share/sddm/themes
```

Enable SDDM manually:
```bash
sudo systemctl enable sddm
```

---

## Updating Your Pack

Modify anything (configs, installer, scripts) then rebuild:

```bash
zip -r DTOS-Pywal.zip DTOS-Pywal
```

---

## Credits

Inspired by **Derek Taylor (DistroTube)**.
Linux is supposed to be fun — customize everything.
