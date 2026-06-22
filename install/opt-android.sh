#!/usr/bin/env bash
# opt --android: Android SDK + platform-tools + cmdline-tools.
# Standalone (usable for native Kotlin/Java dev). Also auto-enabled by --flutter.
set -euo pipefail

paru -S --noconfirm --needed android-tools android-udev

SDK="$HOME/Android/Sdk"
CMDLINE="$SDK/cmdline-tools/latest"
mkdir -p "$CMDLINE"

# Download cmdline-tools if not present
if [[ ! -d "$CMDLINE/bin" ]]; then
  echo "Downloading Android cmdline-tools..."
  TMP=$(mktemp -d)
  curl -fsSL -o "$TMP/cmdline-tools.zip" \
    "https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"
  unzip -q "$CMDLINE" -d "$TMP" 2>/dev/null || unzip -q "$TMP/cmdline-tools.zip" -d "$TMP"
  mkdir -p "$CMDLINE"
  mv "$TMP/cmdline-tools/bin" "$CMDLINE/bin"
  mv "$TMP/cmdline-tools/lib" "$CMDLINE/lib"
  rm -rf "$TMP"
fi

# Drop env fragment so default/bash/envs picks it up
mkdir -p "$HOME/.config/dots/envs.d"
cat > "$HOME/.config/dots/envs.d/android.env" <<EOF
export ANDROID_HOME="$SDK"
export PATH="\$PATH:\$ANDROID_HOME/platform-tools:\$ANDROID_HOME/cmdline-tools/latest/bin"
EOF
