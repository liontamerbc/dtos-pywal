<!-- Optional banner slot -->
<!-- <p align="center"><img src="YOUR_BANNER_URL_HERE" alt="DTOS-Pywal Banner" /></p> -->

<h1 align="center">🦁 DTOS-Pywal 🦁</h1>
<h3 align="center">Pywal-driven DT desktop pack for Arch-based systems</h3>

<p align="center">A Derek Taylor–inspired, keyboard-first setup with pywal-powered colors and offline-friendly bundles.</p>

<p align="center">━━✦━━</p>

<h3 align="center">🛠️ Stack & Contents</h3>

<p align="center">
  <img src="https://img.shields.io/badge/Arch_Linux-C19A3F?style=for-the-badge&logo=archlinux&logoColor=1C1C1C" />
  <img src="https://img.shields.io/badge/Qtile_(Python)-7C5E3C?style=for-the-badge&logo=python&logoColor=F5F5F5" />
  <img src="https://img.shields.io/badge/AwesomeWM_(Lua)-1C1C1C?style=for-the-badge&logo=lua&logoColor=C19A3F" />
  <img src="https://img.shields.io/badge/pywal-F1551D?style=for-the-badge&logo=python&logoColor=F5F5F5" />
  <img src="https://img.shields.io/badge/dmenu-8B0000?style=for-the-badge&logo=linux&logoColor=F5F5F5" />
</p>

<ul>
  <li>Qtile and AwesomeWM configs with wal-aware color hooks.</li>
  <li>Pywal hooks/templates so GTK/KDE, icons, and terminals follow your wallpaper.</li>
  <li>dmscripts and shell-color-scripts bundled for offline installs.</li>
  <li>paru AUR helper plus optional SDDM enablement.</li>
  <li>DTOS wallpapers copied system-wide to <code>/usr/share/backgrounds/dtos-backgrounds</code>.</li>
</ul>

<h3 align="center">📦 Repo Layout</h3>

```
DTOS-Pywal/
 ├── install.sh
 ├── wal/
 ├── dtos-backgrounds/
 ├── awesome/
 ├── qtile/
 ├── dmscripts/
 └── shell-color-scripts/
```

<h3 align="center">🚀 Install</h3>

```bash
unzip DTOS-Pywal.zip
cd DTOS-Pywal
chmod +x install.sh
./install.sh
```

<p align="center">━━✦━━</p>

<h3 align="center">🎨 After Installation</h3>
<ul>
  <li>Pywal: on login, Qtile autostart re-applies your last wal theme to match the current wallpaper. To change it, run <code>wal -i /usr/share/backgrounds/dtos-backgrounds/&lt;file&gt;</code> or <code>~/.config/qtile/apply-wal.sh /usr/share/backgrounds/dtos-backgrounds/&lt;file&gt;</code>.</li>
  <li>Hooks: wal templates live in <code>~/.config/wal</code>; terminals and GTK/KDE pick up palettes automatically after wal runs.</li>
  <li>Wallpapers: installer copies bundled images into <code>/usr/share/backgrounds/dtos-backgrounds</code>; add your own there (sudo) and let wal/apply-wal use them.</li>
  <li>SDDM: enable with <code>sudo systemctl enable sddm</code> if you chose to install it.</li>
</ul>

<h3 align="center">🔄 Update The Pack</h3>

```bash
zip -r DTOS-Pywal.zip DTOS-Pywal
```

<h3 align="center">🙏 Credits</h3>
<ul>
  <li>Inspired by <strong>Derek Taylor (DistroTube)</strong>.</li>
  <li>Linux is supposed to be fun — customize everything.</li>
</ul>

<p align="center" style="color:#F1551D; font-family:JetBrains Mono; font-size:18px;">
  ───────────── ✝ ─────────────
</p>

<p align="center" style="color:#F1551D; font-family:JetBrains Mono; font-size:18px;">
  🦁 Build boldly, tweak freely, enjoy the ride.
</p>
