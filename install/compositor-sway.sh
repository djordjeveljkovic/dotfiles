#!/usr/bin/env bash
# Sway compositor adapter — thin wrapper that adds the Sway package set
# on top of the shared desktop base installed by install/desktop.sh.
#
# Run install/desktop.sh first; this script is also sourced from there
# when DOTS_COMPOSITOR=sway. It is idempotent.

set -euo pipefail

# Sway itself + sway-native idle/lock/bg
paru -S --noconfirm --needed \
    sway swaylock swayidle swaybg \
    fuzzel \
    autotiling

# Mark the active adapter so subsequent installer steps (themes,
# bash_profile, audit, etc.) can detect it.
mkdir -p "$HOME/.config/dots"
printf 'sway\n' > "$HOME/.config/dots/compositor"
echo "==> sway adapter installed"