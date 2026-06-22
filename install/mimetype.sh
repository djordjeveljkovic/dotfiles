#!/bin/bash

APP_DIR="$HOME/.local/share/applications"
mkdir -p "$APP_DIR"

echo "📦 Updating .desktop MIME database..."
update-desktop-database "$APP_DIR"

echo "🔗 Setting default applications..."

# Image viewer: imv
xdg-mime default imv.desktop image/png
xdg-mime default imv.desktop image/jpeg
xdg-mime default imv.desktop image/gif
xdg-mime default imv.desktop image/webp
xdg-mime default imv.desktop image/bmp
xdg-mime default imv.desktop image/tiff

# PDF viewer: Chrome (change to zathura.desktop if you use that)
xdg-mime default google-chrome.desktop application/pdf

# Web browser
xdg-settings set default-web-browser google-chrome.desktop
xdg-mime default google-chrome.desktop x-scheme-handler/http
xdg-mime default google-chrome.desktop x-scheme-handler/https

# Video player: mpv
for mime in video/mp4 video/x-msvideo video/x-matroska video/x-flv video/x-ms-wmv \
            video/mpeg video/ogg video/webm video/quicktime video/3gpp video/3gpp2 \
            video/x-ms-asf video/x-ogm+ogg video/x-theora+ogg application/ogg; do
    xdg-mime default mpv.desktop "$mime"
done

echo "🖥️ Creating Alacritty-based .desktop launchers for your TUIs..."

# 🧠 Add your terminal apps below 👇
# Trimmed to what the installer actually ships (btop, tig).
declare -A tui_apps=(
    [btop]="System monitor"
    [tig]="Git UI"
)

for app in "${!tui_apps[@]}"; do
    cat > "$APP_DIR/$app.desktop" <<EOF
[Desktop Entry]
Name=$app
Comment=${tui_apps[$app]}
Exec=alacritty -e $app
Terminal=false
Type=Application
Categories=System;Utility;ConsoleOnly;
EOF
done

# Update database again after creating new launchers
update-desktop-database "$APP_DIR"

echo "✅ Done: Alacritty TUIs and default apps configured."

