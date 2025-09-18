-- Leader key
vim.g.mapleader = " " -- Space as leader
vim.g.maplocalleader = " "

require("config.lsp")
require("config.mason-path")
require("config.lazy")
require("config.options")
require("config.keymaps")
require("config.terminal")

vim.cmd.colorscheme("catppuccin")

require("config.transperent")
