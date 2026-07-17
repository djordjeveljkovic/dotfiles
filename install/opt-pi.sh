#!/usr/bin/env bash
# pi coding-agent setup: clones the three pi-* repos into ~/.pi/agent/
# and registers the extensions in settings.json.
# Idempotent — re-running just re-pulls and re-registers.
set -euo pipefail

PI_AGENT="$HOME/.pi/agent"
EXT_DIR="$PI_AGENT/extensions"
SETTINGS="$PI_AGENT/settings.json"
GITHUB_USER="${PI_GITHUB_USER:-djordjeveljkovic}"

require() { command -v "$1" >/dev/null 2>&1 || { echo "missing: $1" >&2; exit 1; }; }
require gh
require npm
require node

mkdir -p "$EXT_DIR"

# --- Clone (or pull) the three repos -----------------------------------
clone_or_pull() {
    local repo="$1" dest="$2"
    if [[ -d "$dest/.git" ]]; then
        echo "==> updating $repo"
        git -C "$dest" pull --ff-only || echo "    (pull skipped — local changes or no upstream)"
    else
        echo "==> cloning $repo -> $dest"
        rm -rf "$dest"
        gh repo clone "$GITHUB_USER/$repo" "$dest"
    fi
}

clone_or_pull pi-list-picker    "$EXT_DIR/list-picker"
clone_or_pull pi-skill-manager  "$EXT_DIR/skill-manager"
clone_or_pull pi-skills-library "$PI_AGENT/skills-library"

# --- Install skill-manager deps (pulls pi-list-picker + typebox) ------
echo "==> npm install in skill-manager"
(cd "$EXT_DIR/skill-manager" && npm install --omit=dev)

# --- Register extensions in settings.json -----------------------------
mkdir -p "$PI_AGENT"
if [[ ! -f "$SETTINGS" ]]; then
    echo '{}' > "$SETTINGS"
fi

node - <<NODE
const fs = require('fs');
const file = process.env.SETTINGS;
const settings = JSON.parse(fs.readFileSync(file, 'utf8'));
settings.extensions = settings.extensions || [];
const want = [
  'extensions/skill-manager',
  'extensions/list-picker/extension.ts',
];
let changed = false;
for (const e of want) {
  if (!settings.extensions.includes(e)) {
    settings.extensions.push(e);
    changed = true;
  }
}
fs.writeFileSync(file, JSON.stringify(settings, null, 2) + '\n');
console.log(changed ? '==> settings.json: extensions added' : '==> settings.json: already up to date');
NODE

echo
echo "Pi setup complete. Reload pi with /reload to activate:"
echo "  /skills                 list enabled skills"
echo "  /skills:list            TUI: browse + toggle + filter"
echo "  /skills:manage          enable/disable/all/reset"
echo "  /skills:status          library path + counts"
echo
echo "Installed under:"
echo "  $EXT_DIR/list-picker/"
echo "  $EXT_DIR/skill-manager/"
echo "  $PI_AGENT/skills-library/   (85 SKILL.md files)"