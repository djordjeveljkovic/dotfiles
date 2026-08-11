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
│              flutter,antigravity,zed,ollama,screen-share}.sh      #   (--flutter -> --android)
├── bin/                    # sway-native helper scripts
├── lib/helpers.sh          # shared helpers for script-manage-*
├── config/                 # symlinked into ~/.config/ at install time
├── default/                # bash/  sway/  gpg/  .tmux.conf
├── current/theme/          # ONE active theme (alacritty, mako, fuzzel, btop, waybar.css, sway.conf)
├── assets/                 # background + walls + plymouth image
└── .gitignore
```

## Profiles

| | Installs |
|---|---|
| **base** | paru, gum, eza/fzf/rg/fd/bat/zoxide, fastfetch, alacritty, nvim, rustup/clang/llvm/mise, node/npm/go, git/gh/lazygit/diff-so-fancy, tmux, podman+lazydocker, power-profiles-daemon, iwd |
| **server** | mariadb-libs, postgresql-libs, htop |
| **desktop** | sway, swaylock/idle/bg, waybar, fuzzel, mako, kanshi, autotiling, alacritty, yazi, btop, impala, bluetui, wiremix, pipewire/wireplumber/playerctl, brightnessctl, mpv, imv, grim/slurp/wlsunset, libnotify, swappy, imagemagick, jq, google-chrome, TTY autologin |

## Opt-in flags (each standalone, except `--flutter`→`--android`)

`--nvidia` · `--plymouth` · `--bluetooth` · `--printer` ·
`--android` · `--flutter` · `--antigravity` · `--zed` · `--ollama` · `--screen-share`

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

## Screenshots

Bindings in `default/sway/bindings`, both funneled through
`bin/script-screenshot`:

| Key | Action |
|---|---|
| `Mod+s` | region → save to `~/Pictures/screenshots` + clipboard |
| `Mod+Shift+s` | region → swappy annotate → save + clipboard |

`notify-send` (libnotify) confirms every action. The script also exposes
`region`, `output`, `window`, `clip`, `color`, `annotate`, `delay N <sub>`
subcommands — run `script-screenshot --help` or call it from the terminal
for the others.

## Screen sharing

`install/opt-screen-share.sh` installs the standard Wayland stack so apps
(Chrome, Discord, OBS, Firefox) can capture and share the screen in video
calls:

```
xdg-desktop-portal         # router / dbus interface
xdg-desktop-portal-wlr     # wlroots (sway) backend — Screenshot + ScreenCast
xdg-desktop-portal-gtk     # file/app chooser, notifications
```

Configs in `config/xdg-desktop-portal/`:

- `portals.conf` — pins `Screenshot` + `ScreenCast` (note the capital C) to
  the `wlr` backend so portal autodetect can't lose the race to `gtk`
  (which returns empty buffers on sway). Everything else (file picker,
  etc.) stays on `gtk`.
- `wlr-portal.conf` — sets `chooser_type=custom` and points
  `chooser_cmd` at `~/.dots/bin/script-share-chooser`, which:
  - For **Entire screen**: pops a fuzzel list of available outputs (no
    slurp drag-region). Click one.
  - For **Window**: pops a fuzzel list of toplevels with `[wsN]` labels
    pulled from `swaymsg -t get_tree`. This is important because
    wlr-portal's foreign-toplevel protocol on sway only returns the
    current workspace's windows — the custom chooser bypasses that by
    walking the sway tree directly, so you can share any window on any
    workspace. Caps framerate at 60 fps via `[screencast] max_fps=60`.

Sway already exports `WAYLAND_DISPLAY` + `XDG_CURRENT_DESKTOP=sway` via
`dbus-update-activation-environment` in `default/sway/autostart`, which is
all the env the portal needs — no sway restart required. The script just
installs packages, links configs, and restarts the portal so the new
backend takes effect.

## Pi coding-agent packages

Three public `djordjeveljkovic/pi-*` repos are installed under `~/.pi/agent/`:

```
~/.pi/agent/extensions/list-picker/   # TUI list component (peer dep)
~/.pi/agent/extensions/skill-manager/ # /skills commands, skill_list/toggle/reload tools
~/.pi/agent/extensions/workflow/      # /workflow quick|plan|ask + wf_* tools
~/.pi/agent/skills-library/           # 85 SKILL.md files across 10 collections
```

Reinstall with `gh repo clone …` + `(cd skill-manager && npm install)` + `(cd workflow && npm install)`; see `improvement.md §13` for details.
