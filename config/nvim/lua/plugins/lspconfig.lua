-- nvim-lspconfig's `require('lspconfig').setup()` framework was removed in
-- recent versions of the plugin (the module is now a metatable stub that
-- delegates to vim.lsp.config). We use vim.lsp.enable() in lua/config/lsp.lua,
-- so we don't need the framework at all. Disable it to stop lazy.nvim from
-- invoking the (now-broken) `require('lspconfig').setup(opts)` call.
return {
    { "neovim/nvim-lspconfig", enabled = false },
}