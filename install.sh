#!/usr/bin/env bash
#
#    _____  _______  ____   _____
#   |  __ \|__   __|/ __ \ / ____|
#   | |  | |  | |  | |  | | (___
#   | |  | |  | |  | |  | |\___ \
#   | |__| |  | |  | |__| |____) |
#   |_____/   |_|   \____/|_____/
#
#
#  DTOS-2025 Installer (Qtile + Awesome)
#  Inspired by Derek Taylor / DistroTube style
#
# This script assumes:
#   - Arch-based distro with pacman
# shellcheck disable=SC2016
#   - You are *not* root
#   - The following exist in this folder:
#       ./awesome/
#       ./qtile/
#       ./dmscripts/
#       ./shell-color-scripts/
#

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_FILE="$HOME/.cache/dtos-2025-install.log"
mkdir -p "$(dirname "$LOG_FILE")"

# ---------------------------------------------------------------------------
# Safety checks
# ---------------------------------------------------------------------------

if [ "$(id -u)" -eq 0 ]; then
    echo "==============================================================="
    echo "  ERROR: Do NOT run this script as root."
    echo "  Run it as your normal user. Sudo will be used when needed."
    echo "==============================================================="
    exit 1
fi

if ! command -v whiptail >/dev/null 2>&1; then
    echo "Installing 'libnewt' (whiptail)..."
    sudo pacman -S --needed --noconfirm libnewt
fi

# ---------------------------------------------------------------------------
# Whiptail colors (DT vibe)
# ---------------------------------------------------------------------------

export NEWT_COLORS="
root=white,blue
border=white,blue
window=black,lightgray
shadow=black,blue
title=white,blue
button=black,blue
actbutton=white,cyan
textbox=black,lightgray
"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

error() {
    whiptail --title "DTOS-2025 ERROR" --msgbox "$1" 10 70
    clear
    exit 1
}

run_step() {
    local msg="$1"
    shift
    printf "\n[%s] %s\n" "$(date -Iseconds)" "$msg" >>"$LOG_FILE"
    whiptail --title "DTOS-2025" --infobox "$msg" 7 60
    if "$@" >>"$LOG_FILE" 2>&1; then
        return 0
    fi

    error "$msg

Command failed. Check:
  $LOG_FILE"
}

# Download Weather Icons TTF directly (fallback when AUR is unavailable)
install_weather_icons_manual() {
    local url="https://github.com/erikflowers/weather-icons/archive/refs/heads/master.zip"
    local tmp_dir font_dir

    tmp_dir="$(mktemp -d)" || return 1
    font_dir="$HOME/.local/share/fonts/weather-icons"
    mkdir -p "$font_dir"

    if ! curl -L --fail --silent --show-error "$url" -o "$tmp_dir/weather-icons.zip"; then
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! unzip -j "$tmp_dir/weather-icons.zip" "*/font/weathericons-regular-webfont.ttf" -d "$font_dir" >/dev/null 2>&1; then
        rm -rf "$tmp_dir"
        return 1
    fi

    fc-cache -f "$font_dir" >/dev/null 2>&1
    rm -rf "$tmp_dir"
    return 0
}

# ---------------------------------------------------------------------------
# Intro / warnings (DTOS-style)
# ---------------------------------------------------------------------------

# Welcome screen
whiptail --title "Installing DTOS-2025!" --msgbox "\
This script will set up a DT-style tiling desktop
(Xmonad, AwesomeWM and/or Qtile) plus tools and configs.

You will be asked a few questions before anything changes." 15 70

# Distro warning
if ! grep -qs 'ID=arch' /etc/os-release; then
    whiptail --title "Installing DTOS-2025!" --msgbox "\
WARNING: This installer is written for Arch Linux
and Arch-based distributions that use pacman.

Running it on anything else is very likely to break things." 15 72
fi

# Big caution screen
whiptail --title "Installing DTOS-2025!" --msgbox "\
This script installs a large number of packages and
overwrites some configuration files in your home directory.

It is best used on a fresh install or a test machine,
not a critical production system." 16 72

# Ask which window managers to install (like DTOS prompts)
INSTALL_XMONAD=n
INSTALL_AWESOME=n
INSTALL_QTILE=n

if whiptail --title "Window Managers" --yesno "\
Do you wish to install Xmonad? (recommended if unsure)" 10 60; then
    INSTALL_XMONAD=y
fi

if whiptail --title "Window Managers" --yesno "\
Do you wish to install AwesomeWM?" 10 60; then
    INSTALL_AWESOME=y
fi

if whiptail --title "Window Managers" --yesno "\
Do you wish to install Qtile?" 10 60; then
    INSTALL_QTILE=y
fi

if [ "$INSTALL_XMONAD" = "n" ] && [ "$INSTALL_AWESOME" = "n" ] && [ "$INSTALL_QTILE" = "n" ]; then
    error "You must choose at least one window manager. Install cancelled."
fi

# Final confirmation, like DT's 'Shall we begin installing DTOS?'
if ! whiptail --title "Installing DTOS-2025!" --yesno "\
Shall we begin installing DTOS-2025 now?" 10 60; then
    clear
    echo "DTOS-2025: installation cancelled by user. Nothing changed."
    exit 0
fi

# ---------------------------------------------------------------------------
# System update
# ---------------------------------------------------------------------------

run_step "Updating system (pacman -Syu)..." sudo pacman -Syu --noconfirm

# ---------------------------------------------------------------------------
# Core packages
# ---------------------------------------------------------------------------

SXIV_PKG=""
if pacman -Si nsxiv >/dev/null 2>&1; then
    SXIV_PKG="nsxiv"
elif pacman -Si sxiv >/dev/null 2>&1; then
    SXIV_PKG="sxiv"
else
    whiptail --title "Image Viewer Warning" --msgbox "Neither nsxiv nor sxiv was found in your repositories.

The installer will continue without that image viewer." 12 70
fi

PYWAL_PKG=""
if pacman -Q python-pywal16 >/dev/null 2>&1; then
    :
elif pacman -Q python-pywal >/dev/null 2>&1; then
    :
elif pacman -Si python-pywal >/dev/null 2>&1; then
    PYWAL_PKG="python-pywal"
elif pacman -Si python-pywal16 >/dev/null 2>&1; then
    PYWAL_PKG="python-pywal16"
else
    whiptail --title "Pywal Warning" --msgbox "Neither python-pywal nor python-pywal16 is available in your repositories.

The installer will continue without pywal; some color features may be missing." 12 70
fi

core_pkgs=(
    xorg-server xorg-xinit xorg-xrandr xorg-xsetroot xorg-xprop
    alacritty xterm thunar firefox
    rofi dmenu
    picom starship
    feh xwallpaper swaybg swww
    python-dbus-next pacman-contrib
    papirus-icon-theme papirus-folders
    git fzf wget curl unzip
    python-psutil lm_sensors spice-vdagent
    noto-fonts ttf-dejavu ttf-liberation ttf-ubuntu-font-family
)

# Add WMs based on what the user chose
if [ "$INSTALL_XMONAD" = "y" ]; then
    core_pkgs+=(xmonad xmonad-contrib xmobar)
fi
if [ "$INSTALL_AWESOME" = "y" ]; then
    core_pkgs+=(awesome)
fi
if [ "$INSTALL_QTILE" = "y" ]; then
    core_pkgs+=(qtile)
fi
[ -n "$SXIV_PKG" ] && core_pkgs+=("$SXIV_PKG")
[ -n "$PYWAL_PKG" ] && core_pkgs+=("$PYWAL_PKG")

run_step "Installing core packages (window managers + tools)..." \
    sudo pacman -S --needed --noconfirm "${core_pkgs[@]}"

# ---------------------------------------------------------------------------
# Wallpaper tools (sxiv, xwallpaper)
# ---------------------------------------------------------------------------

wallpaper_pkgs=(xwallpaper)
[ -n "$SXIV_PKG" ] && wallpaper_pkgs+=("$SXIV_PKG")
run_step "Installing wallpaper tools (sxiv/nsxiv + xwallpaper)..." \
    sudo pacman -S --needed --noconfirm "${wallpaper_pkgs[@]}"

# ---------------------------------------------------------------------------
# Build tools (required for paru/AUR packages)
# ---------------------------------------------------------------------------

run_step "Installing base-devel (needed for building paru/AUR packages)..." \
    sudo pacman -S --needed --noconfirm base-devel

# ---------------------------------------------------------------------------
# Ensure ~/.local/bin is on PATH (dmscripts, dm-run, etc.)
# ---------------------------------------------------------------------------

for rc in "$HOME/.profile" "$HOME/.bashrc"; do
    if [ -f "$rc" ]; then
        if ! grep -q 'HOME/.local/bin' "$rc" 2>/dev/null; then
            printf '\n# Ensure local bin is on PATH\nexport PATH="$HOME/.local/bin:$PATH"\n' >>"$rc"
        fi
    else
        printf '#!/bin/sh\n# Ensure local bin is on PATH\nexport PATH="$HOME/.local/bin:$PATH"\n' >"$rc"
    fi
done

# ---------------------------------------------------------------------------
# Paru
# ---------------------------------------------------------------------------

if ! command -v paru >/dev/null 2>&1; then
    run_step "Installing paru (AUR helper)..." bash -c '
    cd "$HOME"
    if [ ! -d paru ]; then
      git clone https://aur.archlinux.org/paru.git
    fi
    cd paru
    makepkg -si --noconfirm
  '
fi

mkdir -p "$HOME/.config/paru"
cat >"$HOME/.config/paru/paru.conf" <<EOF
[options]
BottomUp
SudoLoop
CleanAfter
EOF

# ---------------------------------------------------------------------------
# Fonts
# ---------------------------------------------------------------------------

whiptail --title "DTOS-2025" --infobox "Font installation skipped (disabled in installer)." 7 60

# ---------------------------------------------------------------------------
# SDDM (optional)
# ---------------------------------------------------------------------------

if whiptail --title "Enable SDDM?" --yesno "SDDM is a graphical login manager.

Would you like to install and enable SDDM now?" 12 60; then
    run_step "Installing SDDM..." sudo pacman -S --needed --noconfirm sddm
    run_step "Enabling SDDM..." sudo systemctl enable sddm.service --force
else
    whiptail --title "SDDM Skipped" --msgbox "SDDM will NOT be enabled.

You can enable it later with:
  sudo systemctl enable sddm
" 12 60
fi

# ---------------------------------------------------------------------------
# dmscripts from local pack
# ---------------------------------------------------------------------------

if [ -d "$SCRIPT_DIR/dmscripts" ]; then
    run_step "Installing dmscripts from local pack..." bash -c '
    mkdir -p "$HOME/.local/bin"
    if [ -d "'"$SCRIPT_DIR"'/dmscripts/scripts" ]; then
      cp "'"$SCRIPT_DIR"'/dmscripts/scripts/"* "$HOME/.local/bin/" 2>/dev/null || true
      chmod +x "$HOME/.local/bin/"*
    fi

    sudo mkdir -p /etc/dmscripts
    if [ -f "'"$SCRIPT_DIR"'/dmscripts/config/config" ]; then
      sudo cp "'"$SCRIPT_DIR"'/dmscripts/config/config" /etc/dmscripts/config
    fi

    mkdir -p "$HOME/.config/dmscripts"
    if [ -f /etc/dmscripts/config ]; then
      cp /etc/dmscripts/config "$HOME/.config/dmscripts/config"
      sed -i "s/DMTERM=\"st -e\"/DMTERM=\"alacritty -e\"/" "$HOME/.config/dmscripts/config" 2>/dev/null || true
    fi
  '
else
    whiptail --title "dmscripts Warning" --msgbox "No ./dmscripts directory found next to install.sh.

Skipping dmscripts install." 10 70
fi

# ---------------------------------------------------------------------------
# Custom dm-setbg override from project root
# ---------------------------------------------------------------------------

if [ -f "$SCRIPT_DIR/dm-setbg" ]; then
    run_step "Installing custom dm-setbg script..." bash -c '
    mkdir -p "$HOME/.local/bin"
    cp "'"$SCRIPT_DIR"'/dm-setbg" "$HOME/.local/bin/dm-setbg"
    chmod +x "$HOME/.local/bin/dm-setbg"
  '
fi

# ---------------------------------------------------------------------------
# shell-color-scripts from local pack
# ---------------------------------------------------------------------------

if [ -d "$SCRIPT_DIR/shell-color-scripts" ]; then
    run_step "Installing shell-color-scripts from local pack..." bash -c '
    colors_dir="$HOME/.local/share/shell-color-scripts/colorscripts"
    bin_dir="$HOME/.local/bin"
    mkdir -p "$colors_dir" "$bin_dir"

    if [ -d "'"$SCRIPT_DIR"'/shell-color-scripts/colorscripts" ]; then
      shopt -s nullglob
      for f in "'"$SCRIPT_DIR"'/shell-color-scripts/colorscripts/"*; do
        cp "$f" "$colors_dir/"
        chmod +x "$colors_dir/$(basename "$f")"
      done
      shopt -u nullglob
    fi

    if [ -f "'"$SCRIPT_DIR"'/shell-color-scripts/colorscript.sh" ]; then
      cp "'"$SCRIPT_DIR"'/shell-color-scripts/colorscript.sh" "$bin_dir/colorscript"
      chmod +x "$bin_dir/colorscript"
    fi

    if ! grep -q "colorscript -r" "$HOME/.bashrc" 2>/dev/null; then
      echo "if command -v colorscript >/dev/null 2>&1; then colorscript -r; fi" >> "$HOME/.bashrc"
    fi
  '
else
    whiptail --title "shell-color-scripts Warning" --msgbox "No ./shell-color-scripts directory found next to install.sh.

Skipping shell-color-scripts install." 10 70
fi

# ---------------------------------------------------------------------------
# Picom config and AMD TearFree
# ---------------------------------------------------------------------------

run_step "Deploying picom config (vsync + AMD-friendly)..." bash -c '
  mkdir -p "$HOME/.config/picom"
  if [ -f "'"$SCRIPT_DIR"'/picom/picom.conf" ]; then
    cp "'"$SCRIPT_DIR"'/picom/picom.conf" "$HOME/.config/picom/picom.conf"
  fi
'

# Install AMD TearFree xorg snippet if AMD GPU detected
if lspci | grep -qi "AMD/ATI" && [ -f "$SCRIPT_DIR/picom/20-amdgpu-tearfree.conf" ]; then
    run_step "Installing AMD TearFree Xorg snippet..." bash -c '
    sudo install -Dm644 "'"$SCRIPT_DIR"'/picom/20-amdgpu-tearfree.conf" /etc/X11/xorg.conf.d/20-amdgpu-tearfree.conf
  '
fi

# ---------------------------------------------------------------------------
# DTOS backgrounds
# ---------------------------------------------------------------------------

if [ -d "$SCRIPT_DIR/dtos-backgrounds" ]; then
    run_step "Installing DTOS backgrounds..." bash -c '
    sudo mkdir -p /usr/share/backgrounds/dtos-backgrounds
    sudo cp -r "'"$SCRIPT_DIR"'/dtos-backgrounds/"* /usr/share/backgrounds/dtos-backgrounds/ 2>/dev/null || true
  '
else
    whiptail --title "Backgrounds Warning" --msgbox "No ./dtos-backgrounds directory found next to install.sh.

Skipping backgrounds install." 10 70
fi

# ---------------------------------------------------------------------------
# Xmonad / Awesome / Qtile configs
# ---------------------------------------------------------------------------

if [ "$INSTALL_XMONAD" = "y" ]; then
    if [ -d "$SCRIPT_DIR/xmonad" ]; then
        run_step "Copying Xmonad config..." bash -c '
      mkdir -p "$HOME/.config"
      cp -r "'"$SCRIPT_DIR"'/xmonad" "$HOME/.config/"
    '
    else
        whiptail --title "Xmonad Warning" --msgbox "You chose to install Xmonad but no ./xmonad directory
was found next to install.sh.

Xmonad config will NOT be copied." 12 70
    fi
fi

if [ "$INSTALL_AWESOME" = "y" ]; then
    if [ -d "$SCRIPT_DIR/awesome" ]; then
        run_step "Copying AwesomeWM config..." bash -c '
      mkdir -p "$HOME/.config"
      cp -r "'"$SCRIPT_DIR"'/awesome" "$HOME/.config/"
    '
    else
        whiptail --title "AwesomeWM Warning" --msgbox "You chose to install AwesomeWM but no ./awesome directory
was found next to install.sh.

AwesomeWM config will NOT be copied." 12 70
    fi
fi

if [ "$INSTALL_QTILE" = "y" ]; then
    if [ -d "$SCRIPT_DIR/qtile" ]; then
        run_step "Copying Qtile config..." bash -c '
      mkdir -p "$HOME/.config"
      cp -r "'"$SCRIPT_DIR"'/qtile" "$HOME/.config/"
      chmod +x "$HOME/.config/qtile/"{autostart.sh,apply-wal.sh,wal-reloader.sh} 2>/dev/null || true
    '
    else
        whiptail --title "Qtile Warning" --msgbox "You chose to install Qtile but no ./qtile directory
was found next to install.sh.

Qtile config will NOT be copied." 12 70
    fi
fi

# Copy pywal hooks/templates so wallpaper colors propagate system-wide
if [ -d "$SCRIPT_DIR/wal" ]; then
    run_step "Copying pywal hooks..." bash -c '
      mkdir -p "$HOME/.config"
      cp -r "'"$SCRIPT_DIR"'/wal" "$HOME/.config/"
      chmod +x "$HOME/.config/wal/postrun" 2>/dev/null || true
    '
fi

# Seed pywal cache once so colors are ready for widgets/GTK/KDE out of the box.
run_step "Seeding pywal colors from a wallpaper (once)..." bash -c '
  pick_wall() {
    # 1) user cache from dtos wallpaper tools
    for candidate in "$HOME/.cache/wall" "$HOME/.cache/wall_qtile" "$HOME/.cache/wall_awesome"; do
      if [ -f "$candidate" ]; then
        img="$(cat "$candidate" 2>/dev/null || true)"
        [ -n "$img" ] && [ -f "$img" ] && printf "%s\n" "$img" && return 0
      fi
    done

    # 2) system backgrounds copied earlier in this installer
    if [ -d /usr/share/backgrounds/dtos-backgrounds ]; then
      find /usr/share/backgrounds/dtos-backgrounds -type f | head -n1
      return 0
    fi

    # 3) bundled dtos-backgrounds next to install.sh (if not installed system-wide)
    if [ -d "'"$SCRIPT_DIR"'/dtos-backgrounds" ]; then
      find "'"$SCRIPT_DIR"'/dtos-backgrounds" -type f | head -n1
      return 0
    fi
    return 1
  }

  if command -v wal >/dev/null 2>&1; then
    wall_img="$(pick_wall || true)"
    if [ -n "$wall_img" ]; then
      wal -n -q -i "$wall_img" >/dev/null 2>&1 || true
    fi
  fi
'

# Default to Papirus-Dark so wal's Papirus recolor hook is visible in GTK/Qt
run_step "Setting Papirus-Dark as icon theme (GTK/KDE)..." bash -c '
  theme="Papirus-Dark"

  set_gtk_theme() {
    local target="$1"
    python - "$target" "$theme" <<'"'PY'"'
from pathlib import Path
import sys

target = Path(sys.argv[1])
theme = sys.argv[2]
target.parent.mkdir(parents=True, exist_ok=True)
lines = target.read_text().splitlines() if target.exists() else []

# Ensure we have a [Settings] header
if not lines or not lines[0].strip().startswith("["):
    lines = ["[Settings]"] + lines
elif lines[0].strip() != "[Settings]":
    lines = ["[Settings]"] + lines

# Replace or append gtk-icon-theme-name
for idx, line in enumerate(lines):
    if line.startswith("gtk-icon-theme-name="):
        lines[idx] = f"gtk-icon-theme-name={theme}"
        break
else:
    lines.append(f"gtk-icon-theme-name={theme}")

target.write_text("\n".join(lines) + "\n")
PY
  }

  set_gtk_theme "$HOME/.config/gtk-3.0/settings.ini"
  set_gtk_theme "$HOME/.config/gtk-4.0/settings.ini"

  # Set KDE icon theme if KDE config is present/desired
  if command -v kwriteconfig5 >/dev/null 2>&1; then
    kwriteconfig5 --file kdeglobals --group Icons --key Theme "$theme" >/dev/null 2>&1 || true
  else
    python - "$theme" <<'"'PY'"'
from pathlib import Path
import sys

theme = sys.argv[1]
cfg = Path.home() / ".config" / "kdeglobals"
cfg.parent.mkdir(parents=True, exist_ok=True)
lines = cfg.read_text().splitlines() if cfg.exists() else []

out = []
in_icons = False
icons_section_present = False
theme_written = False

for line in lines:
    stripped = line.strip()
    if stripped.startswith("[") and stripped.endswith("]"):
        if in_icons and not theme_written:
            out.append(f"Theme={theme}")
            theme_written = True
        in_icons = stripped.lower() == "[icons]"
        if in_icons:
            icons_section_present = True
        out.append(line)
        continue
    if in_icons and stripped.startswith("Theme="):
        out.append(f"Theme={theme}")
        theme_written = True
        continue
    out.append(line)

if icons_section_present and not theme_written:
    out.append(f"Theme={theme}")
elif not icons_section_present:
    if out and out[-1].strip():
        out.append("")
    out.append("[Icons]")
    out.append(f"Theme={theme}")

cfg.write_text("\n".join(out) + "\n")
PY
  fi
'

# Copy terminal config that imports wal colors
if [ -d "$SCRIPT_DIR/alacritty" ]; then
    run_step "Copying Alacritty config..." bash -c '
      mkdir -p "$HOME/.config"
      cp -r "'"$SCRIPT_DIR"'/alacritty" "$HOME/.config/"
    '
fi

# ---------------------------------------------------------------------------
# Finish
# ---------------------------------------------------------------------------

whiptail --title "DTOS-2025 Installed" --msgbox "DTOS-2025 installation is complete.

You can now:
  • Reboot and choose your DTOS window manager (Xmonad / AwesomeWM / Qtile)
  • Or start them from a TTY with startx (if configured)
Enjoy your DTOS-2025 desktop." 18 72

if whiptail --title "Reboot Now?" --yesno "Do you want to reboot now?" 8 40; then
    reboot
fi

clear
echo "DTOS-2025 installation finished. Reboot when ready."

# Install dunst auto-setup script
mkdir -p "$HOME/.local/bin"
cp "$(dirname "$0")/dtos-dunst-setup" "$HOME/.local/bin/"
chmod +x "$HOME/.local/bin/dtos-dunst-setup"
