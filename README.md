<!-- Optional banner slot -->
<!-- <p align="center"><img src="YOUR_BANNER_URL_HERE" alt="DTOS-Pywal Banner" /></p> -->

<h1 align="center">🦁 DTOS-Pywal 🦁</h1>
<h3 align="center">Derek Taylor’s DTOS tiling desktop for Arch & Arch-based systems (with Pywal)</h3>

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
<p align="center"><strong>Requires:</strong> Arch/Arch-based distro with <code>pacman</code> and <code>sudo</code>.</p>

```bash
unzip DTOS-Pywal.zip
cd DTOS-Pywal
chmod +x install.sh
./install.sh
```

<p align="center">━━✦━━</p>

<h3 align="center">🎨 After Installation</h3>
<ul>
  <li><strong>Pywal auto-apply:</strong> use the included <code>dm-setbg</code> picker (dmenu/bemenu/wofi). It sets the wallpaper and runs wal immediately so colors follow without extra steps.</li>
  <li><strong>Login restore:</strong> Qtile and Awesome autostart re-apply wal for your last chosen wallpaper; bars/widgets and GTK/KDE recolor on login.</li>
  <li><strong>Outside dm-setbg:</strong> use <code>wal-wallpaper /usr/share/backgrounds/dtos-backgrounds/&lt;file&gt;</code> to set the wallpaper and run wal together. A systemd watcher also re-applies wal whenever the wallpaper cache changes.</li>
  <li><strong>Wallpapers:</strong> installer copies bundled images into <code>/usr/share/backgrounds/dtos-backgrounds</code>; to add your own, copy images into that folder (sudo required) so <code>dm-setbg</code>/wal can see them.</li>
  <li><strong>SDDM:</strong> enable with <code>sudo systemctl enable sddm</code> if you chose to install it.</li>
</ul>

<p><strong>Need to reapply configs later?</strong> Run <code>./apply-customizations.sh</code> from the repo to re-copy bundled configs without rerunning the installer.</p>

<h3 align="center">🔄 Repack For Sharing (optional)</h3>

```bash
rm -f DTOS-Pywal.zip
zip -r DTOS-Pywal.zip DTOS-Pywal
```

<p>If you just clone and use the repo, you can skip this. Run it only when you want to rebuild a distributable zip after making changes. Prefer a clean archive? <code>git archive --format=zip -o DTOS-Pywal.zip HEAD</code>.</p>

<h3 align="center">🙏 Credits</h3>
<ul>
  <li>Inspired by <strong>Derek Taylor (DistroTube)</strong>.</li>
  <li>Linux is supposed to be fun — customize everything.</li>
</ul>

<h4 align="center">📜 Licensing</h4>
<p align="center" style="font-size:12px;">
  This repo’s additions are GPL-3.0. Bundled components keep their original licenses (dmscripts GPL-3.0, Lain GPL-2.0, shell-color-scripts MIT). Wallpapers have mixed/unknown origins—see <a href="LICENSE">LICENSE</a> and <a href="NOTICE">NOTICE</a> if you need one removed.
</p>

<p align="center" style="color:#F1551D; font-family:JetBrains Mono; font-size:18px;">
  ───────────── ✝ ─────────────
</p>

<p align="center" style="color:#F1551D; font-family:JetBrains Mono; font-size:18px;">
  🦁 Build boldly, tweak freely, enjoy the ride.
</p>
