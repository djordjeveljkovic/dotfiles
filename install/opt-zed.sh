#!/usr/bin/env bash
# opt --zed: Zed editor + its UI font (CaskaydiaMono Nerd Font). Standalone.
set -euo pipefail

paru -S --noconfirm --needed ttf-caskaydia-mono-nerd

# Zed ships a curl installer
if ! command -v zed &>/dev/null; then
  curl -f https://zed.dev/install.sh | sh
fi
