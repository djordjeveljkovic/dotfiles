-- Leader key
vim.g.mapleader = " " -- Space as leader
vim.g.maplocalleader = " "

-- Order matters: anything that touches plugins (LSP, keymaps, colorscheme)
-- must run AFTER config.lazy has bootstrapped lazy.nvim and installed plugins.

require("config.mason-path") -- Set Mason bin on PATH before any plugin loads
require("config.lazy") -- Bootstrap lazy.nvim, install + load plugins
require("config.options")
require("config.keymaps")
require("config.terminal")

vim.cmd.colorscheme("catppuccin")

require("config.lsp") -- Needs blink.cmp, snacks, etc. -> loaded by lazy
require("config.transperent")
