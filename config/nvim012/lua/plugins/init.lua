-- ============================================================================
-- PLUGINS (vim.pack declarations + packadd)
-- ============================================================================
vim.pack.add({
  "https://github.com/folke/tokyonight.nvim.git",
	"https://www.github.com/lewis6991/gitsigns.nvim",
	"https://www.github.com/echasnovski/mini.nvim",
	"https://www.github.com/ibhagwan/fzf-lua",
	"https://www.github.com/nvim-tree/nvim-tree.lua",
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
	},
	-- Language Server Protocols
	"https://www.github.com/neovim/nvim-lspconfig",
	"https://github.com/mason-org/mason.nvim",
	"https://github.com/creativenull/efmls-configs-nvim",
	{
		src = "https://github.com/saghen/blink.cmp",
		version = vim.version.range("1.*"),
	},
	"https://github.com/L3MON4D3/LuaSnip",
	"https://github.com/rafamadriz/friendly-snippets",
})

local function packadd(name)
	vim.cmd("packadd " .. name)
end

packadd("nvim-treesitter")
packadd("gitsigns.nvim")
packadd("mini.nvim")
packadd("fzf-lua")
packadd("nvim-tree.lua")
packadd("nvim-lspconfig")
packadd("mason.nvim")
packadd("efmls-configs-nvim")
packadd("blink.cmp")
packadd("LuaSnip")
packadd("friendly-snippets")

local status, _ = pcall(vim.cmd, 'packadd tokyonight.nvim')
if status then
    vim.cmd('colorscheme tokyonight')
else
    print("Tokyonight not found, using default theme.")
end

-- Load plugin configs
require("plugins.treesitter")
require("plugins.nvimtree")
require("plugins.fzf")
require("plugins.mini")
require("plugins.gitsigns")
require("plugins.lsp")
require("plugins.completion")
