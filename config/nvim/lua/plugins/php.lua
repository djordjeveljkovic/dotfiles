-- Disable LazyVim's import-order check. We're importing `lazyvim.plugins.extras.lang.php`
-- from inside a user plugin spec, which (legitimately) breaks the strict
-- `lazyvim.plugins` -> `extras` -> `plugins` order LazyVim expects in `lazy.lua`.
-- This must be set before lazy.nvim processes the spec, hence the top-of-file placement.
vim.g.lazyvim_check_order = false

return {
  -- LazyVim PHP extra:
  --   * phpactor LSP (free, no license required)
  --   * phpcs (linter) + php-cs-fixer (formatter)
  --   * PHP treesitter parser
  --   * neotest-pest + neotest-phpunit (test adapters, if you use neotest)
  { import = "lazyvim.plugins.extras.lang.php" },

  -- Make Mason install the Laravel language server alongside the PHP tooling.
  -- Mason's main spec uses `opts_extend = { "ensure_installed" }` so this list
  -- is merged into the global one (you'll still see stylua, shfmt, phpcs, php-cs-fixer, etc.).
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "laravel-ls" })
    end,
  },

  -- Enable the built-in HTML LSP. It ships with Alpine.js attribute completions
  -- (x-data, x-show, x-on, x-model, x-bind, ...) via vscode-html-languageservice.
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        html = { enabled = true },
      },
    },
  },
}
