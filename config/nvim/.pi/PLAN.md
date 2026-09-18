# i want you to use rose pine theme for the lazyvim nvim setup, also the current setup isn't good for handling php, javascript, nodejs, react, vue, python, go, rust, laravel programming update it, also add support for latex and typst, also add markdown to do tasks and so on with markdown preview

_Generated: 2026-09-14T14:42:00.191Z_
_Last updated: 2026-09-15T15:00:29.174Z_

## Context

Project: `/home/usrtmp/.dots/config/nvim`

## Clarifications

### 1. Rosé Pine needs `termguicolors=true` and defines its own background colors, which directly conflicts with your current transparent setup (`termguicolors=false` + an autocmd that strips every background so the terminal wallpaper shows through). How should the Rosé Pine theme be applied?

**Answer:** Full Rosé Pine (opaque backgrounds, termguicolors=true) — drop the old transparent hack

### 2. Which PHP language server should I configure?

**Answer:** phpactor (LazyVim default, free, good Laravel/composer support)

### 3. How much Laravel-specific support do you want?

**Answer:** Add adalessa/laravel.nvim (artisan/route/tinker pickers) + Blade treesitter

### 4. Do you want debugging (DAP) and test-runner (neotest) support included for those languages?

**Answer:** Yes — add dap.core + test.core (full debugging & test runner for all languages)

### 5. Which supporting dev extras should I include alongside the language support?

**Answer:** All recommended: tailwind + eslint + prettier + json + yaml + docker + sql

### 6. How should the LazyVim extras be registered?

**Answer:** Spec files under lua/plugins/ (version-controlled, matches existing mini-surrond.lua pattern)


## Research Notes

### 1. 2026-09-14T14:42:41.474Z

Current config: stock LazyVim (nvim 0.12.5, LazyVim main) on branch `symbiosis`, with prior customizations already applied:
- lua/plugins/colorscheme.lua: disables tokyonight, sets colorscheme="default" (built-in)
- lua/config/options.lua: showtabline=0, termguicolors=false (terminal palette)
- lua/config/autocmds.lua: ColorScheme autocmd strips ALL bg/ctermbg -> full transparency, only text colored
- lua/plugins/disable-bufferline.lua, dashboard.lua (chafa samurai image), mini-surrond.lua (mini-surround extra import), keymaps uy/<leader>p clipboard
- lua/lazyvim.json: extras=[]
- Installed plugins (lazy-lock): blink.cmp, LazyVim, snacks, treesitter, lspconfig, mason, conform, nvim-lint, lualine, noice, gitsigns etc. No rose-pine, no vimtex, no typst, no render-markdown, no laravel.

### 2. 2026-09-14T14:42:41.477Z

CONFLICT: Rose Pine requires termguicolors=true and defines its own highlight backgrounds. The existing transparent setup (termguicolors=false + autocmd stripping all bg) directly fights rose-pine. Must decide: full Rose Pine opaque, or Rose Pine with transparent background (keep terminal wallpaper). Either way the strip-backgrounds approach and `colorscheme="default"` must be replaced.

### 3. 2026-09-14T14:42:46.662Z

LazyVim extras available and relevant (verified in ~/.local/share/nvim/lazy/LazyVim/lua/lazyvim/plugins/extras):
- lang.php (phpactor default, or intelephense via vim.g.lazyvim_php_lsp; phpcs/php-cs-fixer; neotest pest+phpunit)
- lang.typescript (+ lang.typescript.vtsls default) covers JS/Node/React/TS/JSX
- lang.vue (depends on typescript extra), lang.svelte, lang.angular
- lang.python (pyright + ruff + venv-selector + dap-python + neotest)
- lang.go (gopls, goimports/gofumpt, golangci-lint, delve/dap-go, neotest-golang)
- lang.rust (rustaceanvim, crates.nvim, codelldb)
- lang.tex (vimtex + texlab), lang.typst (tinymist + typst-preview.nvim)
- lang.markdown (marksman, markdownlint-cli2, markdown-toc, markdown-preview.nvim <leader>cp, render-markdown.nvim)
- lang.tailwind, lang.json, lang.yaml, lang.docker, lang.sql, lang.twig
- linting.eslint, formatting.prettier
- dap.core, test.core (optional)
Laravel/Blade: NO dedicated LazyVim extra. Blade treesitter parser exists (unstable). Custom plugin needed for artisan/routes: adalessa/laravel.nvim (exists on GitHub). Blade LSP: twiggy is Twig not Blade; no LazyVim support - would need manual blade-language-server.
Existing user pattern for extras: import spec file, e.g. lua/plugins/mini-surrond.lua `return { import = "lazyvim.plugins.extras.coding.mini-surround" }`. Alternative is lazyvim.json extras list (:LazyExtras).

### 4. 2026-09-14T14:42:46.664Z

Markdown: lang.markdown disables render-markdown checkbox rendering (`checkbox = { enabled = false }`) - must override to enable `- [ ]` / `- [x]` task rendering. Also markdown-preview.nvim already provides browser preview bound to <leader>cp for md files. typst extra also binds <leader>cp but ft=typst scoped, so no real conflict.
Latex: `tectonic` installed but `latexmk`/xelatex/pdflatex NOT installed. vimtex defaults to latexmk -> must set vim.g.vimtex_compiler_method="tectonic" (or install texlive). Typst: `typst` binary NOT in PATH; tinymist (mason) can compile, typst-preview.nvim needs tinymist. Node v26, php 8.5, go, cargo, composer, npm, python3 all present. Nerd fonts present. Network available for plugin install.

### 5. 2026-09-15T14:59:14.246Z

CLARIFICATIONS (from user):
1. Theme: Full Rosé Pine, opaque, termguicolors=true — drop the old transparent hack (remove strip_all_backgrounds autocmd, remove termguicolors=false).
2. PHP LSP: phpactor (LazyVim default / vim.g.lazyvim_php_lsp="phpactor").
3. Laravel: add adalessa/laravel.nvim (artisan/routes/tinker pickers, provider=snacks) + Blade treesitter parser. Blade filetype auto-detected for *.blade.php (nvim runtime filetype.lua:2716).
4. Debug/test: include dap.core + test.core extras (full DAP + neotest for all languages).
5. Supporting extras: all recommended — tailwind, eslint, prettier, json, yaml, docker, sql.
6. Extras registered as spec files under lua/plugins/ (version-controlled), matching existing mini-surrond.lua pattern.

### 6. 2026-09-15T14:59:14.248Z

Environment facts verified:
- nvim 0.12.5; LazyVim main (018.../main); env: node v26, php 8.5, python3, go+gopls, cargo+rust-analyzer, composer, npm, rg. Nerd fonts present.
- Installed colorschemes: tokyonight (disabled), catppuccin (lazy, from LazyVim core). rose-pine NOT installed yet; GitHub reachable.
- Missing binaries: pyright (mason will install via extra), texlab (mason), tinymist (mason), typst binary (tinymist compiles; typst-preview.nvim uses tinymist), lua-language-server (not needed).
- latex tools: only `tectonic` installed; `latexmk`/pdflatex MISSING -> must set vim.g.vimtex_compiler_method="tectonic".
- markdown-preview.nvim build downloads binary via node (present).
- laravel.nvim nvim-nio/plenary/nui dependencies; ripgrep required and present.
- markdown extra disables render-markdown checkboxes -> override checkbox.enabled=true for markdown TODO tasks.


# Rosé Pine + Polyglot LazyVim Setup

## Goal & Scope

Turn the current minimal LazyVim config into a full polyglot dev environment:

1. **Theme** — replace the built-in "default"/transparent setup with **Rosé Pine** (opaque, true color). Drop the old background-stripping hack.
2. **Languages** — first-class support for PHP/Laravel, JavaScript/Node/React/TypeScript, Vue, Python, Go, Rust.
3. **Documents** — LaTeX (vimtex + texlab, tectonic) and Typst (tinymist + live preview).
4. **Markdown** — TODO/checkbox task rendering, linting/formatting, and in-browser preview.

All changes follow LazyVim guidelines: nothing in `~/.local/share/nvim/lazy/LazyVim` is edited; everything lives in `lua/config/*` and `lua/plugins/*`. Extras are registered as **version-controlled import spec files** (per user choice), matching the existing `mini-surrond.lua`.

### Decisions locked in (clarify phase)
- Theme: **full Rosé Pine, opaque, `termguicolors=true`** (transparent hack removed).
- PHP LSP: **phpactor** (LazyVim default).
- Laravel: **adalessa/laravel.nvim** + **Blade** treesitter.
- Debug/test: **dap.core + test.core** enabled.
- Supporting extras: **tailwind, eslint, prettier, json, yaml, docker, sql**.
- Extras registered via **spec files under `lua/plugins/`**.

---

## Current State (research)

| File | State |
|---|---|
| `lua/plugins/colorscheme.lua` | disables tokyonight, sets `colorscheme = "default"` |
| `lua/config/options.lua` | `showtabline=0`, `termguicolors=false` |
| `lua/config/autocmds.lua` | `ColorScheme` autocmd that strips **all** bg/ctermbg (transparency hack) |
| `lua/config/keymaps.lua` | `uy` yank→`"+`, `<leader>p` paste from `"+` |
| `lua/plugins/disable-bufferline.lua` | disables bufferline (tabs) |
| `lua/plugins/dashboard.lua` | chafa samurai dashboard |
| `lua/plugins/mini-surrond.lua` | mini-surround extra import |
| `lazyvim.json` | `extras: []` |

Environment verified: nvim 0.12.5, LazyVim main. `node 26`, `php 8.5`, `python3`, `go`+`gopls`, `cargo`+`rust-analyzer`, `composer`, `npm`, `rg`, `chafa`, `tectonic`, `zathura` present. Missing (mason will install): pyright, texlab, tinymist. No `latexmk`/`pdflatex`. GitHub reachable.

---

## Implementation

### Phase 1 — Theme: Rosé Pine

**`lua/plugins/colorscheme.lua`** (rewrite):
```lua
return {
  -- Rosé Pine (https://github.com/rose-pine/neovim)
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000,
    opts = {
      variant = "auto",        -- follows vim.o.background; main | moon | dawn
      dark_variant = "main",
      dim_inactive_windows = false,
      extend = {},
    },
  },

  -- make Rosé Pine the LazyVim colorscheme
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "rose-pine" },
  },

  -- stop loading the bundled colorschemes
  { "folke/tokyonight.nvim", enabled = false },
  { "catppuccin/nvim", name = "catppuccin", enabled = false },
}
```

**`lua/config/autocmds.lua`** — delete the entire `strip_backgrounds` function, the `transparent_bg` augroup/autocmd, and the `strip_backgrounds()` / `vim.defer_fn(...)` calls. Leave the stock LazyVim comment stub with a one-line note that backgrounds are intentionally *not* stripped (Rosé Pine owns them).

**`lua/config/options.lua`** (rewrite):
```lua
-- Rosé Pine requires true color
vim.opt.termguicolors = true

-- no tabs / top buffer bar (bufferline stays disabled)
vim.opt.showtabline = 0

-- LSP choices
vim.g.lazyvim_php_lsp = "phpactor"  -- or "intelephense"
vim.g.lazyvim_ts_lsp = "vtsls"

-- LaTeX: only `tectonic` is installed (no latexmk / pdflatex)
vim.g.vimtex_compiler_method = "tectonic"
```

### Phase 2 — Language & tooling extras

**`lua/plugins/extras.lua`** (new) — single import hub:
```lua
-- LazyVim extras as version-controlled import specs.
-- https://www.lazyvim.org/extras
return {
  -- languages
  { import = "lazyvim.plugins.extras.lang.php" },
  { import = "lazyvim.plugins.extras.lang.typescript" }, -- JS / Node / React / TS
  { import = "lazyvim.plugins.extras.lang.vue" },        -- pulls typescript itself
  { import = "lazyvim.plugins.extras.lang.python" },     -- pyright + ruff
  { import = "lazyvim.plugins.extras.lang.go" },         -- gopls
  { import = "lazyvim.plugins.extras.lang.rust" },       -- rustaceanvim

  -- documents
  { import = "lazyvim.plugins.extras.lang.tex" },        -- vimtex + texlab
  { import = "lazyvim.plugins.extras.lang.typst" },      -- tinymist + preview
  { import = "lazyvim.plugins.extras.lang.markdown" },   -- marksman + preview

  -- supporting languages / tools
  { import = "lazyvim.plugins.extras.lang.tailwind" },
  { import = "lazyvim.plugins.extras.lang.json" },
  { import = "lazyvim.plugins.extras.lang.yaml" },
  { import = "lazyvim.plugins.extras.lang.docker" },
  { import = "lazyvim.plugins.extras.lang.sql" },

  -- formatting / linting
  { import = "lazyvim.plugins.extras.formatting.prettier" },
  { import = "lazyvim.plugins.extras.linting.eslint" },

  -- debug + tests for every language above
  { import = "lazyvim.plugins.extras.dap.core" },
  { import = "lazyvim.plugins.extras.test.core" },
}
```

> Note: `lang.vue` imports `lang.typescript` itself; duplicate imports are deduped by lazy.nvim.

### Phase 3 — Laravel + Blade

**`lua/plugins/laravel.lua`** (new):
```lua
return {
  -- Blade tree-sitter highlighting (*.blade.php is auto-detected as ft=blade)
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "blade" } },
  },

  -- Laravel: artisan / routes / tinker / make pickers, completion, gf, code actions
  {
    "adalessa/laravel.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-neotest/nvim-nio",
    },
    ft = { "php", "blade" },
    event = { "BufRead composer.json" },
    -- NOTE: use <leader>L (capital) to avoid LazyVim's <leader>l = Lazy
    keys = {
      { "<leader>Ll", function() Laravel.pickers.laravel() end,   desc = "Laravel: Picker" },
      { "<leader>La", function() Laravel.pickers.artisan() end,   desc = "Laravel: Artisan" },
      { "<leader>Lr", function() Laravel.pickers.routes() end,    desc = "Laravel: Routes" },
      { "<leader>Lm", function() Laravel.pickers.make() end,      desc = "Laravel: Make" },
      { "<leader>Lc", function() Laravel.pickers.commands() end,  desc = "Laravel: Commands" },
      { "<leader>Lo", function() Laravel.pickers.resources() end, desc = "Laravel: Resources" },
      { "<leader>Lu", function() Laravel.commands.run("hub") end, desc = "Laravel: Artisan Hub" },
      { "<leader>Lt", function() Laravel.commands.run("actions") end, desc = "Laravel: Code Actions" },
      { "<leader>Lh", function() Laravel.run("artisan docs") end, desc = "Laravel: Docs" },
    },
    opts = {
      features = { pickers = { provider = "snacks" } }, -- LazyVim ships snacks.picker
    },
  },
}
```

### Phase 4 — Markdown tasks & preview

**`lua/plugins/markdown.lua`** (new) — re-enables checkbox rendering that the `lang.markdown` extra disables, so `- [ ]` / `- [x]` render as real tasks:
```lua
return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      checkbox = {
        enabled = true, -- LazyVim's markdown extra sets this to false
      },
    },
  },
}
```
(Loads after `extras.lua` alphabetically, so it wins the opts merge.) Preview itself comes from the extra: `<leader>cp` toggles `markdown-preview.nvim` in the browser for markdown files.

### Phase 5 — LaTeX / Typst niceties

- LaTeX: handled by `vim.g.vimtex_compiler_method = "tectonic"` (Phase 1) + `zathura` auto-detected as viewer. No extra file required.
- Typst: `lang.typst` already wires tinymist, `typst-preview.nvim` (`<leader>cp` on typst buffers), typstyle via LSP (`lsp_format = "prefer"`, so missing `typstyle` binary is harmless). No extra file required.

### Phase 6 — Install & verify

1. Install plugins / regenerate lockfile:
   ```bash
   nvim --headless "+Lazy! sync" +qa
   ```
2. Install LSPs/linters/formatters and treesitter parsers (first normal launch triggers `mason` `ensure_installed` and `nvim-treesitter` installs):
   ```bash
   nvim --headless "+q"        # boot once so mason/treesitter install kick off
   ```
   Then verify in-editor:
   - `:Lazy` → all green, `rose-pine` present
   - `:Mason` → phpactor, vtsls, vue-language-server, pyright, ruff, gopls, rust-analyzer, texlab, tinymist, marksman, prettier, eslint-lsp, etc.
   - `:checkhealth vim.lsp`, `:checkhealth vim.treesitter`, `:checkhealth vimtex`
3. Update `lazy-lock.json` (auto-written by `Lazy sync`) and commit.

---

## Risks & Open Questions

- **Old transparency autocmd** must be fully removed or it will blank out Rosé Pine's backgrounds. This is the single highest-risk item — Phase 1 handles it explicitly.
- **`<leader>l` conflict**: LazyVim maps `<leader>l` to `:Lazy`. Laravel README uses `<leader>l*`; plan uses `<leader>L*` instead. Adjust if the user prefers the README keys and accepts the overlap.
- **`<leader>cp`** is used by both markdown-preview and typst-preview, but each is `ft`-scoped — no real collision.
- **Network dependency**: plugin + mason + treesitter installs need GitHub/registry access (verified available).
- **`tectonic` vs full TeX Live**: only tectonic is installed; complex documents needing `latexmk`/`biber`/external packages may require installing TeX Live later. `vimtex` viewer defaults to zathura (present).
- **Typst binary**: no standalone `typst` CLI; `tinymist` (mason) provides compilation for both LSP and preview.
- **`laravel.nvim`** writes a generated PHP file into `vendor/` — the project's `vendor/` must be writable for full introspection.
- **PHP `intelephense` alternative**: switch later by setting `vim.g.lazyvim_php_lsp = "intelephense"` in `options.lua`.
- **Rust**: extra errors if `rust-analyzer` is absent — it is present at `/usr/bin/rust-analyzer`.
- **Markdown opts merge order** relies on `markdown.lua` sorting after `extras.lua`; if it ever regresses, inline the override into the markdown extra import file.

## Acceptance Criteria

- [ ] Neovim launches with **Rosé Pine** (correct palette, opaque background) and `termguicolors=true`; no leftover background-stripping.
- [ ] `:Lazy` shows `rose-pine/neovim` installed; `lazy-lock.json` updated.
- [ ] PHP files: phpactor LSP attaches; Laravel projects get artisan/routes pickers; `.blade.php` has Blade treesitter highlighting.
- [ ] JS/Node/React/TS: vtsls attaches in `package.json`/`tsconfig.json` projects; eslint + prettier run.
- [ ] Vue: `vue_ls` + vtsls attach on `.vue`; tailwind LSP where config present.
- [ ] Python: pyright + ruff attach; Go: gopls; Rust: rust-analyzer.
- [ ] LaTeX: vimtex compiles with tectonic, zathura preview; texlab LSP attaches.
- [ ] Typst: tinymist LSP attaches; `<leader>cp` opens live preview.
- [ ] Markdown: `<leader>cp` opens browser preview; `- [ ]` / `- [x]` render as tasks; markdownlint + prettier available.
- [ ] DAP and neotest available (`<leader>d`, `<leader>t`) for supported languages.
- [ ] No startup errors; `:checkhealth LazyVim` is clean.
