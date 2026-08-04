#!/usr/bin/env bash
# Hyprland compositor adapter — thin wrapper that adds the Hyprland
# package set on top of the shared desktop base installed by
# install/desktop.sh.
#
# Run install/desktop.sh first; this script is also sourced from there
# when DOTS_COMPOSITOR=hyprland. It is idempotent.

set -euo pipefail

# Hyprland stack
paru -S --noconfirm --needed \
    hyprland hypridle hyprlock hyprpaper hyprpicker hyprshot hyprsunset \
    uwsm polkit-gnome hyprland-qtutils \
    xdg-desktop-portal-hyprland xdg-desktop-portal-gtk

# Mark the active adapter so subsequent installer steps (themes,
# bash_profile, audit, etc.) can detect it.
mkdir -p "$HOME/.config/dots"
printf 'hyprland\n' > "$HOME/.config/dots/compositor"
echo "==> hyprland adapter installed"