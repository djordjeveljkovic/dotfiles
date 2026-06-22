# ~/.dots

Minimal, sway-only, profile-aware Arch Linux dotfiles. Bootstraps a usable
system in one command, with a `desktop` (sway) and `server` (headless) profile.

See [`improvement.md`](./improvement.md) for the full design rationale and the
list of decisions made during the refactor.

---

## Quick start (fresh Arch box)

```bash
# 1. one-liner bootstrap (gets you paru + a shell ready to clone)
sudo pacman -S --needed --noconfirm base-devel git curl
curl -fsSL https://aur.archlinux.org/paru.bin.git | ...   # or your usual paru install

# 2. clone + run the profile installer
git clone git@github.com:djordjeveljkovic/dotfiles.git ~/.dots
~/.dots/install.sh            # prompts for profile + opt flags via gum
#   or non-interactive:
~/.dots/install.sh desktop --nvidia --bluetooth

# 3. reboot (desktop auto-logs into sway on tty1; server stays on tty)
```

## Layout

```
~/.dots/
├── install.sh              # entry: base -> desktop|server -> opt flags
├── install/
│   ├── 1-paru.sh  2-identification.sh  3-terminal.sh  4-config.sh   # base
│   ├── nvim.sh  development.sh  podman.sh  network.sh  power.sh     # base
│   ├── desktop.sh  server.sh                                       # profile
│   ├── mimetype.sh                                                 # sourced by desktop.sh
│   └── opt-{nvidia,plymouth,bluetooth,printer,android,             # opt leaves
│              flutter,antigravity,zed,ollama}.sh                   #   (--flutter -> --android)
├── bin/                    # sway-native helper scripts
├── lib/helpers.sh          # shared helpers for script-manage-*
├── config/                 # symlinked into ~/.config/ at install time
├── default/                # bash/  sway/  gpg/  .tmux.conf
├── current/theme/          # ONE active theme (alacritty, mako, btop, waybar.css, sway.conf)
├── assets/                 # background + walls + plymouth image
└── .gitignore
```

## Profiles

| | Installs |
|---|---|
| **base** | paru, gum, eza/fzf/rg/fd/bat/zoxide, fastfetch, alacritty, nvim, rustup/clang/llvm/mise, node/npm/go, git/gh/lazygit/diff-so-fancy, tmux, podman+lazydocker, power-profiles-daemon, iwd |
| **server** | mariadb-libs, postgresql-libs, htop |
| **desktop** | sway, swaylock/idle/bg, waybar, fuzzel, mako, swayosd, kanshi, autotiling, alacritty, yazi, btop, impala, bluetui, wiremix, pipewire/wireplumber/playerctl, brightnessctl, mpv, imv, grim/slurp/wlsunset, google-chrome, TTY autologin |

## Opt-in flags (each standalone, except `--flutter`→`--android`)

`--nvidia` · `--plymouth` · `--bluetooth` · `--printer` ·
`--android` · `--flutter` · `--antigravity` · `--zed` · `--ollama`

## Secrets

API keys live in `~/.config/secrets.env` (gitignored, chmod 600), sourced by
`default/bash/envs`. The installer creates an empty one for you to fill in.

## Boot speed target

Sub-14s via: no display manager (TTY autologin), no Plymouth by default,
`quiet loglevel=0` kernel params, minimal enabled services, network wait
patched to `--any`. `install.sh` prints `systemd-analyze blame` at the end.

## Configs symlink, not copy

`install/4-config.sh` symlinks each `~/.dots/config/*` into `~/.config/`, so
editing a config edits the repo directly and `git pull` applies instantly.
