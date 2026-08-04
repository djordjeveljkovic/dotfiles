# Current Setup

This document outlines everything currently installed and configured from this
`~/.dots` repository. The dotfiles target a fresh **Arch Linux** install and
bootstrap a fully working Wayland desktop, dev environment, and container
toolchain in a single run via `install.sh`.

---

## Architecture: shared + compositor adapters

The configuration is **compositor-neutral by design**: everything that does not
intrinsically depend on a compositor's IPC lives under `bin/`, `config/` (with
`config/hypr/` and `config/sway/` as thin adapters), and `default/bash/`.
Compositor-specific syntax (Sway's `bindsym`, Hyprland's `bind = ...`) and
IPC commands (`swaymsg`, `hyprctl`) live in their respective adapter.

```
~/.dots/
├── install.sh                      # Entry point; asks for desktop|server + compositor
├── install/
│   ├── desktop.sh                  # Shared Wayland base; dispatches to a compositor adapter
│   ├── compositor-sway.sh          # Sway-only packages + adapter marker
│   ├── compositor-hyprland.sh      # Hyprland-only packages + adapter marker
│   └── ...                         # per-feature installers
├── bin/
│   ├── dots-session                # Universal session entrypoint (calls sway|Hyprland)
│   ├── script-apply-waybar-compositor  # Rewrites waybar workspaces module
│   └── script-*                    # Compositor-neutral scripts (use dots_compositor)
├── lib/
│   └── helpers.sh                  # dots_compositor + dots_compositor_cmd dispatch
├── config/                         # Shared app configs (waybar, mako, git, nvim, ...)
│   ├── hypr/                       # Thin Hyprland adapter (symlinks into ~/.config/hypr)
│   └── sway/                       # Default Sway adapter (linked to ~/.config/sway)
├── default/
│   ├── bash/                       # Compositor-neutral shell setup (rc, envs)
│   ├── sway/                       # Sway source files (linked via default/sway → config/sway)
│   ├── hypr/                       # Hyprland source files
│   ├── gpg/                        # Shared GPG config
│   └── sshconfig                   # Shared SSH config
├── manifest/
│   └── desktop.conf                # Source-of-truth for which paths get linked
├── themes/                         # Catppuccin (dark) + Catppuccin Latte (light)
└── current/theme                   # Active theme symlink (toggled by bin/script-toggle-theme)
```

The active compositor is selected by `DOTS_COMPOSITOR` (env var) or by the
interactive prompt in `install.sh`. The choice is persisted to
`~/.config/dots/compositor` and read by `dots_compositor` so that scripts and
session entrypoints pick the right adapter without needing the env var set.

To switch adapters after installation:

```bash
# Install the other compositor's packages and reload the session
sudo bash ~/.dots/install/compositor-sway.sh
# or
sudo bash ~/.dots/install/compositor-hyprland.sh

# Pick which one boots on tty1
echo sway | sudo tee ~/.config/dots/compositor
# or
echo hyprland | sudo tee ~/.config/dots/compositor
```

---

## OS & Base System

- **Distribution:** Arch Linux (rolling)
- **User:** `usrtmp` (id is sourced dynamically in scripts via `$(id -u)`)
- **Package manager:** `pacman` + `yay` (AUR helper installed in `1-yay.sh`)
- **pacman configured with:** `Color`, `ILoveCandy`, multilib repo enabled
  (by `nvidia.sh` when an NVIDIA GPU is detected)
- **Locate database:** refreshed at end of install via `sudo updatedb`

---

## Boot & Login

| Component | What it does |
|---|---|
| **Plymouth** (`plymouth.sh`) | Splash screen using `bgrt` theme with a custom image (`plymouth_image.png`). `splash quiet` is appended to the kernel cmdline (supports systemd-boot, GRUB, and UKI layouts). |
| **GRUB** (`grub`) | Hidden 0-timeout GRUB config; `quiet loglevel=0 splash`; console terminal; ext4 root. |
| **seamless-login** (`login.sh`) | A small C binary that switches the VT to TTY1, sets KD_GRAPHICS, and clears the screen — replicates SDDM's seamless transition into Hyprland. Installed to `/usr/local/bin/seamless-login`. |
| **minimal-seamless-login.service** | systemd user-spawned service that auto-logs into Hyprland via `uwsm start -- hyprland.desktop`. Conflicts with `getty@tty1.service`. |
| **plymouth-quit.service** | Made to wait for `multi-user.target`; `plymouth-quit-wait.service` is masked. |
| **getty@tty1** | Disabled in favor of the seamless auto-login. |

---

## Display Server / Compositor

The active compositor is **Hyprland**, with a parallel **Sway** config kept in
`default/sway/` as an alternative.

### Hyprland (`default/hypr/` + `config/hypr/`)
- `hyprland.conf` sources: `autostart`, `media`, `envs`, `looknfeel`,
  `input`, `windows`, `monitors`, plus the active theme.
- **Variables:** `gaps_in/out = 0`, `border_size = 0`, `rounding = 0`,
  `layout = master`, blur **off**, animations **off**, tearing **off**,
  `resize_on_border = false`.
- **Input:** keyboard layouts `us,rs,rs` (variant `,latin,`);
  options `ctrl:nocaps, altwin:menu_win, altwin:altgr`; repeat rate 40,
  delay 600; touchpad natural scroll + clickfinger; pointer accel 0.
- **Monitors:** defined in `default/hypr/monitors/*.conf` and auto-aggregated
  by `default/hypr/monitors.conf`. eDP-1 is 1920×1200@60 offset to the left;
  HDMI-A-1 is 1920×1080@60 at (0,0).
- **Wayland envs:** `GDK_BACKEND=wayland,x11,*`, `QT_QPA_PLATFORM=wayland;xcb`,
  `QT_STYLE_OVERRIDE=kvantum`, `SDL_VIDEODRIVER=wayland`, `MOZ_ENABLE_WAYLAND=1`,
  `ELECTRON_OZONE_PLATFORM_HINT=wayland`, `OZONE_PLATFORM=wayland`,
  `XDG_SESSION_TYPE=wayland`, `XDG_CURRENT_DESKTOP=Hyprland`,
  `XCOMPOSEFILE=~/.XCompose`, `XCURSOR_SIZE=24`, `HYPRCURSOR_SIZE=24`.
- **Window rules:** all windows get `suppress_event = maximize`; `FloatingWindow`
  class is centered at 75%; portal file dialogs float at 1200×800; monitor manager
  is centered 519×439; default opacity 0.95/0.92; chrome/firefox 0.97/0.94;
  zoom/vlc/mpv/imv/jetbrains-phpstorm fully opaque; the "is sharing your screen"
  indicator is moved 1 000 000 px off-screen.
- **Media workspaces:** `youtube` and `music` workspaces auto-launch
  `ghostty -e youtube-tui` and fullscreen `youtube-tui` / `mpv` windows.
- **Submap `MOVE_RESIZE`** (toggled with `SUPER+R`): hjkl moves 20px,
  `ALT+hjkl` resizes 20px, `SHIFT+hjkl` does both, `f` fullscreens, `ESC`
  exits.

### Sway (`default/sway/`)
Parallel config with the same logical layout. Uses `autotiling`, `swayidle`,
`swaylock`, `swaybg`. SwayFX-only opacity rules are included and silently
ignored on plain Sway.

---

## Status Bar, Launcher, Notifications, OSD, Lock

| Tool | Config | Notes |
|---|---|---|
| **Waybar** | `config/waybar/{config,style.css}` | Top bar. Modules left: Hyprland workspaces. Center: clock (`%A %H:%M`, alt `%d %B W%V %Y`). Right: network, pulseaudio, bluetooth, battery. Click actions open btop / impala / bluetui / wiremix. Imports theme colors via `@import` from `current/theme/waybar.css`. |
| **Wofi** | `config/wofi/{config,style.css}` | App launcher (`drun`), centered, 600×350, dark, with image icons. 5-line fuzzel-style menu is launched from Hyprland. |
| **Fuzzel** | (no config) | Used by keybindings for power menu, wallpaper, monitors, bluetooth. |
| **Mako** | `config/mako/config → current/theme/mako.ini` | Notifications. Hidden when `do-not-disturb` mode is on; `notify-send` still shown. Spotify notifications suppressed. Top-right, border 2px, Catppuccin palette. |
| **swayosd** | autostarted | Volume / brightness / mic / media-key OSD. |
| **hypridle** | `config/hypr/hypridle.conf` | Lock at 5 min, screen off at 5.5 min (`dpms off`); resume restores display and resets brightness. |
| **hyprlock** | `config/hypr/hyprlock.conf` | CaskaydiaMono Nerd Font, 32px; fingerprint auth **enabled** via `fprintd`. Theme pulled from `current/theme/hyprlock.conf`. |
| **swayidle / swaylock** | `default/sway/autostart` | Sway-variant idle / lock. |

---

## Wallpaper & Visuals

- **hyprpaper** autostarted (`default/hypr/autostart.conf`); preload then
  apply with empty monitor name to set on all outputs.
- `bin/script-wallpaper` uses **yazi** to pick from `~/Pictures/walls`,
  preloads the selection in hyprpaper, applies to all monitors, and copies
  the file to `~/.dots/background` so the next boot keeps it.
- `current/background` is a 0-byte placeholder; the actual image lives at
  `~/.dots/background` (~1 MB).
- The two wallpapers in `current/walls/` are `back.jpg` and `back2.jpg`.

---

## Terminal & Shell

### Terminals
- **Alacritty** (`config/alacritty/alacritty.toml`) — primary terminal
  (15pt Fira Code Nerd Font, opacity 0.9, no decorations, padding 10×3,
  F11 fullscreen, Ctrl-J/K scroll).
- **Ghostty** — used for `yazi`/`script-wallpaper`/media workspaces.

### Bash (`default/bash/`)
The user's `~/.bashrc` is replaced with a single `source ~/.dots/default/bash/rc`
that pulls in:

| File | Purpose |
|---|---|
| `prompt` | PS1 with working dir, git branch + staged/changed/behind counts, and SSH hostname. |
| `shell` | `shopt -s histappend`, `HISTCONTROL=ignoreboth`, `HISTSIZE=32768`, bash-completion, `set +h`. |
| `aliases` | `ls=eza -lh --group-directories-first --icons=auto`, `lt=eza --tree`, `ff=fzf+bat`, `cd=zd` (uses zoxide), `open=xdg-open`, `n=nvim`, `g=git`, `gcm/gcam/gcad`, and `yays` (yay+fzf package installer). |
| `functions` | `compress`, `iso2sd`, `format-drive`, `transcode-video-1080p`, `transcode-video-4K`, `img2jpg`, `img2jpg-small`, `img2png`. |
| `init` | Activates `mise`, `zoxide`, and `fzf` (completion + key-bindings). |
| `envs` | See *Environment* below. |
| `music` | `playlist-play`, `song-play`, `playlist-dl-play` — yt-dlp + mpv streaming. |
| `inputrc` | Readline tweaks: history-search on arrows, case-insensitive completion, `mark-symlinked-directories`, `visible-stats`, `colored-stats`. |

### Environment (`default/bash/envs`)
- `EDITOR=nvim`, `SUDO_EDITOR=$EDITOR`
- `HYPRSHOT_DIR=$HOME/Pictures/screenshots/`
- `ANDROID_HOME=$HOME/Android/Sdk` (+ platform-tools and cmdline-tools on PATH)
- `DOCKER_HOST=unix:///run/user/$(id -u)/podman/podman.sock`
- **PATH additions:** `~/.local/bin`, `~/.dots/bin`, `./bin`, `~/go/bin`,
  `~/.cargo/bin`, `~/.npm-global/bin`, `~/.config/composer/vendor/bin`,
  `~/ai/llama.cpp/build/bin`, `~/usr/bin`, `~/.cache/.bun/bin`,
  `~/Android/Sdk/platform-tools`, `~/Android/Sdk/cmdline-tools/latest/bin`,
  `/opt/flutter/bin`.

---

## Keybindings (Hyprland)

`SUPER` = Mod4 (Windows key). See `default/hypr/bindings.conf` and
`media.conf` for the full list; the highlights:

### Applications
- `SUPER+Return` → alacritty
- `SUPER+B` → google-chrome-stable
- `SUPER+G` → steam
- `SUPER+A` → chatgpt (webapp), `SUPER+SHIFT+A` → gemini,
  `SUPER+ALT+A` → Antigravity (Google's AI IDE at
  `~/Downloads/antigravity/Antigravity/antigravity`)
- `SUPER+E` → yazi (floating), `SUPER+T` → btop, `SUPER+Z` → impala,
  `SUPER+X` → wiremix, `SUPER+C` → bluetui, `SUPER+SHIFT+C` → calcure,
  `SUPER+D` → lazydocker (with `DOCKER_HOST` set for podman),
  `SUPER+grave` → `script-manage` (gum-driven podman hub)

### System
- `SUPER+SPACE` → fuzzel (5 lines), `SUPER+SHIFT+SPACE` → reload waybar
- `SUPER+ESCAPE` → power menu (lock / suspend / relaunch / restart / shutdown)
- `SUPER+N` → toggle `hyprsunset` (-g 50% -t 4000k)
- `SUPER+I` → `script-info` (compiled Rust binary, ~15 MB system-info viewer)
- `SUPER+CTRL+I` → toggle hypridle, `SUPER+SHIFT+P` → monitor picker
  (compiled ~14 MB binary), `SUPER+V` → cliphist in fuzzel

### Media keys
Volume / mute / mic / brightness / play / next / prev all routed through
`bin/script-audio`, `bin/script-brightness`, `bin/script-media` —
each calls `wpctl` / `brightnessctl` / `playerctl` and shows an OSD
notification via mako (no swayosd). `ALT+SHIFT_L` cycles XKB layout
through `bin/script-notify-layout`, which dispatches via
`dots_compositor_cmd` (swaymsg / hyprctl) and shows a mako notification
of the new keymap.

### Screenshots & picker
- `PRINT` → region, `SHIFT+PRINT` → window, `CTRL+PRINT` → output
  (via `hyprshot`); `SUPER+PRINT` and `SUPER+ALT+S` → `hyprpicker -a`

### Windows
- `SUPER+W` close, `SUPER+F` float + center, `SUPER+O` cycle orientation
- `SUPER+hjkl/arrows` focus; `SUPER+SHIFT+hjkl/arrows` swap
- `SUPER+R` enters `MOVE_RESIZE` submap (move 20px, `ALT+...` resize,
  `SHIFT+...` combined)
- `ALT+TAB` cycle next window and bring to top
- 10 workspaces on `SUPER+1..0`; move window with `SUPER+SHIFT+1..0`
- `SUPER+mouse_up/down` and `SUPER+TAB` → `workspace-cycle`
- `SUPER+mouse:272` move, `SUPER+mouse:273` resize
- `SUPER+SHIFT+M` → music workspace, `SUPER+SHIFT+Y` → youtube workspace

### Notifications
- `SUPER+,` dismiss latest, `SUPER+SHIFT+,` dismiss all,
  `SUPER+CTRL+,` toggle do-not-disturb with notify-send confirmation

### Vimium (Chrome)
Stored in `config/vimium-options.json`. Remaps `z` → scrollDown, `x` → scrollUp,
`a` → back, `s` → forward, `m` → mute. Per-site pass-keys for Gmail, RAF
learning portal, YouTube, Discord/Google Drive, several anime/streaming
mirrors (hianime, gogoanime, anitaku, kisskh, cineb, etc.), Hetzner Cloud,
and others.

---

## Editors & Dev Tools

### Neovim — two configs kept side by side

**1. `config/nvim/` — the main config (older, 0.10-era)**
- `init.lua` requires `config.lsp`, `config.mason-path`, `config.lazy`,
  `config.options`, `config.keymaps`, `config.terminal`, then
  `colorscheme catppuccin` and `config.transperent`.
- `lazy-lock.json` plugins:
  `lazy.nvim`, `catppuccin/nvim` (macchiato, transparent, no bold/italic),
  `rose-pine/neovim`, `tokyonight.nvim`,
  `blink.cmp` (completion) + `LuaSnip` + `friendly-snippets`,
  `telescope.nvim` + `telescope-fzf-native.nvim`,
  `nvim-treesitter` + `nvim-treesitter-textobjects` + `nvim-ts-autotag`
  + `nvim-ts-context-commentstring`,
  `harpoon`, `trouble.nvim`, `snacks.nvim`, `noice.nvim`,
  `conform.nvim`, `nvim-lint`, `tiny-inline-diagnostic.nvim`,
  `fidget.nvim`, `nvim-notify`, `nvim-spectre`, `Comment.nvim`,
  `plenary.nvim`, `lazydev.nvim`, `mason.nvim`, `laravel.nvim`.
- LSP servers (defined in `config/nvim/lsp/`): `css-ls`, `gopls`, `html-ls`,
  `intelephense` (PHP), `lua-ls`, `rust-analyzer`, `tailwindcss`, `ts-ls`,
  `vue-ls`, `zls`.
- Editor options: line numbers + relative, 4-space soft tabs, smart indent,
  `ignorecase`+`smartcase`, `incsearch` on, `hlsearch` off.

**2. `config/nvim012/` — a Neovim 0.12 prototype**
- Modular layout: `lua/config/{options,keymaps,autocmds,statusline,terminal}.lua`
  + `lua/plugins/{init,completion,fzf,gitsigns,mini,nvimtree,treesitter,lsp}.lua`.
- Uses `mini.nvim`, `fzf-lua`, `nvim-tree.lua`, `nvim-lspconfig`,
  `mason.nvim`, `gitsigns.nvim`, `blink.cmp`, `LuaSnip`,
  `friendly-snippets`, `efmls-configs-nvim`. Locked with
  `nvim-pack-lock.json`.
- Default colorscheme `habamax`, transparent UI groups.

### Zed (`config/zed/settings.json`)
- **Vim mode** on, **telemetry off**, **auto-update off**, **autosave** at 1 s.
- Theme: `Catppuccin Mocha` (dark) / `Catppuccin Latte` (light) with custom
  border overrides to `#15141c`; icons `Soft Charmed Icons` (dark).
- UI font: CaskaydiaMono Nerd Font 18pt; buffer font: Ubuntu Mono
  Ligaturized 20pt; tab size 4; hidden tab bar, status bar, toolbar, title
  bar elements; no scrollbars, no folds, no gutter line numbers;
  `auto_indent_on_paste = false`; `show_completions_on_input = false`.
- **Edit predictions** wired to local **Ollama** model `qwen2.5-coder:7b-base`,
  max 64 output tokens.

### Languages & Runtimes
- `rustup`, `clang`, `llvm`, `mise` (version manager, activated in bash)
- Node (npm), Go, Bun (`~/.cache/.bun/bin`), Composer, ShellCheck
- `tree-sitter-cli`, `cmake`, `luarocks`
- MariaDB libs, PostgreSQL libs (for podman DB containers)
- **Flutter** at `/opt/flutter/bin`
- **Android SDK** expected at `~/Android/Sdk` (cmdline-tools + platform-tools)

### Git (`config/git/config`, `ignore`, `template`)
- Identity: `Djordje Veljkovic` <djveljkovic3019rn@raf.rs>, GitHub user
  `djordjeveljkovic`.
- `core.compression=9`, `core.whitespace=error`, `core.preloadindex=true`.
- `init.defaultBranch=dev` (overrides installer default `main`).
- `status` shows branch + stash + untracked, `diff` uses 3 context lines,
  renames+copies, inner-hunk 10.
- **URL rewrites:** `dj:` → `git@github.com:djordjeveljkovic/`,
  `gh:` → `git@github.com:`.
- **Pagers:** `diff=diff-so-fancy | $PAGER`, `branch=false`, `tag=false`;
  `diff-so-fancy.markEmptyLines=false`; interactive `singleKey=true`.
- **Push:** `autoSetupRemote=true`, `default=current`.
- **Pull:** `default=current`, `rebase=true`; rebase `autoStash=true`,
  `missingCommitsCheck=warn`.
- **Log/branch/tag** sorted by date; branch sorting by committerdate.
- **Colored blame** with time-based gradient; colored branch/diff.
- `.gitignore` shipped: Python caches, `target/`, `zig-cache`, `node_modules`,
  `.env`.
- Commit template: conventional-commit checklist (`feat:`, `fix:`, `style:`,
  `ci:`, `chore:`, `docs:`, `refactor:`, `perf:`, `test:`, `debug:`,
  `BREAKING CHANGE:`).
- Installed tools: `git`, `github-cli` (gh), `lazygit`, `diff-so-fancy`,
  `tmux` with **TPM** plugin manager.

### Tmux (`default/.tmux.conf`)
- Prefix `C-s`, base index 1, history 25 000, mouse off, 10 ms escape-time,
  vi copy-mode keys, `screen-256color`.
- Status bar at top: empty left, `%H:%M` right, Catppuccin-tinted styles
  (`#c6d0f5` / `#a6adc8` / `#b4befe`).
- Splits `v` (h) / `a` (v) inherit pane cwd; `hjkl` move;
  `C-h` / `C-l` cycle windows; `prefix r` reloads the config.
- TPM bootstrap: `set -g @plugin 'tmux-plugins/tpm'` + `run '~/.tmux/plugins/tpm/tpm'`.

---

## Containers (Podman, rootless)

No Docker — `install/docker.sh` is in fact a **Podman** setup script.

- Installs `podman` + `podman-compose`.
- Enables and starts `podman.service` and `podman.socket` (Docker-compatible
  socket at `unix:///run/user/<uid>/podman/podman.sock`).
- Drops a `~/.config/containers/containers.conf` with `json-file` log driver,
  10 MiB size cap, 5 rotated files.
- Exports `DOCKER_HOST=unix://$XDG_RUNTIME_DIR/podman/podman.sock` so the
  Docker CLI / lazydocker / docker-compose work transparently.
- Runs a `hello-world` test container to verify.

### `bin/script-manage` (and `bin/lib/helpers.sh`)
A `gum`-driven hub that discovers every `bin/script-manage-*` script and
presents them as a menu. Currently includes:

- `script-manage-database` — interactive create/list/delete for
  **MariaDB / PostgreSQL / MongoDB / Redis** containers, with persistent
  named volumes and configurable network.
- `script-manage-database-managment` — DB management utilities.
- `script-manage-network` — list/create/delete podman networks; supports
  `--select` mode for other scripts to pick host vs. custom network.
- `script-manage-php` — install/switch PHP versions (main repo + AUR
  `phpXY` packages), uses `/usr/local/bin/php` symlink to switch.

Other container-adjacent helpers:
- `script-monitors-parse` — auto-generates `default/hypr/monitors.conf` from
  `hyprctl monitors all`.
- `script-monitor-display` — `wofi` menu to switch display modes
  (Display / Mirror / Extend / Resolution) on X11 (xrandr-based).

---

## Networking

- `iwd` (if not already installed) — `systemctl enable --now iwd.service`.
- `systemd-networkd-wait-online` patched to use `--any` so it doesn't
  block on disconnected interfaces.

---

## Bluetooth

- `bluetui` TUI frontend; `bluetooth.service` enabled at boot.

---

## Power

- `power-profiles-daemon` installed; sets `performance` on desktops,
  `balanced` on laptops.
- Laptops also enable a user-level **battery monitor** timer
  (`defo-battery-monitor.timer`, from `bin/script-battery-monitor`).
- The monitor uses `upower` and a flag dir under
  `/run/user/$UID/battery_notify/` so it fires at 50/30/20/15/10% once per
  threshold; flags clear when the battery returns to charging.

---

## Printing

- `cups`, `cups-pdf`, `cups-filters`, `system-config-printer`;
  `cups.service` enabled.

---

## Fonts

- `ttf-firacode-nerd`, `ttf-ubuntu-mono-nerd`, `ttf-dejavu` from the AUR.
- Also referenced by name: **CaskaydiaMono Nerd Font** (Hyprland lock, Zed
  UI), **Ubuntu Mono Ligaturized** (Zed buffer), **Liberation Sans 11**
  (Mako default).

---

## Default Apps (XDG)

`install/mimetype.sh` sets:

- **Images** → `imv` (png, jpeg, gif, webp, bmp, tiff)
- **PDF** → `google-chrome`
- **Browser** → `google-chrome` (http/https)
- **Video** → `mpv` (mp4, mkv, webm, etc.)
- Plus Alacritty-based `.desktop` launchers for TUIs: `htop`, `neomutt`,
  `taskwarrior`, `ncmpcpp`, `tig`.

---

## Audio

- `wireplumber` + `pipewire` (transitive); `wiremix` TUI mixer bound to
  `SUPER+X`. `playerctl` for media keys.

---

## AI / ML Local Stack

- `OPENROUTER_API_KEY` exported in `default/bash/envs` (real key present).
- Local LLaMA build at `~/ai/llama.cpp/build/bin` on PATH.
- Ollama (referenced by Zed's edit_predictions: `qwen2.5-coder:7b-base`).
- Antigravity (Google's AI IDE) launched from `SUPER+ALT+A` from
  `~/Downloads/antigravity/Antigravity/antigravity`.

---

## SSH

`default/sshconfig` (`~/.ssh/config`) contains:

| Host | Address | User |
|---|---|---|
| `github.com` | github.com | `git` (using `~/.ssh/id_key`) |
| `buster` | 213.139.204.176 | `busterrs` |
| `prosoftis` | prosoftis.com | `prosofti` |
| `minipc` | 192.168.0.105 | `usr` |

`bin/script-setup-ssh-connection` is a multi-distro helper that
generates/syncs a key with `ssh-keygen` + `curl` (works on pacman, apt, dnf).

---

## GPG

- `default/gpg/dirmngr.conf` is dropped into `/etc/gnupg/` (chmod 644).
- Multiple keyservers: `hkps://keyserver.ubuntu.com`,
  `hkps://pgp.surfnet.nl`, `hkps://keys.mailvelope.com`,
  `hkps://keyring.debian.org`, `hkps://pgp.mit.edu`,
  with `connect-quick-timeout = 4`.
- `dirmngr` is killed and re-launched at install time.

---

## Fingerprint

`bin/script-fingerprint-setup` (run manually, requires `fprintd` + `usbutils`):

- Patches `/etc/pam.d/sudo` and `/etc/pam.d/polkit-1` to allow
  `pam_fprintd.so`.
- Walks the user through enrolling their right index finger with
  `fprintd-enroll`, then verifies with `fprintd-verify`.
- Hyprlock has `auth { fingerprint:enabled = true }`, so login works with a
  touch.

---

## Themes

`themes/` contains **7 complete palettes**, each exporting matching files for
`alacritty.toml`, `btop.theme`, `hyprland.conf`, `hyprlock.conf`, `mako.ini`,
`waybar.css`, `wofi.css`:

1. **catppuccin** *(active — see `current/theme/`)*
2. everforest
3. gruvbox
4. kanagawa
5. matte-black
6. nord
7. tokyo-night

Switching a theme = copying one folder's contents into `current/theme/` and
reloading the affected apps. `current/theme/` currently holds a Catppuccin
Mocha variant (`#181824` background, `#cdd6f4` text, `#449dab` check).

---

## Hardware-Specific

### NVIDIA (`install/nvidia.sh`)
Auto-detected by `lspci`. Picks `nvidia-open-dkms` for Turing+ (RTX 2xxx and
newer, GTX 16) and falls back to `nvidia-dkms` otherwise. Kernel-headers
package follows the installed kernel (`linux-zen`, `linux-lts`,
`linux-hardened`, or `linux`).

Installs: `nvidia-utils`, `lib32-nvidia-utils`, `egl-wayland`,
`libva-nvidia-driver`, `qt5-wayland`, `qt6-wayland`.

Configures:
- `options nvidia_drm modeset=1` in `/etc/modprobe.d/nvidia.conf`
- `nvidia nvidia_modeset nvidia_uvm nvidia_drm` prepended to
  `/etc/mkinitcpio.conf` MODULES
- `mkinitcpio -P` rebuild
- Appends `NVD_BACKEND=direct`, `LIBVA_DRIVER_NAME=nvidia`,
  `__GLX_VENDOR_LIBRARY_NAME=nvidia` to `~/.config/hypr/hyprland.conf`

### Multi-monitor
Two laptop outputs are pre-configured:
- `eDP-1` (internal) — 1920×1200@60, offset left (`-1920x0`)
- `HDMI-A-1` (external) — 1920×1080@60, origin

The same model is mirrored in Sway's `monitors/` (with `eDP-1 disable` on
the sway side because sway is normally used docked to HDMI).

---

## Daily Driver Apps (summary table)

| Purpose | App | Launcher |
|---|---|---|
| Terminal | Alacritty (15pt FiraCode NF) | `SUPER+Return` |
| Tiling WM | Hyprland | auto-login |
| Bar | Waybar | autostart |
| Launcher | Wofi / Fuzzel | `SUPER+SPACE` / keybinds |
| Notifications | Mako | autostart |
| File manager | yazi | `SUPER+E` |
| Browser | Google Chrome | `SUPER+B` |
| Editor | Neovim (two configs) | `n` / `nvim` |
| Code editor | Zed | app drawer |
| Media player | mpv | file/right-click |
| Image viewer | imv | mime default |
| Screen capture | hyprshot | `PRINT` / `SUPER+S` |
| Color picker | hyprpicker | `SUPER+PRINT` |
| Bluetooth | bluetui | `SUPER+C` |
| Audio | wiremix + swayosd | `SUPER+X`, media keys |
| System monitor | btop | `SUPER+T` |
| Music | youtube-tui (media workspaces) | `SUPER+M` / `SUPER+Y` |
| Container UI | lazydocker (podman backend) | `SUPER+D` |
| Container mgmt | gum-driven `script-manage*` hub | `SUPER+grave` |
| PHP switcher | `script-manage-php` | via manage hub |
| Info screen | `script-info` (Rust binary) | `SUPER+I` |
| Wallpaper picker | yazi + hyprpaper | `SUPER+P` |
| Night light | hyprsunset (50% / 4000 K) | `SUPER+N` |
| Power | fuzzel menu | `SUPER+ESCAPE` |
| Steam | Steam | `SUPER+G` |
| Antigravity IDE | Google Antigravity | `SUPER+ALT+A` |
| ChatGPT / Gemini | Chrome webapps | `SUPER+A` / `SUPER+SHIFT+A` |
| Clipboard | cliphist + fuzzel | `SUPER+V` |
| Tmux | tmux 3.x with TPM | shell |
| LazyGit | lazygit | shell |
| FZF everywhere | fzf | Ctrl-T / Ctrl-R (fzf shell bindings) |
| Music CLI | custom yt-dlp+mpv functions | `playlist-play`, `song-play`, `playlist-dl-play` |
| Passwords | GPG (`gpg` via keyservers) | shell |
| SSH | openssh | shell |
| Python / JS / PHP / Rust / Go / TS | `mise` + per-language tools | shell |

---

## Helper Scripts (`bin/`)

| Script | Purpose |
|---|---|
| `script-power` | fuzzel power menu (lock / suspend / relaunch / restart / shutdown). |
| `script-wallpaper` | yazi-pick a wallpaper from `~/Pictures/walls`, preload + apply in hyprpaper, copy to `~/.dots/background`. |
| `script-toggle-sunset` | start/kill `hyprsunset -g 50% -t 4000k`. |
| `script-toggle-idle` | start/kill hypridle, with notify-send feedback. |
| `script-notify-time` | tiny `notify-send` that prints the current time (used by systemd). |
| `script-battery-monitor` | `upower`-based tiered battery warning (50/30/20/15/10%) with flag files. |
| `script-info` | compiled Rust binary, full system-info screen. |
| `script-monitors-pick` | compiled Rust binary, interactive monitor picker. |
| `script-monitors-parse` | regenerates `monitors.conf` from `hyprctl monitors all`. |
| `script-monitor-display` | wofi dmenu for xrandr Display/Mirror/Extend/Resolution. |
| `script-fingerprint-setup` | one-shot `fprintd` enrollment + PAM wiring. |
| `script-show-keybindings` | parses `hyprland.conf` + dotfiles, sorts unique binds, presents in wofi. |
| `script-setup-ssh-connection` | multi-distro SSH keygen/sync helper. |
| `script-manage` | gum-driven hub that auto-discovers `script-manage-*` files. |
| `script-manage-database` | create/list Podman DB containers (MariaDB/Postgres/Mongo/Redis). |
| `script-manage-database-managment` | DB management utilities. |
| `script-manage-network` | list/create/delete podman networks; `--select` mode for callers. |
| `script-manage-php` | install/switch PHP versions via pacman+AUR, symlink at `/usr/local/bin/php`. |
| `workspace-cycle` | cycles Hyprland workspaces in `next`/`prev` direction. |
| `lib/helpers.sh` | shared `resource_exists`, `list_all_containers`, `check_deps (gum)`. |

---

## `install.sh` Order

`install.sh` simply `source`s every file in `install/` alphabetically. The
effective order is:

```
1-yay.sh          → base-devel + yay + pacman color/candy
2-identification.sh → gum + name/email prompt (exported to env)
3-terminal.sh     → core CLI tools (eza, fzf, bat, fd, ripgrep, zoxide, fastfetch, alacritty, …)
4-config.sh       → copy ~/.config/*, .tmux.conf, ssh config, GPG dirmngr, .bashrc, git aliases + identity
bluetooth.sh      → bluetui + enable bluetooth.service
desktop.sh        → brightnessctl, playerctl, wiremix, wireplumber, cliphist, mpv, imv, google-chrome
development.sh    → rustup, clang, llvm, mise, imagemagick, jq, mariadb/postgres libs, git, gh, lazygit, diff-so-fancy, podman, tmux
docker.sh         → podman + podman-compose + systemd units + DOCKER_HOST + hello-world
fonts.sh          → ttf-firacode-nerd, ttf-ubuntu-mono-nerd, ttf-dejavu
hyprlandia.sh     → hyprland, hyprshot, hyprpicker, hyprlock, hypridle, polkit-gnome, hyprland-qtutils, wofi, waybar, mako, swaybg, xdg portals
login.sh          → seamless-login binary, minimal-seamless-login.service, plymouth/plymouth-quit units, getty@tty1 disabled
mimetype.sh       → xdg-mime defaults + alacritty TUI .desktop files
network.sh        → iwd (if missing) + wait-online=any
nvidia.sh         → conditional NVIDIA stack (only if lspci shows NVIDIA)
nvim.sh           → nvim + LSP/treesitter tools + copy ~/.dots/config/nvim → ~/.config
plymouth.sh       → install plymouth, add hook, splash+quiet on kernel cmdline, set bgrt theme, copy custom image
power.sh          → power-profiles-daemon, set performance/balanced, enable battery monitor
printer.sh        → cups + cups-pdf + cups-filters + system-config-printer, enable cups
theme.sh          → `cp -R ~/.dots/config/* ~/.config` (overlay active theme)
```

Finally: `sudo updatedb` and a gum-confirm reboot.

---

## What is **not** in this repo (but referenced)

- Wallpapers live in `~/Pictures/walls/` and `~/Pictures/screenshots/`.
- Local repos / personal projects — not tracked here.
- Antigravity binary at `~/Downloads/antigravity/Antigravity/antigravity`.
- Android SDK contents under `~/Android/Sdk` (created by the user, only
  paths are exported).
- `~/.cache/.bun/bin` (bun installed out-of-band).
- `~/ai/llama.cpp/build/bin` (llama.cpp built locally).

---

## Quick "what do I use?" cheat sheet

- **WM:** Hyprland (with sway as a backup config)
- **Bar:** Waybar
- **Launcher:** Wofi (`SUPER+SPACE`) / Fuzzel (everything else)
- **Notifications:** Mako
- **Terminal:** Alacritty
- **Shell:** Bash (custom `default/bash/*`)
- **Editor:** Neovim (Catppuccin Macchiato, blink.cmp, telescope, treesitter, harpoon, trouble) and Zed (Catppuccin Mocha, vim mode, local Ollama completions)
- **Browser:** Google Chrome + Vimium (heavy per-site pass-key config)
- **Container runtime:** Podman (rootless, Docker-compatible socket)
- **Version manager:** Mise
- **Version control:** Git + LazyGit + diff-so-fancy, conventional-commit template
- **Search/jump:** FZF + Zoxide + Ripgrep + Bat + FD
- **Music:** mpv + yt-dlp via custom bash functions; youtube-tui workspaces
- **AI tooling:** ChatGPT/Gemini as webapps, Antigravity as native app, Ollama (`qwen2.5-coder:7b-base`) wired into Zed, OpenRouter API key exported, local llama.cpp on PATH
- **Theming:** 7 palettes in `themes/`, current is Catppuccin
- **Lock / idle:** hyprlock + hypridle, fingerprint enabled
- **Boot:** Plymouth `bgrt` theme + custom image, seamless auto-login via a tiny C binary + systemd user service
