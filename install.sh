#!/usr/bin/env bash
# Entry point: base -> profile (desktop|server) -> opt flags
#
# Compositor selection (when PROFILE=desktop) is driven by the
# DOTS_COMPOSITOR environment variable (sway | hyprland). If unset,
# the installer asks interactively. Compositor-specific packages and
# configs are then delegated to install/compositor-{sway,hyprland}.sh
# from install/desktop.sh.
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
#   install.sh desktop --compositor sway
#   install.sh desktop --compositor hyprland
# If no profile arg, ask interactively.
# ---------------------------------------------------------------------------
PROFILE=""
OPTS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    desktop|server) PROFILE="$1"; shift ;;
    --compositor)   DOTS_COMPOSITOR="$2"; shift 2 ;;
    --compositor=*) DOTS_COMPOSITOR="${1#--compositor=}"; shift ;;
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
    "--android" "--flutter" "--antigravity" "--zed" "--ollama" "--pi" || true)
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
if [[ $PROFILE == desktop ]]; then
    # Compositor picker: env var > interactive
    if [[ -z "${DOTS_COMPOSITOR:-}" ]]; then
        DOTS_COMPOSITOR=$(gum choose sway hyprland --header "Select compositor adapter")
    fi
    case "$DOTS_COMPOSITOR" in
        sway|hyprland) ;;
        *) echo "Unknown --compositor value: $DOTS_COMPOSITOR (expected sway|hyprland)"; exit 1 ;;
    esac
    export DOTS_COMPOSITOR
    # Persist the choice so subsequent steps (theme toggle, audit,
    # session entrypoint) pick the same adapter without an env var.
    mkdir -p "$HOME/.config/dots"
    printf '%s\n' "$DOTS_COMPOSITOR" > "$HOME/.config/dots/compositor"
    run_step "profile: desktop ($DOTS_COMPOSITOR)" "$INSTALL/desktop.sh"
else
    run_step "profile: $PROFILE" "$INSTALL/$PROFILE.sh"
fi

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
