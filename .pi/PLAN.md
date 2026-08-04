# checkout what is configured on the system, and what is configured in the dots, the system should be main, dots should create the system as it is now

_Generated: 2026-08-04T08:52:13.653Z_
_Last updated: 2026-08-04T10:05:03.204Z_

## Context

Project: `/home/usrtmp/.dots`

## Clarifications

### 1. How broad should “dots should create the system as it is now” be?

**Answer:** Desktop environment: managed dotfiles plus Hyprland-related packages, services, themes, and system settings

### 2. Should the plan remove the remaining Omarchy integration and consolidate desktop ownership under ~/.dots?

**Answer:** Remove Omarchy integration and make ~/.dots the sole owner of desktop configuration

### 3. Should the new dark/light toggle remain part of the target setup?

**Answer:** Keep and fully integrate the dark/light toggle into the reconciled desktop

### 4. After importing the current system state, how should ~/.dots deploy managed configuration?

**Answer:** Use symlinks/direct includes so ~/.dots remains the canonical source after reconciliation

### 5. How should the plan handle the live API-backed Bash/Zed integrations?

**Answer:** Omit all API/model integrations and credentials from the reproducible desktop

### 6. Which dark appearance should the reconciled setup reproduce?

**Answer:** Standardize dark mode on Catppuccin across all desktop components


## Research Notes

### 1. 2026-08-04T08:56:48.192Z

Initial audit: live system and repo diverge substantially. Exact matches: fastfetch, wofi, and nvim-012. Differences exist for Alacritty, btop, Git, Hyprland/Hyprlock, main Neovim, Sway, Waybar, Zed, ~/.tmux.conf, and ~/.ssh/config. Live Hyprland uses monolithic default/hypr/{bindings,media}.conf and does not source current/theme/hyprland.conf; repo config/hypr/hyprland.conf currently references nonexistent default/hypr/bindings/{media,tiling,utilities}.conf, so deploying repo as-is would break Hyprland. Live btop and Mako still point into ~/.config/omarchy rather than ~/.dots. Live Alacritty imports current/theme/rose.toml, while repo imports current/theme/alacritty.toml. The prior theme-toggle work has uncommitted current/theme changes and new Catppuccin Latte files.

### 2. 2026-08-04T08:56:56.895Z

Audit finding: live system and repo diverge substantially. Exact matches include fastfetch, wofi, and nvim-012. Differences exist for Alacritty, btop, Git, Hyprland/Hyprlock, main Neovim, Sway, Waybar, Zed, ~/.tmux.conf, and ~/.ssh/config. Live Hyprland uses monolithic default/hypr/{bindings,media}.conf and does not source current/theme/hyprland.conf; repo config/hypr/hyprland.conf references nonexistent default/hypr/bindings/{media,tiling,utilities}.conf, so deploying repo as-is would break Hyprland. Live btop and Mako still point into ~/.config/omarchy. Live Alacritty imports current/theme/rose.toml. Prior theme-toggle work remains uncommitted.

### 3. 2026-08-04T08:57:38.172Z

Security finding: live Bash and Zed settings contain API credentials. These must not be copied into Git; the sync should redact them and use an ignored local secrets file or environment injection. SSH config has additional live hosts but no private key material. Live user systemd contains both reusable dotfile services and machine/project-specific services.

### 4. 2026-08-04T10:02:41.290Z

Live desktop command audit found all referenced core commands installed. Installer is missing several currently required packages, including uwsm, hyprpaper, hyprsunset, fuzzel, swayosd, ghostty, yazi, btop, calcure, lazydocker, Steam, and some launcher/keybinding dependencies. Current boot/login state conflicts: minimal and Omarchy seamless login are both enabled, getty@tty1 is also enabled with a stale autologin override for another username, and display-manager.service points to Lemurs even though its executable is not package-owned/present.


# System-first desktop reconciliation plan

## Goal and scope

Make the **currently running Arch/Hyprland desktop** the baseline for this repository, then normalize the few explicitly chosen differences:

- `~/.dots` becomes the sole owner of managed desktop configuration.
- Managed files are deployed with symlinks/direct includes rather than copied, preventing future repo/live drift.
- Remove remaining Omarchy ownership and conflicting legacy login links/services.
- Preserve current live behavior and settings for managed applications, except:
  - standardize both the active and toggled dark mode on Catppuccin;
  - retain and fully integrate the new Catppuccin dark/light toggle;
  - omit all API credentials and API/model integrations from Bash and Zed;
  - exclude project-specific services and mutable application state.
- Cover the desktop environment, its command/package dependencies, reusable user services, and relevant boot/login/system settings. Do not attempt to snapshot all 350 explicitly installed packages or all of `~/.config`.

## Phase 1 — Establish a safe, explicit ownership manifest

1. Add a repository manifest, proposed as `manifest/desktop.conf`, describing:
   - each repo source and live destination;
   - whether the destination is a file or directory symlink;
   - required desktop packages/commands;
   - expected user/system services;
   - expected GSettings values and theme state;
   - files intentionally excluded as secrets, caches, databases, runtime state, or project-specific configuration.
2. Add `.gitignore` rules for generated active-theme state, local secrets, backups, and audit output.
3. Add `bin/script-audit-system` as a read-only checker that reports:
   - missing or incorrectly targeted symlinks;
   - managed file drift;
   - missing required executables/packages;
   - unexpected Omarchy references in managed desktop files and enabled services;
   - expected login, portal, power, and desktop service state;
   - current system color mode and selected palette.
4. Ensure the audit never prints secret values. It should report only file paths and setting names for excluded sensitive files.

## Phase 2 — Import the live managed configuration

Use the live system as the source for behavior, then apply the agreed normalization rather than blindly copying caches or credentials.

### Application configuration

1. Reconcile `config/alacritty/alacritty.toml` with the live file:
   - preserve live font size, Vi-mode keybinding, padding, opacity, and window behavior;
   - replace the live Rose Pine import with the canonical generated active theme path.
2. Replace `config/btop/btop.conf` with the current btop 1.4.7-compatible live configuration, including current layout, Vim keys, update rate, rounded-corner, and CPU-power preferences.
3. Clean `config/git/` into one canonical level (`config`, `ignore`, `template`), removing the recursively nested `git/git/...` copies created by repeated `cp -R` deployment. Import the safe live versions.
4. Reconcile `config/hypr/`:
   - make `config/hypr/hyprland.conf` match the working live source layout using `default/hypr/bindings.conf` and `default/hypr/media.conf`;
   - restore an active-theme source only after the generated theme path exists;
   - import the live wallpaper/blur/transparent-input behavior from `~/.config/hypr/hyprlock.conf`;
   - add the live `hyprpaper.conf` only if it has durable configuration not already handled by `script-wallpaper`;
   - keep the active monitor layout from `default/hypr/monitors.conf`, remove duplicate/obsolete monitor filename variants, and make paths use `$HOME` rather than hard-coded `/home/usrtmp` where Hyprland syntax permits.
5. Replace the main `config/nvim/` with the current live Neovim configuration, excluding `.git`, caches, downloaded plugins, and machine-local state. Keep `config/nvim012/` because it already exactly matches `~/.config/nvim-012`.
6. Reconcile `config/sway/config` with the live fallback configuration, then re-enable a valid generated theme include after adding Sway dark/light theme files.
7. Import the minor live Waybar style changes into `config/waybar/style.css`; retain the active-theme import. Keep Wofi and Fastfetch unchanged because they already match live state.
8. Reconcile `config/zed/settings.json` with safe live UI/editor preferences, including current completion and finder behavior, while removing:
   - `agent_servers`;
   - `agent` model configuration;
   - `language_models` and embedded API keys;
   - Ollama/edit-prediction model integration.
   Configure Zed to follow the system dark/light preference where supported.
9. Import the live `~/.tmux.conf` into the canonical `default/.tmux.conf`, including the live prefix, hidden status bar, colors, clipboard copy, Alt-number bindings, and resurrect plugin.
10. Keep `~/.bashrc` reproducible as a single include of `default/bash/rc`. Preserve live Angular completion only as a conditional, non-failing hook in `default/bash/init`; do not import API-key exports.
11. Reconcile `default/sshconfig` with the current live host entries, but never copy private keys or credentials. Confirm permissions remain `0600` on deployment.

### Reusable desktop services

12. Add safe, reusable user units under `config/systemd/user/` for the live desktop-owned services:
   - battery monitor service/timer;
   - time notification service/timer;
   - MPD service only if its durable `mpd.conf` is also added.
13. Exclude project-path services (`maps-scraper`, `outreach-astro`, and laptop-controller companion) and all runtime databases, PID files, logs, tokens, and timer state.
14. Remove the duplicate Omarchy battery timer from the target service set.

## Phase 3 — Canonical dark/light theming

1. Keep `themes/catppuccin/` as the canonical dark palette and complete `themes/catppuccin-latte/` as the canonical light palette.
2. Validate that each palette supplies every consumed component:
   - `alacritty.toml`;
   - `btop.theme`;
   - `hyprland.conf`;
   - `hyprlock.conf`;
   - `mako.ini`;
   - `waybar.css`;
   - `wofi.css`;
   - new `sway.conf`.
3. Stop tracking mutable copied files in `current/theme/`. Make it a generated/ignored symlink (or generated directory) pointing to the selected tracked palette so toggling does not dirty Git.
4. Refactor `bin/script-toggle-theme` to atomically switch that generated target and update:
   - `org.gnome.desktop.interface color-scheme`;
   - GTK theme (`Adwaita`/`Adwaita-dark`);
   - Kvantum (`KvGnome`/`KvGnomeDark`) when installed;
   - Zed via system mode rather than rewriting its tracked settings;
   - Hyprland, Sway, Waybar, Mako, and other live-reload-capable processes.
5. Initialize fresh installs in Catppuccin dark mode, matching the agreed standardized live baseline.
6. Add a Hyprland and Sway keybinding for `script-toggle-theme` in `default/hypr/bindings.conf` and `default/sway/bindings`, selecting a currently unused chord during implementation.
7. Repair stale theme consumers:
   - replace `~/.config/btop/themes/current.theme -> ~/.config/omarchy/...` with a dots-owned link;
   - replace `~/.config/mako/config -> ~/.config/omarchy/...` with a dots-owned link;
   - ensure Alacritty, Waybar, Wofi, Hyprlock, Hyprland, and Sway all resolve only to `~/.dots` paths.

## Phase 4 — Replace copy deployment with idempotent linking

1. Refactor `install/4-config.sh` around a shared helper in `lib/helpers.sh` that:
   - creates parent directories;
   - backs up an existing non-matching destination to `~/.local/state/dots/backups/<timestamp>/`;
   - creates relative or absolute symlinks deterministically;
   - is safe to run repeatedly;
   - never follows a stale destination symlink while copying.
2. Link each managed application directory/file from the manifest into `~/.config`, including the special `nvim012 -> ~/.config/nvim-012` mapping.
3. Link `~/.tmux.conf`, `~/.bashrc`, and `~/.ssh/config` to canonical repo files with correct permissions and no `sudo` for user-owned files.
4. Remove the existing broad `cp -R ~/.dots/config ~/.config` and `cp -R ~/.dots/config/* ~/.config` operations that caused nested Git config directories and silent drift.
5. Add an explicit migration step that backs up and then replaces current live files/symlinks. It must list changes before applying and support a non-destructive `--dry-run`.
6. Remove stale managed links into `~/.config/omarchy`; do not delete unrelated Omarchy files until all managed consumers and services have been verified migrated.

## Phase 5 — Align packages and desktop services

1. Add a curated desktop package list, proposed as `install/packages-desktop.txt`, based on package ownership of commands actually referenced by the active configs/scripts. Include at minimum the currently installed owners of:
   - Hyprland/UWSM, hypridle, hyprlock, hyprpaper, hyprpicker, hyprshot, hyprsunset;
   - Waybar, Wofi, Fuzzel, Mako, swayosd, swaybg;
   - xdg-desktop-portal, `xdg-desktop-portal-hyprland`, and `xdg-desktop-portal-gtk`;
   - Alacritty, Ghostty, yazi, btop, impala, wiremix, bluetui, calcure, lazydocker;
   - cliphist, wl-clipboard, brightnessctl, playerctl, libnotify, jq;
   - Kvantum/Adwaita support and fonts used by the configs;
   - explicitly bound desktop applications such as Chrome and Steam.
2. Refactor `install/desktop.sh`, `install/hyprlandia.sh`, and related scripts to consume the curated list without duplicated package declarations.
3. Add preflight checks for `yay`, network access, required repository/AUR availability, and a post-install command ownership audit.
4. Reconcile desktop services to one owner:
   - keep and enable `minimal-seamless-login.service`;
   - disable/remove `omarchy-seamless-login.service`;
   - remove the stale `display-manager.service -> lemurs.service` link;
   - remove the stale `getty@tty1` autologin override and disable tty1 getty only after verifying minimal seamless login;
   - enable the required Bluetooth, IWD, CUPS, portal/session, and selected user timer services idempotently.
5. Consolidate power management on the repo-supported `power-profiles-daemon` balanced profile and disable stale/conflicting TLP activation if present.

## Phase 6 — Reproduce relevant system settings

1. Move the embedded seamless-login C source and service template out of `install/login.sh` into tracked files such as:
   - `system/seamless-login.c`;
   - `system/systemd/minimal-seamless-login.service.in`.
   Render the user safely during install rather than storing `usrtmp` in the template.
2. Reconcile the current AMD laptop boot configuration:
   - Plymouth hook and image;
   - `amdgpu`, NVMe, USB, and ext4 initramfs modules;
   - current quiet GRUB command line and hidden menu settings.
   Preserve NVIDIA handling as conditional code for other machines rather than applying NVIDIA settings here.
3. Track/install the current durable hardware overrides where appropriate:
   - `/etc/modprobe.d/hid_apple.conf`;
   - `/etc/udev/rules.d/99-touchpad-power.rules`.
4. Preserve current locale (`en_US.UTF-8`), keymap, timezone (`Europe/Belgrade`), Wayland environment, dark initial GSettings, and balanced power profile through idempotent installer steps.
5. Do not reproduce hostname, transient hardware IDs, runtime process state, caches, package databases, browser profiles, or application histories.

## Phase 7 — Validation and documentation

1. Run Bash syntax checks and ShellCheck on all text shell scripts; explicitly skip compiled binaries in `bin/` (`script-info`, `script-monitors-pick`).
2. Validate all source/include/import paths and fail if any managed reference is missing. This must catch the currently broken:
   - `default/hypr/bindings/{media,tiling,utilities}.conf` references;
   - missing Sway theme include;
   - missing `default/wofi/select.css` reference.
3. Test install/link logic in a temporary HOME with both `--dry-run` and apply modes. Re-running apply must produce no changes.
4. Test dark → light → dark in an isolated environment and verify every expected palette file, GSettings operation, and reload action.
5. On the live machine, run the migration in this order:
   - audit and backup;
   - deploy links;
   - initialize dark theme;
   - reload user services and desktop components;
   - remove Omarchy service/link ownership;
   - rerun audit.
6. Verify after migration:
   - every managed destination resolves into `~/.dots`;
   - no managed file or enabled desktop service references `~/.config/omarchy`;
   - Hyprland config validation/reload succeeds;
   - Waybar, Mako, portals, lock screen, launchers, audio/brightness OSD, and wallpaper processes start correctly;
   - btop and Alacritty use the Catppuccin dark palette;
   - the theme toggle switches all covered components and returns cleanly;
   - `git status` remains clean after toggling.
7. Rewrite `current_setup.md` to reflect the audited implementation rather than the current stale snapshot. Document:
   - source-of-truth and symlink model;
   - managed/excluded scope;
   - package and service ownership;
   - theme toggle behavior;
   - migration, audit, rollback, and fresh-install commands.

## Risks and open questions

- **Live-session disruption:** replacing Hyprland, Mako, Waybar, portal, or login configuration can interrupt the session. Apply user config first; defer login/service cleanup until validation succeeds.
- **Boot/login risk:** removing overlapping getty/display-manager/Omarchy services must be staged and retain a rollback path from a TTY or live medium.
- **Symlink migration:** existing files must be backed up before replacement; directory symlinks must not swallow unmanaged runtime files.
- **Application-generated config:** btop and Zed may rewrite linked config. Keep only durable settings and accept intentional repo diffs, or link individual stable files rather than whole stateful directories.
- **Nested Git config cleanup:** repeated copy deployment produced multiple conflicting levels; choose the live top-level files and verify Git resolves `XDG_CONFIG_HOME/git/config` as intended before deleting backups.
- **Secrets already present live:** no credential values may enter the repository, logs, plan, audit output, or documentation. Existing exposed credentials should be rotated independently.
- **Hardware specificity:** monitor coordinates, initramfs modules, and udev rules describe this laptop. Keep conditional guards so a fresh install on different hardware does not become unbootable.
- There are no remaining product decisions blocking implementation; the user selected desktop scope, dots-only ownership, symlink deployment, Catppuccin dark standardization, retention of the toggle, and omission of API/model integrations.

## Acceptance criteria

- `bin/script-audit-system` reports no drift or stale Omarchy ownership for the managed desktop.
- All managed live config destinations resolve to canonical files under `~/.dots`; rerunning installation is idempotent.
- A temporary fresh HOME can run the deployment and resolve every config include/import without missing files.
- Required commands used by active keybindings/autostart are installed by the curated desktop package manifest.
- Exactly one login path is enabled: dots-owned minimal seamless login; stale Omarchy, Lemurs, and tty1 autologin ownership is removed.
- No tracked file contains API credentials, model-provider configuration, private keys, tokens, caches, databases, PIDs, logs, or project-specific service paths.
- Hyprland starts/reloads successfully and the current desktop behavior matches the audited live settings.
- Dark mode is consistently Catppuccin; light mode is consistently Catppuccin Latte across GTK/system preference, Qt/Kvantum, terminal, bar, launcher, notifications, lock screen, btop, Hyprland/Sway colors, and Zed system theme.
- Toggling themes does not modify tracked files or leave Git dirty.
- Current wallpaper, monitor layout, input settings, keyboard shortcuts, OSD, idle/lock behavior, and reusable timers function after migration.
- `current_setup.md` accurately documents the resulting system and recovery procedure.
