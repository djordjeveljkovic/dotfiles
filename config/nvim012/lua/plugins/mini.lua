-- ============================================================================
-- MINI.NVIM modules
-- ============================================================================
require("mini.ai").setup({})
require("mini.comment").setup({})
require("mini.move").setup({})
require("mini.surround").setup({})
require("mini.cursorword").setup({})
require("mini.indentscope").setup({})
require("mini.pairs").setup({})
require("mini.trailspace").setup({})
require("mini.bufremove").setup({})
require("mini.notify").setup({})
require("mini.icons").setup({})

-- Provide nvim-web-devicons API via mini.icons (for nvim-tree, fzf-lua, etc.)
MiniIcons.mock_nvim_web_devicons()
