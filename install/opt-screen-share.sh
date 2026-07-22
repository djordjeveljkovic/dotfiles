#!/usr/bin/env bash
# --screen-share: xdg-desktop-portal-wlr so Chrome/Discord/OBS/etc. can share
# the screen in video calls.
#
# Stack: xdg-desktop-portal (router) + xdg-desktop-portal-wlr (wlroots /
# sway backend, handles Screenshot + ScreenCast) + xdg-desktop-portal-gtk
# (file/app chooser, notifications). Configs live in
# ~/.dots/config/xdg-desktop-portal/ and are symlinked into ~/.config/ by
# install/4-config.sh.
#
# Sway already exports WAYLAND_DISPLAY + XDG_CURRENT_DESKTOP=sway via
# dbus-update-activation-environment in default/sway/autostart — that's the
# only env requirement. No sway restart needed.
set -euo pipefail

# --- Packages ---
# Skip the install if everything is already present — saves a sudo round-trip
# and avoids tripping pam_faillock (default deny=3) if the password is wrong
# or this script is being run from a non-TTY pipe that can't prompt.
missing_pkgs=()
for p in xdg-desktop-portal xdg-desktop-portal-gtk xdg-desktop-portal-wlr; do
  pacman -Q "$p" &>/dev/null || missing_pkgs+=("$p")
done
if [[ ${#missing_pkgs[@]} -gt 0 ]]; then
  if [[ ! -t 0 ]]; then
    echo "Need to install: ${missing_pkgs[*]}" >&2
    echo "But stdin is not a TTY (can't prompt for sudo password)." >&2
    echo "Re-run from an interactive terminal, or pre-install with:" >&2
    echo "    sudo pacman -S --noconfirm --needed ${missing_pkgs[*]}" >&2
    exit 1
  fi
  paru -S --noconfirm --needed "${missing_pkgs[@]}"
fi

# --- Configs ---
# install/4-config.sh symlinks ~/.dots/config/xdg-desktop-portal/* into
# ~/.config/xdg-desktop-portal/, so editing the repo edits the live config.
# On an already-installed box, run that step once if the symlink is missing.
if [[ ! -e "$HOME/.config/xdg-desktop-portal/portals.conf" ]]; then
    mkdir -p "$HOME/.config/xdg-desktop-portal"
    ln -sfn "$HOME/.dots/config/xdg-desktop-portal/portals.conf" \
             "$HOME/.config/xdg-desktop-portal/portals.conf"
    ln -sfn "$HOME/.dots/config/xdg-desktop-portal/wlr-portal.conf" \
             "$HOME/.config/xdg-desktop-portal/wlr-portal.conf"
    echo "Linked portal configs from ~/.dots/config/xdg-desktop-portal/."
fi

# --- Enable + start the wlr-portal systemd user service ---
# xdg-desktop-portal-wlr ships a user service
# (/usr/lib/systemd/user/xdg-desktop-portal-wlr.service) with Restart=on-failure.
# Starting it now means the impl is ALWAYS up — the router sees the
# ScreenCast/Screenshot interfaces the instant it starts, instead of
# waiting for a client request and the dbus autostart dance.
#
# Note: don't `enable` this service. It's a Type=dbus unit with no
# [Install] section, meant to be activated by dbus on demand. `enable`
# errors out. The combination of (a) starting it now and (b) dbus
# autostarting it on future boots is enough.
if command -v systemctl &>/dev/null && systemctl --user status &>/dev/null; then
    systemctl --user start xdg-desktop-portal-wlr.service
    # Also restart the main router so it re-reads portals.conf + sees the now-
    # running wlr impl. (Systemd dependencies would handle this for the first
    # boot, but on a long-running session the router was started before wlr
    # was enabled, so we have to nudge it.)
    systemctl --user try-restart xdg-desktop-portal.service
else
    echo "(note) no user systemd — falling back to manual wlr-portal autostart"
fi

# --- Belt-and-suspenders: kill any stragglers so dbus can respawn them ---
# NOTE: do NOT use pkill -x here. On Linux the kernel truncates /proc/PID/comm
# to 15 chars, so 'pkill -x xdg-desktop-portal' (17 chars) matches nothing.
# Use -f (full cmdline) and anchor the pattern so we don't catch our own shell.
pkill -f '^/usr/lib/xdg-desktop-portal'      || true
pkill -f '^/usr/lib/xdg-desktop-portal-gtk$' || true
pkill -f '^/usr/lib/xdg-desktop-portal-wlr$' || true
sleep 0.5

# --- Sanity check ---
# After the restart, the router should expose org.freedesktop.portal.ScreenCast
# and Screenshot (note: "ScreenCast" with capital C, no lowercase t — easy
# typo to make in portals.conf). We probe via D-Bus introspect rather than
# trying to call CreateSession directly, because both gdbus and busctl have
# finicky GVariant parsers for a{sv}.
#
# busctl's output format is flat columns ("org.freedesktop.portal.ScreenCast
#   interface - - -"), so grep for the interface name + "interface" column.
if command -v busctl &>/dev/null; then
    sleep 0.5
    if busctl --user introspect org.freedesktop.portal.Desktop \
        /org/freedesktop/portal/desktop 2>/dev/null \
        | grep -qE 'org\.freedesktop\.portal\.(ScreenCast|Screenshot)\s+interface'; then
        echo "OK — ScreenCast + Screenshot portals are live on the router."
    else
        echo "(warn) ScreenCast/Screenshot not detected on the router yet." >&2
        echo "       Try: systemctl --user restart xdg-desktop-portal-wlr xdg-desktop-portal" >&2
    fi
fi

# --- Also verify the underlying wlr-screencopy protocol is responsive ---
# grim uses the exact same wlr-screencopy-unstable-v1 protocol that
# xdg-desktop-portal-wlr uses to capture the screen. If grim works, the
# portal will work.
if command -v grim &>/dev/null && [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
    test_shot=/tmp/grim-portal-smoke.png
    if grim "$test_shot" &>/dev/null && [[ -s "$test_shot" ]]; then
        size=$(stat -c %s "$test_shot")
        echo "OK — wlr-screencopy works (grim produced a ${size}-byte PNG)."
        rm -f "$test_shot"
    else
        echo "(warn) grim failed — wlr-screencopy is not working." >&2
        echo "       Check that you're actually in a wayland session (echo \$WAYLAND_DISPLAY)." >&2
    fi
fi

cat <<'EOF'

Screen sharing is ready.
  - Chrome/Edge/Discord/OBS: click "Share screen" → slurp-based chooser pops
    up to pick an output or region.
  - Backend pinned via config/xdg-desktop-portal/portals.conf (ScreenCast
    AND Screenshot → wlr; everything else → gtk).
  - wlr backend is a systemd user service (xdg-desktop-portal-wlr.service)
    so it survives sway restarts and starts on next login automatically.

If screen sharing still fails in a specific app:
  - Restart the app (Chrome/Discord/etc.) — portals are looked up at launch.
  - Chrome flags worth knowing about (already on by default in modern
    Chrome, but if sharing fails: chrome://flags):
      #use-fake-ui-for-media-stream        Default
      #enable-webrtc-pipewire-capturer     Default
  - Verify in the running session:
      busctl --user introspect org.freedesktop.portal.Desktop \
        /org/freedesktop/portal/desktop | grep -E 'ScreenCast|Screenshot'
EOF
