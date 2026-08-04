-- ╭────────────────────────────────────────────────────────────╮
-- │               Bootstrap & Configure lazy.nvim              │
-- ╰────────────────────────────────────────────────────────────╯

-- Determine the installation path for lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- Clone lazy.nvim if not already installed
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local ok, result = pcall(vim.fn.system, {
        "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath
    })

    -- Handle clone failure gracefully
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

-- Prepend lazy.nvim to runtime path
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim with plugin imports
require("lazy").setup({
    { import = "plugins" }, -- Import all plugins from lua/plugins/
}, {
    change_detection = {
        enabled = true, -- Auto-detect changes to plugin files
        notify = false, -- Don't show notifications for changes
    },
})
