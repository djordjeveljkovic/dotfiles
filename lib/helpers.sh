# ~/.dots/lib/helpers.sh
# Shared functions used by install/*.sh, bin/script-install, and
# bin/script-audit-system. This file is also auto-sourced by the
# top-level install.sh.

# ----------------------------------------------------------------------------
# podman helpers
# ----------------------------------------------------------------------------

# Check if a resource (container, network, volume) exists.
# Usage: resource_exists "container" "my-container-name"
resource_exists() {
    local type="$1"
    local name="$2"
    podman "$type" inspect "$name" &>/dev/null
}

# List all containers with user-friendly formatting.
list_all_containers() {
    podman ps -a --format "{{.Names}} ({{.Image}}) [{{.Status}}]"
}

# List only running containers.
list_running_containers() {
    podman ps --format "{{.Names}} ({{.Image}})"
}

# ----------------------------------------------------------------------------
# dependency checks
# ----------------------------------------------------------------------------

# Check for required commands.
# Usage: check_deps "gum" "jq" "yay"
check_deps() {
    local missing=0
    for cmd in "$@"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            printf 'missing dependency: %s\n' "$cmd" >&2
            missing=$((missing + 1))
        fi
    done
    if (( missing > 0 )); then
        printf '%d required command(s) not found; install them and retry.\n' "$missing" >&2
        return 1
    fi
}

# ----------------------------------------------------------------------------
# dots linking helpers
# ----------------------------------------------------------------------------

# Expand a path that may start with $HOME or be relative. Always returns an
# absolute path. Relative paths are interpreted as relative to $HOME, not $PWD,
# so the manifest can be applied from any directory.
dots_expand_home() {
    local p="$1"
    p="${p/#\$HOME/$HOME}"
    p="${p/#\~/$HOME}"
    case $p in
        /*) printf '%s' "$p" ;;
        *)  printf '%s/%s' "$HOME" "$p" ;;
    esac
}

# ----------------------------------------------------------------------------
# compositor detection / dispatch
# ----------------------------------------------------------------------------
# The active compositor is whatever ~/.config/dots/compositor holds, or
# the DOTS_COMPOSITOR env var, or auto-detected from running processes.
# Scripts and shared configs call `dots_compositor` instead of hardcoding
# swaymsg / hyprctl so that swapping adapters requires no script edits.

DOTS_COMPOSITOR_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/dots/compositor"

dots_compositor() {
    if [[ -n "${DOTS_COMPOSITOR:-}" ]]; then
        printf '%s' "$DOTS_COMPOSITOR"
        return 0
    fi
    if [[ -f "$DOTS_COMPOSITOR_FILE" ]]; then
        head -n1 "$DOTS_COMPOSITOR_FILE"
        return 0
    fi
    if pgrep -x Hyprland >/dev/null 2>&1; then
        echo hyprland; return 0
    fi
    if pgrep -x sway >/dev/null 2>&1; then
        echo sway; return 0
    fi
    echo sway  # safe default
}

# Run a compositor-specific IPC command. Usage:
#   dots_compositor_cmd reload
#   dots_compositor_cmd "output * bg /path/to/wall.jpg fill"
dots_compositor_cmd() {
    case "$(dots_compositor)" in
        sway)     swaymsg "$@" ;;
        hyprland) hyprctl "$@" ;;
        *)        echo "dots_compositor_cmd: unknown compositor" >&2; return 1 ;;
    esac
}

# Create a symlink at $link pointing to $target, backing up any existing
# destination unless the destination already correctly points at the target.
# Returns 0 if the link is in place, 1 on failure.
dots_link() {
    local target="$1"
    local link="$2"
    target=$(dots_expand_home "$target")
    link=$(dots_expand_home "$link")
    if [[ -L $link && $(readlink -- "$link") == "$target" ]]; then
        return 0
    fi
    if [[ -e $link || -L $link ]]; then
        local backup="${link}.dots-backup-$(date +%Y%m%d-%H%M%S)"
        mv -- "$link" "$backup"
        printf 'backed up %s -> %s\n' "$link" "$backup" >&2
    fi
    local parent
    parent=$(dirname -- "$link")
    if [[ ! -d $parent ]]; then
        mkdir -p "$parent"
    fi
    ln -s "$target" "$link"
}

# Sync every link declared in $DOTS_DIR/manifest/desktop.conf.
dots_apply_manifest() {
    : "${DOTS_DIR:=$HOME/.dots}"
    local manifest="${DOTS_DIR:-$HOME/.dots}/manifest/desktop.conf"
    [[ -f $manifest ]] || { printf 'manifest missing: %s\n' "$manifest" >&2; return 1; }
    while read -r kind live src _; do
        [[ -z $kind || $kind == \#* ]] && continue
        local live_expanded
        live_expanded=$(dots_expand_home "$live")
        local src_expanded="$DOTS_DIR/$src"
        if [[ ! -e $src_expanded ]]; then
            printf 'skip %s (missing source: %s)\n' "$live_expanded" "$src_expanded" >&2
            continue
        fi
        case $kind in
            link) dots_link "$src_expanded" "$live_expanded" ;;
            file)
                local parent
                parent=$(dirname -- "$live_expanded")
                [[ ! -d $parent ]] && mkdir -p "$parent"
                cp -- "$src_expanded" "$live_expanded"
                ;;
        esac
    done <"$manifest"
}

# Idempotently enable a system systemd unit.
dots_systemctl_enable() {
    local unit="$1"
    systemctl is-enabled "$unit" 2>/dev/null | grep -q '^enabled$' || sudo systemctl enable "$unit"
}

# Idempotently disable a system systemd unit.
dots_systemctl_disable() {
    local unit="$1"
    systemctl is-enabled "$unit" 2>/dev/null | grep -q '^disabled$' || sudo systemctl disable "$unit"
}
