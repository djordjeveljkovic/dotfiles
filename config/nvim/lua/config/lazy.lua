-- ╭────────────────────────────────────────────────────────────╮
-- │               Bootstrap & Configure lazy.nvim              │
-- ╰────────────────────────────────────────────────────────────╯

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local ok, result = pcall(vim.fn.system, {
        "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath
    })

    if not ok or vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { result or "unknown error",      "WarningMsg" },
            { "\nPress any key to exit...",   "WarningMsg" },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end

vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim with manual plugin import order
require("lazy").setup({
    { import = "plugins.extra" }, -- ✅ Load first
    { import = "plugins" },       -- ✅ Load the rest (e.g., lsp.lua, ui.lua, etc.)
}, {
    change_detection = {
        enabled = true,
        notify = false,
    },
})

