#!/usr/bin/env bash
# ~/.dots/install/4-config.sh
# Replaces the old cp -R based install. This script:
#  1. links every managed destination listed in manifest/desktop.conf
#  2. deploys ~/.dots/default/.tmux.conf -> ~/.tmux.conf
#  3. deploys ~/.dots/default/sshconfig -> ~/.ssh/config (0600)
#  4. deploys GPG keyserver config
#  5. points ~/.bashrc at ~/.dots/default/bash/rc
#  6. enables the dots-owned user systemd units from
#     config/systemd/user/ (battery-monitor, time-notify) and reloads the
#     user systemd manager.
#
# The script is idempotent. Re-running it should print no changes after
# the first successful run.

set -e

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dots}"
MANIFEST="$DOTFILES_DIR/manifest/desktop.conf"

# shellcheck disable=SC1091
. "$DOTFILES_DIR/lib/helpers.sh"

[[ -f $MANIFEST ]] || { echo "manifest not found: $MANIFEST" >&2; exit 1; }

# 1. Managed links
dots_apply_manifest

# 2. ~/.tmux.conf
if [[ ! -L $HOME/.tmux.conf || $(readlink "$HOME/.tmux.conf") != "$DOTFILES_DIR/default/.tmux.conf" ]]; then
    [[ -e $HOME/.tmux.conf && ! -L $HOME/.tmux.conf ]] && \
        mv "$HOME/.tmux.conf" "$HOME/.tmux.conf.dots-backup-$(date +%Y%m%d-%H%M%S)"
    ln -s "$DOTFILES_DIR/default/.tmux.conf" "$HOME/.tmux.conf"
fi

# 3. ~/.ssh/config
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
if [[ ! -L $HOME/.ssh/config || $(readlink "$HOME/.ssh/config") != "$DOTFILES_DIR/default/sshconfig" ]]; then
    [[ -e $HOME/.ssh/config && ! -L $HOME/.ssh/config ]] && \
        mv "$HOME/.ssh/config" "$HOME/.ssh/config.dots-backup-$(date +%Y%m%d-%H%M%S)"
    ln -s "$DOTFILES_DIR/default/sshconfig" "$HOME/.ssh/config"
fi
chmod 600 "$HOME/.ssh/config"

# 4. GPG keyserver config
if ! diff -q "$DOTFILES_DIR/default/gpg/dirmngr.conf" /etc/gnupg/dirmngr.conf >/dev/null 2>&1; then
    sudo mkdir -p /etc/gnupg
    sudo cp "$DOTFILES_DIR/default/gpg/dirmngr.conf" /etc/gnupg/dirmngr.conf
    sudo chmod 644 /etc/gnupg/dirmngr.conf
    sudo gpgconf --kill dirmngr || true
    sudo gpgconf --launch dirmngr || true
fi

# 5. ~/.bashrc -> ~/.dots/default/bash/rc (single include)
if [[ ! -L $HOME/.bashrc || $(readlink "$HOME/.bashrc") != "$DOTFILES_DIR/default/bash/rc" ]]; then
    [[ -e $HOME/.bashrc && ! -L $HOME/.bashrc ]] && \
        mv "$HOME/.bashrc" "$HOME/.bashrc.dots-backup-$(date +%Y%m%d-%H%M%S)"
    ln -s "$DOTFILES_DIR/default/bash/rc" "$HOME/.bashrc"
fi

# 6. User systemd units
mkdir -p "$HOME/.config/systemd/user"
for unit in battery-monitor.service battery-monitor.timer time-notify.service time-notify.timer; do
    src="$DOTFILES_DIR/config/systemd/user/$unit"
    dest="$HOME/.config/systemd/user/$unit"
    [[ -f $src ]] || continue
    if [[ ! -L $dest || $(readlink "$dest") != "$src" ]]; then
        [[ -e $dest && ! -L $dest ]] && rm -f "$dest"
        ln -s "$src" "$dest"
    fi
done

systemctl --user daemon-reload
systemctl --user enable --now battery-monitor.timer 2>/dev/null || true
systemctl --user enable --now time-notify.timer 2>/dev/null || true

# 7. Common git identity defaults (used by `git config --global` later).
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global pull.rebase true
git config --global init.defaultBranch main

# 8. Apply Catppuccin dark theme by default on fresh installs.
if ! "$DOTFILES_DIR/bin/script-toggle-theme" dark 2>/dev/null; then
    "$DOTFILES_DIR/bin/script-toggle-theme" >/dev/null || true
fi
