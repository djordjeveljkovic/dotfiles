#!/usr/bin/env bash
# ~/.dots/install/keyboard.sh
#
# Configure the system XKB keyboard layouts so they match the
# compositor configs (default/hypr/input.conf and default/sway/input):
#
#   XKB layouts:   us,rs,rs
#   XKB variant:   ,latin,
#   XKB options:   grp:alt_shift_toggle,ctrl:nocaps,altwin:menu_win
#   (Hyprland adds: altwin:altgr)
#
# Without this, /etc/X11/xorg.conf.d/00-keyboard.conf (managed by
# systemd-localed from a fresh install) ends up with only `us` and
# Alt+Shift does not switch layouts. The compositor configs declare
# the same set, so the X session and the TTY agree.
#
# localectl writes both:
#   /etc/X11/xorg.conf.d/00-keyboard.conf
#   /etc/vconsole.conf (the TTY layout)
#
# Idempotent. Re-running prints the current setting and exits.

set -euo pipefail

DOTS_LAYOUT="us,rs,rs"
DOTS_VARIANT=",latin,"
DOTS_OPTIONS_X11="grp:alt_shift_toggle,ctrl:nocaps,altwin:menu_win"
DOTS_OPTIONS_TTY="grp:alt_shift_toggle,ctrl:nocaps,altwin:menu_win,altwin:altgr"
DOTS_MODEL="pc105+inet"

if ! command -v localectl >/dev/null 2>&1; then
    echo "keyboard: localectl not found (systemd-localed missing); skipping" >&2
    exit 0
fi

current_x11=$(localectl status 2>/dev/null \
    | awk -F': *' '/X11 Layout/ {print $2; exit}')
current_model=$(localectl status 2>/dev/null \
    | awk -F': *' '/X11 Model/ {print $2; exit}')
current_opts=$(localectl status 2>/dev/null \
    | awk -F': *' '/X11 Options/ {print $2; exit}')

if [[ "$current_x11"    == "$DOTS_LAYOUT" \
   && "$current_model"   == "$DOTS_MODEL" \
   && "$current_opts"    == "$DOTS_OPTIONS_X11" ]]; then
    echo "keyboard: already set to $DOTS_LAYOUT ($DOTS_MODEL)"
    exit 0
fi

echo "keyboard: setting XKB to layout=$DOTS_LAYOUT variant=$DOTS_VARIANT model=$DOTS_MODEL"
sudo localectl set-x11-keymap "$DOTS_LAYOUT" "$DOTS_MODEL" "$DOTS_VARIANT" "$DOTS_OPTIONS_X11"

# vconsole: same layout / model / options minus the X11-only ones.
# (We keep both X11 and TTY options in sync; the only difference is
# that vconsole can't use the Hyprland-only altwin:altgr.)
echo "keyboard: setting vconsole to layout=$DOTS_LAYOUT"
sudo localectl set-keymap "$DOTS_LAYOUT"
sudo localectl set-vconsole-keymap "$DOTS_LAYOUT"

echo "keyboard: done. Verify with 'localectl status'."