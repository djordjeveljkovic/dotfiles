#!/usr/bin/env bash
# Desktop profile: sway + audio + media + TUIs + fonts + XDG defaults.
set -euo pipefail

# --- Sway + wayland stack ---
paru -S --noconfirm --needed \
  sway swaylock swayidle swaybg \
  waybar fuzzel mako swayosd \
  polkit-gnome \
  autotiling kanshi

# --- Terminal-adjacent TUIs bound in sway ---
paru -S --noconfirm --needed \
  alacritty yazi btop \
  impala bluetui wiremix

# --- Audio ---
paru -S --noconfirm --needed \
  pipewire wireplumber playerctl

# --- Media / hardware ---
paru -S --noconfirm --needed \
  brightnessctl \
  mpv imv \
  wl-clipboard wl-clip-persist cliphist \
  grim slurp wlsunset \
  google-chrome

# --- Fonts (alacritty uses Fira Code NF) ---
paru -S --noconfirm --needed ttf-firacode-nerd

# --- XDG defaults + TUI .desktop launchers ---
source ~/.dots/install/mimetype.sh

# --- TTY autologin (chosen for sub-14s boot; no display manager) ---
OVERRIDE_DIR=/etc/systemd/system/getty@tty1.service.d
sudo mkdir -p "$OVERRIDE_DIR"
sudo tee "$OVERRIDE_DIR/autologin.conf" >/dev/null <<EOF
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin $USER --noclear %I \$TERM
EOF
sudo systemctl daemon-reload

# ~/.bash_profile starts sway on tty1 if not already in a session
cat > ~/.bash_profile <<'EOF'
# Auto-start sway on the first virtual terminal (no display manager)
if [[ -z "$DISPLAY" && -z "$WAYLAND_DISPLAY" && "$XDG_VTNR" -eq 1 ]]; then
  exec sway
fi
EOF

echo "Desktop profile installed. Reboot to auto-login into sway."
