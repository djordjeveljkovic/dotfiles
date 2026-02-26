-- ============================================================================
-- TREESITTER
-- ============================================================================

require("nvim-treesitter.config").setup({
	auto_install = true,
	ensure_installed = {
		"bash",
		"blade",
		"c",
		"cpp",
		"css",
		"dockerfile",
		"go",
		"gomod",
		"gosum",
		"html",
		"javascript",
		"json",
		"lua",
		"markdown",
		"php",
		"phpdoc",
		"python",
		"regex",
		"rust",
		"scss",
		"sql",
		"svelte",
		"toml",
		"tsx",
		"typescript",
		"typst",
		"vim",
		"vimdoc",
		"vue",
		"yaml",
	},
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
	indent = {
		enable = true,
	},
})
