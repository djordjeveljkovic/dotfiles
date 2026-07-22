#!/usr/bin/env bash
# Entry point: base -> profile (desktop|server) -> opt flags
set -euo pipefail

DOTS="$HOME/.dots"
INSTALL="$DOTS/install"

if [[ ! -d "$DOTS" ]]; then
  echo "Clone the repo to ~/.dots first: git clone <repo> ~/.dots"
  exit 1
fi

# ---------------------------------------------------------------------------
# Parse args: positional profile + --flags
#   install.sh [desktop|server] [--nvidia] [--plymouth] [--bluetooth] ...
# If no profile arg, ask interactively.
# ---------------------------------------------------------------------------
PROFILE=""
OPTS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    desktop|server) PROFILE="$1"; shift ;;
    --*)            OPTS+=("$1"); shift ;;
    *)              echo "Unknown arg: $1"; exit 1 ;;
  esac
done

# Need gum (installed in 2-identification.sh, but ensure it's here for prompts)
if ! command -v gum &>/dev/null; then
  sudo pacman -S --needed --noconfirm gum >/dev/null
fi

if [[ -z "$PROFILE" ]]; then
  PROFILE=$(gum choose desktop server --header "Select install profile")
fi

if [[ -z "$PROFILE" ]]; then
  echo "No profile selected. Aborting."
  exit 1
fi

# Interactive opt-flag selection if none passed
if [[ ${#OPTS[@]} -eq 0 ]]; then
  SELECTED=$(gum choose --no-limit --header "Select optional add-ons (space to toggle, enter to confirm)" \
    "--nvidia" "--plymouth" "--bluetooth" "--printer" \
    "--android" "--flutter" "--antigravity" "--zed" "--ollama" "--pi" \
    "--screen-share" || true)
  while IFS= read -r line; do
    [[ -n "$line" ]] && OPTS+=("$line")
  done <<< "$SELECTED"
fi

# Expand --flutter -> also enable --android (Flutter mobile needs the Android SDK)
for o in "${OPTS[@]}"; do
  if [[ "$o" == "--flutter" ]]; then
    OPTS+=(--android)
  fi
done

run_step() {
  local label="$1"; shift
  echo
  gum style --bold --foreground 212 "==> $label"
  source "$@"
}

# ---------------------------------------------------------------------------
# 1. BASE (always)
# ---------------------------------------------------------------------------
BASE_SCRIPTS=(
  "$INSTALL/1-paru.sh"
  "$INSTALL/2-identification.sh"
  "$INSTALL/3-terminal.sh"
  "$INSTALL/4-config.sh"
  "$INSTALL/nvim.sh"
  "$INSTALL/development.sh"
  "$INSTALL/podman.sh"
  "$INSTALL/network.sh"
  "$INSTALL/power.sh"
)
for s in "${BASE_SCRIPTS[@]}"; do
  run_step "$(basename "$s")" "$s"
done

# ---------------------------------------------------------------------------
# 2. PROFILE
# ---------------------------------------------------------------------------
run_step "profile: $PROFILE" "$INSTALL/$PROFILE.sh"

# ---------------------------------------------------------------------------
# 3. OPT FLAGS
# ---------------------------------------------------------------------------
for flag in "${OPTS[@]}"; do
  name="${flag#--}"
  script="$INSTALL/opt-$name.sh"
  if [[ -f "$script" ]]; then
    run_step "opt: $flag" "$script"
  else
    gum style --foreground 3 "(skip) no installer for $flag"
  fi
done

# ---------------------------------------------------------------------------
# 4. Finalize
# ---------------------------------------------------------------------------
sudo updatedb

echo
gum style --bold --foreground 10 "Install complete."
echo
echo "Boot time (for your sub-14s target):"
systemd-analyze 2>/dev/null || true
echo
gum style --foreground 245 "Slowest units:"
systemd-analyze blame 2>/dev/null | head -10 || true

if gum confirm "Reboot to apply all settings?"; then
  reboot
fi
