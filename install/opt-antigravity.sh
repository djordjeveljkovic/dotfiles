#!/usr/bin/env bash
# opt --antigravity: Google Antigravity IDE (standalone downloaded binary).
set -euo pipefail

DEST="$HOME/Downloads/antigravity"
mkdir -p "$DEST"

# Download URL changes per release; this is a best-effort fetch.
# If it fails, see https://anthropic.com/antigravity or your account for the current link.
URL="${ANTIGRAVITY_URL:-}"
if [[ -z "$URL" ]]; then
  echo "Set ANTIGRAVITY_URL to the current download URL, then re-run."
  echo "  ANTIGRAVITY_URL=https://... install.sh --antigravity"
  exit 0
fi

curl -fsSL "$URL" -o "$DEST/antigravity.tar.gz"
tar -xzf "$DEST/antigravity.tar.gz" -C "$DEST"
rm -f "$DEST/antigravity.tar.gz"
chmod +x "$DEST/Antigravity/antigravity" 2>/dev/null || true

echo "Antigravity installed to $DEST/Antigravity/antigravity"
echo "Uncomment the SUPER+Mod1+a binding in default/sway/bindings to launch it."
