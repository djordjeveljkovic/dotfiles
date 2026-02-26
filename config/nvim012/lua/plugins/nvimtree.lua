-- ============================================================================
-- NVIM-TREE
-- ============================================================================
local api = require("nvim-tree.api")

-- Auto-close tree when opening a file
local function on_attach(bufnr)
	local function opts(desc)
		return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
	end

	-- Apply default mappings first
	api.config.mappings.default_on_attach(bufnr)

	-- Override edit to close tree after opening a file
	vim.keymap.set("n", "<CR>", function()
		api.node.open.edit()
		api.tree.close()
	end, opts("Open and close tree"))

	vim.keymap.set("n", "o", function()
		api.node.open.edit()
		api.tree.close()
	end, opts("Open and close tree"))

	vim.keymap.set("n", "l", function()
		api.node.open.edit()
		api.tree.close()
	end, opts("Open and close tree"))
end

require("nvim-tree").setup({
	on_attach = on_attach,
	view = {
		width = 35,
	},
	filters = {
		dotfiles = false,
	},
	renderer = {
		group_empty = true,
		icons = {
			show = {
				file = true,
				folder = true,
				folder_arrow = true,
				git = true,
			},
		},
	},
})

-- Toggle: if tree is open, close it; otherwise open and reveal current file
vim.keymap.set("n", "<leader>e", function()
	if api.tree.is_visible() then
		api.tree.close()
	else
		api.tree.find_file({ open = true, focus = true })
	end
end, { desc = "Toggle NvimTree (reveal current file)" })

-- Transparent highlights
vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { bg = "none" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeSignColumn", { bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeWinSeparator", { fg = "#2a2a2a", bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { bg = "none" })
