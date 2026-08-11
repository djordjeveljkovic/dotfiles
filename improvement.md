# Dotfiles Improvement Plan
*Reconciled with `current_setup.md` (your actual Hyprland desktop).*

**Goal:** minimal repo, sway-only, profile-aware (`desktop` vs `server`), usable system in < 4 steps.

### How to read the decisions below
| Tag | Meaning |
|---|---|
| 🟢 **base** | Installed on every box (server + desktop) |
| 🖧 **server** | Server-only add-on |
| 🖥️ **desktop** | Desktop-only add-on (requires 🟢 base) |
| ⚙️ **opt** | Optional / opt-in flag (not in default bootstrap) |
| ❌ **drop** | Removed from repo |
| 🔧 **convert** | Kept but rewritten for sway |

---

## 1. What your current desktop has → decision for the minimal sway setup

### OS & base
| Current | Decision | Note |
|---|---|---|
| Arch Linux | 🟢 keep | — |
| `yay` AUR helper | 🔧 → `paru` | You actually use paru (`.bash_history`). Rename `1-yay.sh`→`1-paru.sh`, clone `paru-bin`. |
| pacman `Color` + `ILoveCandy` | 🟢 keep | — |
| multilib repo | ⚙️ opt | Only enabled by nvidia installer. |
| `sudo updatedb` at end | 🟢 keep | — |

### Boot & login
| Current | Decision | Note |
|---|---|---|
| Plymouth (`bgrt` + custom image) | ⚙️ opt (`--plymouth`) | **Does not speed up boot** — it only hides the text scroll via an extra mkinitcpio hook that *adds* work. The "fast start" you remember is the `quiet loglevel=0` kernel params, which cost nothing without Plymouth. Default off; opt in only for splash art. |
| GRUB config | ⚙️ opt | Keep file, apply only if GRUB detected (plymouth.sh already branches on bootloader). |
| `seamless-login` C binary | ❌ drop | Hard-coded `uwsm start -- hyprland.desktop`. |
| `minimal-seamless-login.service`, `plymouth-quit` units, getty@tty1 disable | ❌ drop | All tied to the above. |
| (new) login for sway | 🖥️ **TTY autologin** (chosen for the sub-14s target) | Zero extra packages, zero extra services. A `getty@tty1` autologin override + a 3-line `~/.bash_profile` guard that runs `exec sway` on tty1. Beats greetd by one fewer service + one fewer greeter round-trip. Full boot-speed strategy in §10. |

### Display server / compositor
| Current | Decision |
|---|---|
| Hyprland (`default/hypr/*`, `config/hypr/*`) | ❌ **drop entirely** (9 files in `default/hypr/`, 3 in `config/hypr/`) |
| Sway (`default/sway/*`) | 🖥️ **keep — becomes the primary** |
| `install/hyprlandia.sh` | 🔧 → rename `install/sway.sh`, install sway stack (see §4) |

### Bar / launcher / notifications / OSD / lock
| Current | Decision | Note |
|---|---|---|
| Waybar | 🖥️ keep | Config uses `hyprland/workspaces` module → change to `sway/workspaces` (one line). |
| Wofi | ❌ drop | You bind it **nowhere**; everything uses fuzzel. Pick one → fuzzel. |
| Fuzzel | 🖥️ keep (and **add to installer**) | Not currently installed by any script despite being bound everywhere. |
| Mako | 🖥️ keep | Replace broken tracked symlink with real `include ~/.dots/current/theme/mako.ini`. |
| swayosd | ❌ drop | OS-level OSD overlay replaced by `notify-send` (mako) for volume/brightness/media/layout feedback. See §14. |
| hypridle | 🔧 → `swayidle` | Already in `default/sway/autostart`. Drop hypridle config. |
| hyprlock | 🔧 → `swaylock` | Password-only (fingerprint unlock dropped — see §9). |

### Wallpaper
| Current | Decision |
|---|---|
| hyprpaper | ❌ drop |
| swaybg | 🖥️ keep (already in sway autostart) |
| `bin/script-wallpaper` | 🔧 rewrite: `swaymsg output "*" bg "$WALL" fill` + `cp` to `~/.dots/background`. Drop hyprctl preload. |

### Terminal & shell
| Current | Decision | Note |
|---|---|---|
| Alacritty | 🖥️ keep (primary `$terminal`) | — |
| Ghostty | ❌ **drop** | Alacritty-only. The 4 ghostty bindings (yazi, youtube workspace, music workspace, `script-wallpaper`) all become `$terminal -e ...`. Removes a second terminal emulator and its config surface. |
| Bash (`default/bash/*`) | 🟢 keep | Solid. Trim `envs` (below). |

### Bash environment trimming (`default/bash/envs`)
| Current | Decision |
|---|---|
| `EDITOR=nvim` | 🟢 keep |
| `HYPRSHOT_DIR` | ❌ drop (hyprshot gone) |
| `ANDROID_HOME` + platform-tools + cmdline-tools | ⚙️ opt (`--android`): drops an env fragment into `~/.config/dots/envs.d/android.env` that `default/bash/envs` sources if present |
| `DOCKER_HOST` podman socket | 🟢 keep (if keeping podman) |
| PATH `~/.local/bin`, `~/.dots/bin`, `./bin`, `~/go/bin`, `~/.cargo/bin` | 🟢 keep |
| PATH flutter (`/opt/flutter/bin`) | ⚙️ opt (`--flutter`) → `envs.d/flutter.env`. **`--flutter` auto-pulls `--android`** (Flutter mobile builds require the Android SDK). |
| PATH composer / llama.cpp / bun / `~/usr/bin` | ⚙️ opt (move out of base envs; each gets its own `envs.d/*.env` if ever revived) |
| **API keys** (`OPENROUTER`, NVIDIA, MINIMAX, Z_AI) | 🔧 move to **`~/.config/secrets.env`** (gitignored, sourced by `envs` if present). Right now they're hand-edited into `~/.bashrc` and lost on a new box. |

### Editors & dev tools
| Current | Decision |
|---|---|
| `config/nvim/` (lazy.nvim, Catppuccin, blink, telescope, treesitter, harpoon, trouble, Laravel, intelephense) | 🟢 keep |
| `config/nvim012/` (nvim-pack prototype) | ❌ drop (dead, superseded) |
| Zed | 🖥️ opt (keep config, don't force-install the binary) |
| `rustup`, `clang`, `llvm`, `mise` | 🟢 keep (core dev) |
| `node`, `npm`, `go` | 🟢 keep (needed for `pi`, nvim, general) |
| `tree-sitter-cli`, `cmake`, `luarocks`, `npm` (for nvim) | 🟢 keep (nvim.sh) |
| `shellcheck` | 🟢 keep (nvim-lint) |
| MariaDB-libs / PostgreSQL-libs | 🖧 keep (DB container work) |
| Composer, Bun | ⚙️ opt (PHP/JS only) |
| Flutter `/opt/flutter/bin` | ⚙️ opt (`--flutter`) — depends on `--android` (see envs above) |
| Android SDK (`~/Android/Sdk`) | ⚙️ opt (`--android`) — standalone; usable for native Kotlin/Java dev without Flutter |
| Git (`config/git/*`) | 🟢 keep — but **delete nested dup** `config/git/git/git/...` |
| Tmux + TPM | 🟢 keep |

### Containers (podman, rootless)
| Current | Decision |
|---|---|
| `docker.sh` + `development.sh` (both install podman) | 🟢 keep, **merge into one** `install/podman.sh` |
| Rootless podman + socket + `containers.conf` + `DOCKER_HOST` | 🟢 keep |
| `bin/script-manage` (gum hub) + `lib/helpers.sh` | 🟢 keep — this is your daily workflow |
| `script-manage-network` | 🟢 keep |
| `script-manage-database`, `-database-managment` | 🖧 keep (your real DB work — confirmed by current_setup) |
| `script-manage-php` | 🖧 keep (your real PHP work — intelephense, Laravel) |
| `lazydocker` | 🟢 **add to installer** (bound to SUPER+D, never installed) |

### Monitor management
| Current | Decision |
|---|---|
| `script-monitors-parse` (hyprctl) | ❌ drop |
| `script-monitor-display` (wofi + xrandr) | ❌ drop |
| `script-monitors-pick` (14 MB Rust binary) | ❌ drop |
| (new) **kanshi** | 🖥️ add — sway-native, declarative, replaces all three. |

### Networking
| Current | Decision |
|---|---|
| `iwd` + wait-online `--any` patch | 🟢 keep |
| `impala` (wifi TUI) | 🖥️ keep (bound SUPER+Z) |

### Bluetooth
| Current | Decision |
|---|---|
| `bluetui` + `bluetooth.service` | 🖥️ desktop only |

### Power
| Current | Decision |
|---|---|
| `power-profiles-daemon` | 🟢 keep |
| `script-battery-monitor` + timer | 🖥️ keep (laptop only) |

### Printing
| Current | Decision |
|---|---|
| CUPS stack | ⚙️ opt (drop from default — both profiles) |

### Fonts
| Current | Decision |
|---|---|
| `ttf-firacode-nerd` | 🟢 keep (Alacritty uses FiraCode NF) |
| `ttf-ubuntu-mono-nerd` | ⚙️ opt (only Zed buffer font) |
| `ttf-dejavu` | ⚙️ opt |
| (referenced) CaskaydiaMono NF | ⚙️ opt (`--zed`) | Only used by Zed UI font; pulled automatically by `--zed`. |

### Default apps / XDG mime
| Current | Decision |
|---|---|
| imv, mpv, google-chrome defaults | 🖥️ keep |
| Alacritty `.desktop` launchers for `htop/neomutt/taskwarrior/ncmpcpp/tig` | 🔧 trim to what's installed: `btop`, `tig`. Drop the rest. |

### Audio
| Current | Decision |
|---|---|
| pipewire + wireplumber + wiremix + playerctl | 🖥️ keep |

### AI / ML stack — all separate opt-ins, no bundling
| Current | Decision | Dependencies |
|---|---|---|
| OpenRouter / NVIDIA / MiniMax / Z-AI keys in envs | 🔧 → `secrets.env` (gitignored) | — |
| Ollama (local LLM runtime) | ⚙️ `--ollama` | **standalone.** Zed's config *references* it for edit predictions, but it's a soft link — Zed works without it (just no local AI completions). |
| Zed (editor) | ⚙️ `--zed` | **standalone.** Pulls CaskaydiaMono NF (its UI font) but nothing else. |
| Antigravity (Google's AI IDE) | ⚙️ `--antigravity` | **standalone.** A downloaded binary placed at `~/Downloads/antigravity/`; no relation to Zed/Ollama/Flutter/Android. |
| llama.cpp local build | ⚙️ out of repo | If you rebuild it later, it gets its own `envs.d/llama.env`; not an install flag (you build it yourself). |

### SSH / GPG
| Current | Decision |
|---|---|
| `default/sshconfig` | ❌ **remove from repo** | You don't want SSH config versioned (private hostnames/IPs/usernames, per-machine keys). Delete the file; `4-config.sh` stops copying it. Why I originally flagged the `id_key` vs `id_ed25519` mismatch — full rationale in §11. |
| `bin/script-setup-ssh-connection` | 🟢 keep | Generates/syncs keys on a new box; stores nothing host-specific. |
| GPG dirmngr.conf (multi-keyserver) | 🟢 keep |

### Fingerprint
❌ **Dropped entirely.** swaylock has no fingerprint auth (hyprlock did), and you're fine without it. `script-fingerprint-setup` is deleted; fprintd is not installed.

### Themes
| Current | Decision |
|---|---|
| `themes/` (7 palettes × 7 files, 49 files) | ❌ drop (unreferenced dead code) |
| `current/theme/` (single active theme) | 🖥️ keep + **finish it**: add missing `waybar.css` and `sway.conf`. |

### NVIDIA
| Current | Decision |
|---|---|
| Driver detection + install + mkinitcpio + modprobe | ⚙️ opt (keep, generalize) |
| Appending envs to `hyprland.conf` | ❌ drop — instead append NVIDIA envs to `default/sway/envs.sh` if detected. |

### Vimium (Chrome)
| Current | Decision |
|---|---|
| `config/vimium-options.json` (heavy per-site config) | 🖥️ keep — you clearly use it. |

### Daily-driver TUIs actually referenced by bindings but **missing from installer**
Must be added to the desktop profile:
- `fuzzel` (launcher) — bound everywhere, never installed
- `yazi` (file manager, SUPER+E) — never installed
- `btop` (SUPER+T) — never installed (mimetype.sh even wrongly references `htop`)
- `lazydocker` (SUPER+D) — never installed
- `swaylock`, `swayidle` — never installed (only hyprlock/hypridle were)
- `grim`, `slurp` (screenshots) — replacing hyprshot, never installed
- `wlsunset` (night light) — replacing hyprsunset. Lighter than gammastep (tiny C daemon, wlr-gamma-control only, no geo deps).
- `polkit-gnome` — was in hyprlandia.sh, keep for sway auth dialogs

---

## 2. Current repo problems (technical debt)

| Problem | Detail |
|---|---|
| **Repo is 29 MB; 28 MB is 2 compiled binaries** | `bin/script-info` (14 MB) + `bin/script-monitors-pick` (13 MB) checked into git. Removing → repo shrinks ~96%. Replace `script-info` with fastfetch (already installed) or rebuild-from-source; drop `script-monitors-pick` for kanshi. |
| **Hardcoded `/home/usrtmp`** in 5+ files | `default/hypr/{bindings,monitors,envs}.conf` (deleting with hypr anyway), `default/sway/bindings` (Antigravity line), `bin/script-info`, `bin/script-monitors-pick` (deleting). |
| **Tracked broken symlink** | `config/mako/config` → `/home/usrtmp/.config/omarchy/current/theme/mako.ini` (dead). Replace with real file. |
| **Missing theme files** | `config/waybar/style.css` imports `current/theme/waybar.css` (doesn't exist); `config/sway/config` includes `current/theme/sway.conf*` (doesn't exist — glob hides the failure). |
| **Wrong AUR helper everywhere** | All `install/*.sh` use `yay`; you use `paru`. |
| **Duplicate configs** | `config/git/git/git/{config,ignore,template}` (nested copy artifact); `config/.tmux.conf` dupes `default/.tmux.conf`; `config/nvim012/` dupes `config/nvim/`. |
| **`docker.sh` and `development.sh` both install podman** | Merge into one `install/podman.sh`. |
| **`install.sh` runs all 17 scripts unconditionally** | No profile branching; server gets a full GUI attempt. |
| **`4-config.sh` uses `cp -R ~/.dots/config ~/.config`** | Overwrites blindly, leaves stale files on re-runs. Use symlinks so edits flow back to the repo. |
| **Installer ≠ bindings** | §1 "missing from installer" — bindings call apps the installer never installs. |
| **No `.gitignore`** | Secrets are one careless `git add` away from being committed. |
| **API keys live in `~/.bashrc`** | Lost on reinstall; not versioned safely. |

---

## 3. Target repo layout (after)

```
~/.dots/                          # ~1 MB
├── install.sh                    # entry: base → server|desktop → opt flags
├── install/
│   ├── 1-paru.sh                 # base: paru-bin + pacman color
│   ├── 2-identification.sh       # base: gum + git identity
│   ├── 3-terminal.sh             # base: eza/fzf/rg/fd/bat/zoxide/fastfetch/alacritty/...
│   ├── 4-config.sh               # base: symlink ~/.config/* from repo, bashrc, tmux, ssh, gpg
│   ├── nvim.sh                   # base
│   ├── development.sh            # base: rustup/clang/llvm/mise/node/npm/go/git/gh/lazygit/dsf/tmux
│   ├── podman.sh                 # base (merged from docker.sh): podman + socket + DOCKER_HOST
│   ├── network.sh                # base: iwd + wait-online patch
│   ├── power.sh                  # base: power-profiles-daemon
│   ├── desktop.sh                # DESKTOP: sway stack, audio, bluetooth, fonts, mime, wallpaper
│   ├── server.sh                 # SERVER: db libs, headless niceties (empty/minimal by default)
│   ├── bluetooth.sh  / printer.sh / plymouth.sh / nvidia.sh  # OPT flags
├── bin/                          # sway-native, no compiled binaries
├── lib/helpers.sh
├── config/                       # symlinked into ~/.config
│   ├── alacritty btop fastfetch git nvim zed waybar fuzzel(maybe) vimium-options.json
├── default/
│   ├── bash/  sway/  gpg/  .tmux.conf   # NOTE: sshconfig removed (see §11)
├── current/theme/                # ONE active theme, complete (alacritty, mako, btop, waybar.css, sway.conf)
├── assets/                       # background + walls + plymouth image (was 3 scattered locations)
└── .gitignore                    # secrets.env, *.env, current/background (generated)
```

---

## 4. Profile install manifests

### 🟢 base (every box)
```
paru -S --needed base-devel gum \
  unzip p7zip zip curl wget openssh nmap whois \
  fd eza fzf ripgrep zoxide bat \
  wl-clipboard plocate bash-completion less man tldr fastfetch \
  git github-cli lazygit diff-so-fancy tmux \
  rustup clang llvm mise jq imagemagick \
  nvim luarocks tree-sitter-cli cmake npm go shellcheck \
  podman podman-compose \
  power-profiles-daemon
```

### 🖧 server add-on
```
paru -S --needed mariadb-libs postgresql-libs
# + iwd if the box has wifi
```

### 🖥️ desktop add-on
```
paru -S --needed sway swaylock swayidle swaybg \
  waybar fuzzel mako \
  alacritty yazi btop \
  brightnessctl playerctl wiremix wireplumber pipewire \
  wl-clip-persist cliphist \
  grim slurp wl-clipboard \
  wlsunset \
  mpv imv google-chrome \
  impala bluetui \
  polkit-gnome \
  ttf-firacode-nerd ttf-caskaydia-mono-nerd \
  kanshi \
  lazydocker             # if podman present
```

### ⚙️ opt flags (each fully independent unless noted)

| Flag | Installs | Depends on |
|---|---|---|
| `--nvidia` | NVIDIA driver stack | nothing |
| `--plymouth` | Plymouth splash + custom image | nothing |
| `--bluetooth` | bluetui + bluetooth.service | nothing |
| `--printer` | CUPS stack | nothing |
| `--android` | Android SDK + cmdline/platform-tools + `envs.d/android.env` | nothing |
| `--flutter` | Flutter SDK at `/opt/flutter` + `envs.d/flutter.env` | **`--android`** (auto-enabled) |
| `--antigravity` | Google Antigravity IDE binary | nothing |
| `--zed` | Zed editor + CaskaydiaMono NF | nothing |
| `--ollama` | Ollama daemon + `qwen2.5-coder` model | nothing |

> Design: every opt flag is a standalone leaf except `--flutter`→`--android`. Zed and Ollama are **not** coupled (Zed works without Ollama; Ollama works without Zed). This matches your instruction: separate unless a hard dependency.
>
> Mechanism: each flag (a) installs its packages, and (b) drops an env fragment at `~/.config/dots/envs.d/<name>.env`. `default/bash/envs` runs `for f in ~/.config/dots/envs.d/*.env; do source "$f"; done` — so opting in = fragment present, opting out = fragment absent. No PATH pollution when a flag isn't used.

---

## 5. `bin/` scripts — rewrite map

| Script | Decision | Action |
|---|---|---|
| `script-power` | 🔧 | `hyprlock`→`swaylock`; `uwsm stop` stays for "Relaunch". |
| `script-wallpaper` | 🔧 | `hyprctl hyprpaper` → `swaymsg output "*" bg "$WALL" fill`. |
| `script-toggle-sunset` | 🔧 | `hyprsunset` → `wlsunset -T 4000 -g 0.5` (toggle via pkill). |
| `script-toggle-idle` | 🔧 / ❌ | `hypridle` toggle is easy; `swayidle` is launched by sway itself. Either drop (idle always on) or reimplement by killing/restarting `swayidle`. |
| `script-notify-time` | 🟢 keep | WM-agnostic. |
| `script-battery-monitor` | 🟢 keep | WM-agnostic. |
| `script-info` (14 MB) | ❌ drop | Replace with `fastfetch` (already installed) bound to SUPER+I. |
| `script-monitors-pick` (13 MB) | ❌ drop | Use kanshi. |
| `script-monitors-parse` | ❌ drop | hyprctl-based. kanshi config is static. |
| `script-monitor-display` | ❌ drop | hyprctl/xrandr. kanshi profiles replace it. |
| `script-fingerprint-setup` | ❌ drop | Fingerprint unlock dropped (swaylock has no support; you accepted password-only). |
| `script-show-keybindings` | 🔧 | Rewrite to parse `default/sway/bindings` instead of `hyprland.conf`. |
| `script-setup-ssh-connection` | 🟢 keep | WM-agnostic. |
| `script-manage` + `lib/helpers.sh` | 🟢 keep | — |
| `script-manage-network` | 🟢 keep | — |
| `script-manage-database`, `-database-managment`, `-php` | 🟢 keep | Your real work. |
| `workspace-cycle` | ❌ drop | Sway has `workspace back_and_forth` + `workspace next_on_output` natively. |

---

## 6. Finish the theme system (`current/theme/`)

Pick the per-app-file approach (matches alacritty/mako already). Required files:

| File | Status | Source |
|---|---|---|
| `alacritty.toml` | ✓ exists | keep |
| `mako.ini` | ✓ exists | keep |
| `btop.theme` | ✓ exists | keep |
| `waybar.css` | ❌ missing | port from `themes/catppuccin/waybar.css` |
| `sway.conf` | ❌ missing | new — sway `client.focused/unfocused/...` color vars, ported from a theme's hyprland border colors |
| `rose.toml` / `nord.toml` | 🔧 collapse | two parallel formats; pick ONE as the alacritty color source and delete the other |

Then `config/mako/config`, `config/waybar/style.css`, `config/alacritty/alacritty.toml`, and the new sway include all point at `current/theme/` consistently.

---

## 7. The "< 4 steps" bootstrap

End-state on a fresh Arch box:

```bash
# 1. one-liner (derived from your .bash_history):
sudo pacman -S --needed --noconfirm base-devel gcc make rustup openssh git nodejs npm go ttf-firacode-nerd eza alacritty neovim fd ripgrep fzf bat zoxide jq tmux && paru -S --needed --noconfirm google-chrome && curl -fsSL https://pi.dev/install.sh | sh
# (this gets you to a shell with pi + paru so you can clone the repo)

# 2. clone + run the profile installer
git clone git@github.com:djordjeveljkovic/dotfiles.git ~/.dots && ~/.dots/install.sh
#   install.sh asks (gum): "desktop or server?" and prompts for opt flags.

# 3. reboot into sway (desktop) or stay on tty (server)
```

After the refactor, the real entrypoint is just step 2. `install.sh` flow:
```
base (always) → ask profile → desktop|server add-ons → opt flags → updatedb → done
```

---

## 8. Execution order (one PR each)

1. **Nuke hyprland** + delete dead `themes/`, `config/nvim012/`, nested `config/git/git/`, `config/.tmux.conf`. Fix `/home/usrtmp` refs. Commit.
2. **Drop the 2 compiled binaries** from git. Replace `script-info` with fastfetch binding. Commit. (Repo → ~1 MB.)
3. **yay → paru** across install scripts + bash alias. Commit.
4. **Rewrite sway scripts** (§5) + add missing packages to desktop profile (fuzzel, yazi, btop, lazydocker, grim, slurp, wlsunset, swaylock/idle, kanshi). Commit.
5. **Finish `current/theme/`** (§6) + fix waybar/mako/sway includes. Commit.
6. **Split installer** into base/server/desktop + opt flags (§3, §4). Merge `docker.sh`+podman part of `development.sh` into `install/podman.sh`. Commit.
7. **Hygiene**: `.gitignore`, `secrets.env` mechanism, symlink-based `4-config.sh`, `assets/` dir, trim `envs`, trim mimetype `.desktop` list. Commit.

---

## 9. Open questions (resolved & remaining)

### Resolved by `current_setup.md`
- ✅ **PHP/DB scripts** → keep (your real work: intelephense, Laravel, DB containers).
- ✅ **Podman** → keep (rootless, your daily container runtime).
- ✅ **Vimium** → keep (heavy per-site config).
- ✅ **Themes** → one active theme; the 7-palette library is dead.
- ✅ **Multiple monitors** → kanshi (replaces 3 hypr/xrandr scripts + a 14 MB binary).
- ✅ **Screenshots** → grim + slurp + wl-clipboard (sway standard, replaces hyprshot).
- ✅ **Color picker** → drop hyprpicker (rarely used; `grim -g "$(slurp -p)" - | magick -` if needed).

### Resolved by your answers
- ✅ **Fingerprint unlock** → **dropped.** swaylock is password-only; `script-fingerprint-setup` deleted, fprintd not installed. (You're fine without it.)
- ✅ **Login manager** → **TTY autologin**, not greetd. Chosen for the sub-14s boot target: zero extra packages, zero extra services. A `getty@tty1` autologin override + a 3-line `~/.bash_profile` guard (`[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec sway`). Full strategy in §10.
- ✅ **Night light** → **`wlsunset`** (lighter than gammastep — tiny C daemon, wlr-gamma-control only, no geolocation/Python deps). `script-toggle-sunset` calls `wlsunset -T 4000 -g 0.5`.
- ✅ **Ghostty** → **dropped.** Alacritty-only. The 4 ghostty bindings (yazi, youtube workspace, music workspace, `script-wallpaper`) all become `$terminal -e ...`. Removes a second terminal emulator + its config surface.
- ✅ **SSH config** → **removed from the repo.** Rationale in §11. (You were right to push back.)
- ✅ **Plymouth** → **opt-in** (`--plymouth` flag). It does *not* speed up boot — it only hides the text scroll via an early-userspace hook that adds work. The "fast" feel comes from `quiet loglevel=0` kernel params, which work with zero overhead and no Plymouth. Default off.
- ✅ **Zed / Ollama / Antigravity / Flutter / Android SDK** → each its own **opt-in flag**, not bundled:
  - `--android` (standalone; native Android dev)
  - `--flutter` (depends on `--android`, auto-pulled — Flutter mobile builds need the Android SDK)
  - `--antigravity` (standalone Google AI IDE)
  - `--zed` (standalone editor + CaskaydiaMono NF)
  - `--ollama` (standalone LLM runtime; Zed *may* use it but isn't coupled)
  - Rationale: your instruction — separate unless a hard dependency. Only Flutter→Android qualifies. Full table in §4.
- ✅ **Wallpapers** → **keep all**, consolidated under `assets/` (`background`, `walls/back.jpg`, `walls/back2.jpg`, `plymouth_image.png`).

### Nothing left open
All questions resolved. Ready to execute §8.

---

## 10. Sub-14s boot strategy (hard target)

Target: power-on → sway usable in under 14 seconds. Levers, in priority order:

| Lever | Action | Impact |
|---|---|---|
| **No display manager** | TTY autologin on tty1 + `~/.bash_profile` `exec sway`. No greetd/sddm/lightdm service. | Saves a service start + a greeter round-trip (~0.5–1 s). |
| **No Plymouth by default** | Skip the `plymouth` mkinitcpio hook. `--plymouth` is opt-in. | Smaller initramfs, one fewer early-userspace phase. |
| **`quiet loglevel=0` kernel params** | Apply via bootloader entry (already in your `grub` file; systemd-boot equivalent auto-detected by `plymouth.sh`). | The *real* perceived-speed lever — clean console, zero cost. |
| **Minimal enabled services** | Only enable what each profile needs. Bluetooth/cups/etc. start only with their opt flag. | Fewer `systemd-analyze blame` entries competing for boot. |
| **Network wait patched** | `systemd-networkd-wait-online --any` (already in `install/network.sh`). | Stops boot blocking on every interface. |
| **initramfs compression** | `COMPRESSION="zstd"` in `/etc/mkinitcpio.conf` (modern Arch default). | Faster decompress than gzip. |
| **Measure** | `systemd-analyze` / `blame` / `critical-chain` run automatically at end of install and printed. | Tells you where the seconds went. |

### TTY autologin implementation (the chosen login path)

```ini
# /etc/systemd/system/getty@tty1.service.d/autologin.conf
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin <USER> --noclear %I $TERM
```

```sh
# ~/.bash_profile  (guard: only start sway on the first tty, never inside an existing session)
if [[ -z "$DISPLAY" && "$XDG_VTNR" -eq 1 ]]; then
  exec sway
fi
```

No `uwsm` needed unless you want its session management — `exec sway` is the minimum. If systemd/xdg portals misbehave without a session manager, add this to `default/sway/autostart`:
`exec dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway`.

> Security note: autologin means no password at boot. Fine for a personal desktop; the **server** profile neither autologins nor starts sway, so it's unaffected.

---

## 11. Why SSH config is leaving the repo (your Q5)

You asked *why* I flagged the key filename. Honest reason + why your instinct to drop it is correct:

**Why I flagged it:** the repo *already* contained `default/sshconfig`, and that file hardcoded `IdentityFile ~/.ssh/id_key`. On the new box you generated `id_ed25519` (visible in `.bash_history`). So if `sshconfig` stayed versioned, every `ssh buster` / `ssh minipc` would fail looking for a nonexistent `id_key`. It was an inconsistency to resolve *conditional on keeping the file* — not a request to standardize a key name across machines.

**Why removing it is the right call:**
- It contains hostnames, IPs, and usernames of your personal servers (`buster`, `prosoftis`, `minipc`) — private infra data, not dotfile config.
- SSH config is genuinely machine-specific (different boxes talk to different hosts).
- Key paths/names are per-machine.

**What changes in the plan:**
- `default/sshconfig` is deleted from the repo.
- `install/4-config.sh` stops copying it to `~/.ssh/config`.
- `bin/script-setup-ssh-connection` **stays** (it *generates* keys and syncs them on a new box; stores no host config).
- `.gitignore` adds `ssh/config` defensively in case you later symlink something.

No information is lost — your local `~/.ssh/config` on each machine stays as-is; it just stops being tracked.

---

## 12. Screenshot pipeline (grim + slurp + wl-copy + swappy)

**Before:** four inline `bindsym` lines in `default/sway/bindings`, each calling `grim -g "$(slurp)" - | wl-copy` directly. Three problems:

1. `wl-copy` without `-t image/png` defaults to `text/plain` for some apps — pasting into Discord/Slack/Telegram produces a text blob, not the image. The fix is to pass `-t image/png` *with a file path* (`wl-copy < file.png`), which wl-clipboard sniffs to `image/png`.
2. No notification feedback — pressing Print silently succeeds/fails.
3. No file save on `Print` / `Shift+Print`, no swappy annotate, no color picker, no active-window capture, no delay.

**After:** single helper script `bin/script-screenshot` with subcommands, called from bindings:

| Sub | What |
|---|---|
| `region`   | slurp region → save to `~/Pictures/screenshots/<ts>.png` + wl-copy |
| `output`   | full active output → save + wl-copy |
| `window`   | focused window (via `swaymsg -t get_tree \| jq`) → save + wl-copy |
| `clip`     | slurp region → wl-copy only (no file) |
| `color`    | `slurp -p` → `magick … %[pixel:p{0,0}]` → hex → wl-copy + notify |
| `annotate` | slurp region → `swappy -f -` overlay → save + wl-copy |
| `delay N <sub>` | sleep N seconds, then run sub |

Bindings (`default/sway/bindings`) — deliberately kept to two keys, the
others are still available as subcommands on the script:

```
bindsym $mod+s        exec script-screenshot region    # slurp → save + clipboard
bindsym $mod+Shift+s  exec script-screenshot annotate  # slurp → swappy → save + clipboard
```

**New packages** added to `install/desktop.sh` (`Media / hardware` section):
- `swappy` — annotation/crop overlay
- `libnotify` — provides `notify-send` for feedback
- `imagemagick` — `magick` parses `%[pixel:p{0,0}]` for color picker
- `jq` — extract focused window rect from `swaymsg -t get_tree`

**Why a script, not just longer bindsym lines:**
- Two `~/.dots` systems (current Hyprland box + clean Sway box) need identical screenshot behavior.
- swappy's `-f -` stdin mode makes annotation a one-liner inside the script but a mess inline.
- Color-picker pipe (`grim | magick | grep | wl-copy`) is non-trivial to debug from a binding; the script surfaces `notify-send` errors so failures are visible.
- Subcommand pattern (`region`, `output`, `window`, …) keeps the binding table one-line-per-key, which `script-show-keybindings` already formats nicely.

**Reinstall:** `~/.dots/install/desktop.sh` is idempotent (paru `--needed`) — re-run after pulling to pick up `swappy/libnotify/imagemagick/jq` without re-installing everything.

---

## 13. Pi coding-agent setup (pi-* packages)

Three public repos under the `pi-` namespace are the user-facing surface of pi extensions/skills. Installed globally:

| Repo | Cloned to | Type |
|---|---|---|
| [`djordjeveljkovic/pi-list-picker`](https://github.com/djordjeveljkovic/pi-list-picker) | `~/.pi/agent/extensions/list-picker/` | TUI component (npm package, peer-dep for skill-manager) |
| [`djordjeveljkovic/pi-skill-manager`](https://github.com/djordjeveljkovic/pi-skill-manager) | `~/.pi/agent/extensions/skill-manager/` | Extension: `/skills`, `/skills:list`, `/skills:manage`, `skill_list`/`skill_toggle`/`skill_reload` tools |
| [`djordjeveljkovic/pi-workflow`](https://github.com/djordjeveljkovic/pi-workflow) | `~/.pi/agent/extensions/workflow/` | Extension: `/workflow quick\|plan\|ask` + `wf_project_info`, `wf_note`, `wf_ask_question`, `wf_plan_save` tools |
| [`djordjeveljkovic/pi-skills-library`](https://github.com/djordjeveljkovic/pi-skills-library) | `~/.pi/agent/skills-library/` | 85 `SKILL.md` files across 10 collections (playwright, docmd, axi, toon-format, ui-ux-pro-max, find-skills, skill-manager, aif-collection, books-collection, ruflo-collection) |

**Why this lives outside `~/.dots`:** pi reads from `~/.pi/agent/` (XDG-style, per-user agent home). Keeping the repos there — owned by pi, not symlinked from `~/.dots/config/pi/` — means `git pull` inside each repo updates the live install without re-running the dotfiles installer.

**Install procedure** (idempotent — re-running is safe):

```bash
mkdir -p ~/.pi/agent/extensions
gh repo clone djordjeveljkovic/pi-list-picker      ~/.pi/agent/extensions/list-picker
gh repo clone djordjeveljkovic/pi-skill-manager    ~/.pi/agent/extensions/skill-manager
gh repo clone djordjeveljkovic/pi-workflow         ~/.pi/agent/extensions/workflow
gh repo clone djordjeveljkovic/pi-skills-library   ~/.pi/agent/skills-library

(cd ~/.pi/agent/extensions/skill-manager && npm install)
```

`settings.json` additions (auto-merged if missing):

```json
{
  "extensions": [
    "extensions/skill-manager",
    "extensions/list-picker/extension.ts"
  ]
}
```

After install, `/reload` (or restart pi) activates:

| Command | Purpose |
|---|---|
| `/skills` | compact list of enabled skills |
| `/skills:list` | TUI: browse + toggle + filter |
| `/skills:manage` | enable/disable/all/reset menu |
| `/skills:enable <name>` / `/skills:disable <name>` | one-shot |
| `/skills:enable-all` / `/skills:reset` | bulk |
| `/skills:status` | library path + state file + counts |

The skill library is in `~/.pi/agent/skills-library/`, managed by `pi-skill-manager`'s state file at `~/.pi/agent/skill-state.json`.
