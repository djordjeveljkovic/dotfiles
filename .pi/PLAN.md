# checkout the new_age branch, and i want you to create a new branch called symbiosis that branch will be main and new_age merged, but i like the minimalisam of new_age but there is some stuff i have in main that are missing in new_age and some stuff that is too much in main. symbiosis branch should have configuration that is universal not dependant on the wayland compositor, meaning same configuration and i can change whether i use hyprland or sway or any other compositor. My main focus on the configuration is that it's minimal not heavy on the system and easily maintainable

_Generated: 2026-08-04T15:03:00.795Z_
_Last updated: 2026-08-04T16:40:26.437Z_

## Context

Project: `/home/usrtmp/.dots`

## Clarifications

### 1. Should the current uncommitted changes be included in symbiosis?

**Answer:** Carry the current uncommitted changes into symbiosis; do not modify main/new_age

### 2. What compositor architecture should symbiosis use?

**Answer:** One shared common layer plus separate thin compositor adapters (Hyprland/Sway), selected by a single environment variable or installer option

### 3. Which default scope should the symbiosis desktop profile target?

**Answer:** Use new_age's minimal package set as the default and selectively restore only missing main features after comparison

### 4. Which category of main's missing functionality should symbiosis restore first?

**Answer:** Treat all main functionality as candidates and decide after a full diff review


## Research Notes

### 1. 2026-08-04T15:03:25.317Z

Repository is on main with extensive uncommitted work; origin/new_age points to 7980db7 and main/origin/main to 99ad29f. User explicitly wants a new symbiosis branch based on new_age with main merged, so current dirty work must not be accidentally included unless user confirms. The branches differ across a large refactor: new_age commits include profile-aware installer, theme system, sway-native scripts/bindings/waybar/kanshi, removal of Hypr-based scripts/compiled binaries and duplicate configs. Current working tree contains many modifications/untracked files likely pending changes and .pi/PLAN.md.

### 2. 2026-08-04T15:03:30.667Z

Repository is on main with extensive uncommitted work; origin/new_age points to 7980db7 and main/origin/main to 99ad29f. User explicitly wants a new symbiosis branch based on new_age with main merged, so current dirty work must not be accidentally included unless user confirms. The branches differ across a large refactor: new_age commits include profile-aware installer, theme system, sway-native scripts/bindings/waybar/kanshi, removal of Hypr-based scripts/compiled binaries and duplicate configs. Current working tree contains many modifications/untracked files likely pending changes and .pi/PLAN.md.

### 3. 2026-08-04T16:39:45.376Z

Clarified decisions: create/work only on symbiosis; carry current uncommitted changes into symbiosis; leave main/new_age unchanged. Architecture: shared common layer plus thin Hyprland/Sway adapters selected by one environment variable or installer option. Default should use new_age's minimal package set, restoring main functionality only after full diff review; all main features are candidates, not automatic inclusions. Branch refs are local only (no origin/* refs); main=bdc9822, new_age=7980db7. Branch diff is ~210 files/7726 insertions/2175 deletions, with main's two commits mostly representing current setup and new_age's commits performing major cleanup/refactor.


# Symbiosis Branch Implementation Plan

## Goal & scope

Create and work exclusively on a new `symbiosis` branch. Leave `main` and `new_age` unchanged. Start from `new_age`, merge `main`, preserve the user's current uncommitted work in `symbiosis`, and reconcile the resulting tree into a minimal, maintainable, compositor-independent Wayland setup.

The target design is a shared common configuration plus thin compositor adapters for Hyprland and Sway. A single profile/selection mechanism should choose the adapter without duplicating application configuration. The default desktop profile should follow `new_age`'s smaller package set, while selectively restoring useful functionality from `main` after reviewing the complete branch diff.

## Steps

### 1. Protect branch state and create the working branch

- Verify the worktree and refs without modifying either source branch.
- Create `symbiosis` from `new_age` while carrying the existing worktree changes forward.
- Merge `main` into `symbiosis`; resolve conflicts deliberately, favoring the new_age cleanup where functionality is redundant or compositor-specific, while retaining main functionality that remains lightweight and useful.
- Confirm `main` and `new_age` hashes are unchanged before and after the operation.
- Do not commit or discard user changes without explicit instruction.

### 2. Compare and classify the merged tree

Review the complete `main`/`new_age` diff and classify files into:

- shared, compositor-neutral configuration (`config/alacritty`, `config/btop`, `config/git`, `config/nvim`, `config/zed`, shell, tmux, SSH, themes, user services);
- compositor adapters (`default/hypr`, `default/sway`, compositor-specific lock/idle/autostart/bindings/window rules);
- shared Wayland services (`waybar`, launcher, notifications, wallpaper, portals, audio/brightness helpers);
- optional/heavy features and binaries that should not be in the minimal default;
- installer and system/login behavior that needs profile-aware handling.

Record the decisions in repository documentation so future maintenance does not require repeating the branch archaeology.

### 3. Establish the common/adapters configuration structure

- Add a clearly named common configuration area for shared environment variables, commands, keybinding intent, theme paths, service units, and application configs.
- Keep Hyprland syntax in a thin Hyprland adapter and Sway syntax in a thin Sway adapter; avoid embedding `hyprctl` or `swaymsg` in shared files.
- Normalize common actions behind small wrapper scripts/functions (for example reload bar, lock, idle toggle, wallpaper, screenshot, theme reload, workspace movement) so bindings and services call stable interfaces.
- Replace Waybar's compositor-specific workspace module/configuration with a selected adapter or a neutral module strategy, preserving one shared style/theme source.
- Ensure theme selection continues through one active-theme link and that both adapters consume the same theme assets where possible.
- Make compositor selection explicit through one environment/profile setting, with a safe default and validation for unsupported values.

Likely touch points include `config/`, `default/bash/`, `default/hypr/`, `default/sway/`, `config/waybar/`, `themes/*`, `bin/`, `lib/helpers.sh`, and `manifest/desktop.conf`. Exact new paths should follow the existing repository naming conventions after the merge.

### 4. Simplify installer and package profiles

- Use `new_age`'s profile-aware installer as the base.
- Define a minimal desktop package list containing only required shared tools and the selected compositor adapter.
- Keep specialized development, hardware, printer, Docker/Podman, login, NVIDIA, and other integrations optional or separately gated where they are not required for the minimal desktop.
- Make configuration deployment select only the chosen adapter while always deploying shared files.
- Make install scripts idempotent and avoid installing Hyprland-specific packages when Sway is selected, and vice versa.
- Update `install.sh`, `install/*.sh`, `manifest/desktop.conf`, and helper functions together so package selection, links, runtime commands, and audit behavior agree.
- Preserve lightweight useful main features identified in the comparison, especially universal dotfiles and durable user services; omit duplicate, compiled, or tightly compositor-bound features unless they provide clear value.

### 5. Restore selected main functionality

After the diff review, selectively reintroduce missing main functionality into the common layer or an optional feature module. Candidates include useful Neovim modules/plugins, systemd user timers/services, theme integrations, login/power behavior, desktop helpers, and application configuration. Each restored feature must have:

- a clear owner/path;
- a dependency declaration or optional gate;
- no compositor-specific command in common code;
- a reason it belongs in the minimal default or why it is optional.

Avoid restoring redundant configurations, stale duplicates, machine-specific monitor files, secrets, large generated binaries, or features that substantially increase maintenance burden.

### 6. Documentation and audits

- Update `current_setup.md` (or the post-new_age documentation source) to describe the symbiosis layout, compositor selection, minimal/default versus optional features, install commands, and switching procedure.
- Update audit logic in `bin/script-audit-system` and related helpers to validate shared links, the selected adapter, source paths, required commands, and absence of invalid cross-compositor references.
- Add comments at adapter boundaries explaining what belongs in common versus compositor-specific files.

### 7. Verification

Run, as applicable:

- shell syntax checks (`bash -n`) across changed installer and helper scripts;
- static reference checks for unresolved `source`/`include` paths and compositor commands in shared files;
- manifest/deployment dry-run or audit checks;
- package/profile consistency checks;
- Neovim configuration validation if available;
- Git diff review ensuring no accidental changes to `main` or `new_age` refs;
- focused smoke tests for both adapter selections, including bar, launcher, notification, lock/idle, wallpaper, screenshots, media keys, theme switching, and workspace bindings.

## Risks & open questions

- The current worktree is heavily dirty, with modifications, deletions, and untracked files; carrying it through branch creation and merge may create conflicts or include partially completed work. No user work should be discarded.
- There are no remote-tracking refs named `origin/main`/`origin/new_age` in the local repository; the local branch refs must be used unless remote fetching is explicitly requested.
- Hyprland and Sway have materially different configuration languages and command APIs. Full universalization is not realistic; the common layer must call adapters/wrappers rather than pretending syntax is shared.
- Some current scripts and themes use compositor-specific names or commands (`hyprctl`, `swaymsg`, Hyprland/ Sway Waybar modules) and need careful separation.
- The exact list of main features to restore is intentionally deferred until the complete branch diff is reviewed.
- Monitor layouts and hardware-specific behavior should remain user/machine overrides rather than universal defaults.
- Whether the selected compositor should be changed at runtime or only at install/login time must be implemented consistently; the plan assumes one explicit profile variable and adapter selection at deployment/session startup.

## Acceptance criteria

- `symbiosis` exists and is the only branch modified; `main` and `new_age` retain their original commit IDs and working-tree state.
- The existing uncommitted changes are present in `symbiosis` and no user files were silently discarded.
- `symbiosis` contains the merged history/content of `new_age` and `main`, reconciled rather than blindly favoring one side.
- Shared configuration contains no direct Hyprland- or Sway-only syntax/commands.
- Hyprland and Sway each have a small, explicit adapter selected by one documented setting or installer option.
- Shared Wayland tools, themes, application configs, shell, editor, and user services are deployed identically regardless of compositor.
- The default desktop profile follows the minimal new_age package baseline, with restored main functionality justified and optional heavy features gated.
- Installation and reinstallation are idempotent, do not install the wrong compositor stack, and do not overwrite unmanaged files without the existing backup behavior.
- Audit/static checks pass for both compositor selections, and changed scripts/configs pass syntax/reference validation.
- Documentation explains the architecture, selection process, dependencies, optional features, and verification commands.
## Implementation Status (2026-08-04)

Branch `symbiosis` created from `new_age` at `7980db7`, merged `main` (`bdc9822`),
preserved the user's uncommitted `.pi/PLAN.md` content. The merge produced three
commits on top of `new_age`; `main` and `new_age` refs were never moved.

1. `00f6a7a` — merge main into symbiosis (new_age + main reconciled)
2. `140f0d7` — refactor scripts to route compositor-specific calls through
                `dots_compositor` / `dots_compositor_cmd`
3. `55cf3d5` — docs + `install.sh --compositor` flag

### Architecture delivered

* Shared base: `install/desktop.sh` installs the common Wayland stack
  (waybar, mako, fuzzel, polkit-gnome, audio, fonts, TUIs) and then
  dispatches to one of two thin adapters.
* Compositor adapters: `install/compositor-sway.sh`,
  `install/compositor-hyprland.sh`. Each installs the compositor's own
  package set and writes `~/.config/dots/compositor` so downstream steps
  can detect the adapter without an env var.
* Selection: `DOTS_COMPOSITOR=sway|hyprland` env var, `--compositor`
  CLI flag to `install.sh`, or interactive prompt in the installer.
* Universal entrypoint: `bin/dots-session`, called from `~/.bash_profile`
  (auto-login on tty1).
* Dispatcher: `lib/helpers.sh::dots_compositor` + `dots_compositor_cmd`.
* Waybar adapter: `bin/script-apply-waybar-compositor` rewrites
  `config/waybar/config`'s workspace module to match the active
  compositor (Waybar has no config conditionals).

### Verification results

| Check | Result |
|---|---|
| `bash -n` on every `*.sh` | 0 errors |
| Manifest source existence | 0 missing |
| Shared files with direct `swaymsg`/`hyprctl` calls | 0 (only the dispatcher in `lib/helpers.sh`) |
| Sway/Hyprland adapter symmetry | 8 vs 9 source files (Hyprland has `monitors.conf`) |
| `bin/script-audit-system` end-to-end | 40 OK, 3 expected Omarchy warnings, 0 errors |
| All Hyprland `source =` paths resolve | OK |
| All Sway `include` paths exist | OK |
| `main`/`new_age` refs unchanged | bdc9822 / 7980db7 (verified) |
