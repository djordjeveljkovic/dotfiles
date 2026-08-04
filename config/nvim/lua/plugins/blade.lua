return {
  -- Filetype detection + a robust treesitter fallback for `.blade.php` files.
  --
  -- We do three things:
  --   1. Make sure `.blade.php` is detected as the `blade` filetype.
  --   2. Alias the `blade` language to the installed `html` parser, so any
  --      tool that asks treesitter for the blade parser (nvim-ts-autotag,
  --      LSP semantic tokens, etc.) gets a real working parser back.
  --   3. Explicitly start the parser on the buffer via a FileType autocmd,
  --      as a belt-and-suspenders fallback in case `language.add` alone
  --      isn't enough on a given Neovim build.
  {
    "neovim/nvim-lspconfig",
    init = function()
      vim.filetype.add({
        pattern = {
          [".*%.blade%.php"] = "blade",
        },
      })

      -- Alias `blade` -> `html` parser. Wrapped in pcall so older builds
      -- that don't have this API just skip it.
      pcall(vim.treesitter.language.add, "blade", { path = "html", silent = true })

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("blade_treesitter_fallback", { clear = true }),
        pattern = "blade",
        callback = function(ev)
          -- Prefer the (now-aliased) "blade" parser; fall back to "html"
          -- directly if the alias isn't active.
          if not pcall(vim.treesitter.start, ev.buf, "blade") then
            pcall(vim.treesitter.start, ev.buf, "html")
          end
        end,
      })
    end,
  },

  -- nvim-ts-autotag ships a built-in `blade -> html` alias, so on every
  -- InsertLeave in a blade buffer it tries to rename the matching closing
  -- tag. The internal callback does `pcall(vim.treesitter.get_parser)` —
  -- but pcall only catches *errors*, not a `nil` return — so when the
  -- parser isn't ready (or the buffer hasn't had one started yet) it dies
  -- with `attempt to index local 'parser' (a nil value)`. Auto-close on
  -- `>` and `/` is still useful for Blade, so we just disable the rename
  -- half per-filetype and let the alias keep everything else working.
  {
    "windwp/nvim-ts-autotag",
    opts = function(_, opts)
      opts.per_filetype = opts.per_filetype or {}
      opts.per_filetype.blade = opts.per_filetype.blade or {}
      opts.per_filetype.blade.enable_rename = false
    end,
  },
}
