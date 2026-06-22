#!/usr/bin/env bash
# opt --flutter: Flutter SDK at /opt/flutter.
# Depends on --android (auto-enabled by install.sh).
set -euo pipefail

FLUTTER_DIR="/opt/flutter"
if [[ ! -d "$FLUTTER_DIR" ]]; then
  sudo mkdir -p "$FLUTTER_DIR"
  sudo chown -R "$USER":"$USER" "$FLUTTER_DIR"
  echo "Cloning Flutter stable..."
  git clone --depth 1 --branch stable https://github.com/flutter/flutter.git "$FLUTTER_DIR"
fi

mkdir -p "$HOME/.config/dots/envs.d"
cat > "$HOME/.config/dots/envs.d/flutter.env" <<EOF
export PATH="$FLUTTER_DIR/bin:\$PATH"
EOF
