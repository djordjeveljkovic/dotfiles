-- ╭──────────────────────────────────────────────╮
-- │            Transparent background            │
-- ╰──────────────────────────────────────────────╯

vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })
vim.api.nvim_set_hl(0, "Pmenu", { bg = "none" })
vim.api.nvim_set_hl(0, "Terminal", { bg = "none" })
vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
vim.api.nvim_set_hl(0, "FoldColumn", { bg = "none" })
vim.api.nvim_set_hl(0, "Folded", { bg = "none" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
vim.api.nvim_set_hl(0, "WhichKeyFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = "none" })
vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "none" })
vim.api.nvim_set_hl(0, "TelescopePromptBorder", { bg = "none" })
vim.api.nvim_set_hl(0, "TelescopePromptTitle", { bg = "none" })

vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE", ctermbg = "NONE" })
vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "NONE", ctermbg = "NONE" })

vim.api.nvim_set_hl(0, "PmenuSel", { bg = "NONE", fg = "NONE", blend = 100 }) -- for popup selection

-- Wildmenu transparency (command-line completion)
vim.api.nvim_set_hl(0, "WildMenu", { bg = "NONE", fg = "NONE" })
vim.api.nvim_set_hl(0, "MsgArea", { bg = "NONE" })
vim.api.nvim_set_hl(0, "MsgSeparator", { bg = "NONE" })

-- cmp menu
vim.opt.pumblend = 0
vim.opt.winblend = 0

vim.api.nvim_set_hl(0, "VertSplit", { bg = "NONE", fg = "NONE" })
vim.api.nvim_set_hl(0, "WinSeparator", { bg = "NONE", fg = "NONE" })
vim.api.nvim_set_hl(0, "WinBar", { bg = "NONE", fg = "NONE" })
vim.api.nvim_set_hl(0, "WinBarNC", { bg = "NONE", fg = "NONE" })
vim.opt.fillchars:append({
    vert = " ",
    horiz = " ",
    horizup = " ",
    horizdown = " ",
    vertleft = " ",
    vertright = " ",
    verthoriz = " ",
})

-- ╭──────────────────────────────────────────────╮
-- │         Transparent Notify background        │
-- ╰──────────────────────────────────────────────╯

vim.api.nvim_set_hl(0, "NotifyINFOBody", { bg = "none" })
vim.api.nvim_set_hl(0, "NotifyERRORBody", { bg = "none" })
vim.api.nvim_set_hl(0, "NotifyWARNBody", { bg = "none" })
vim.api.nvim_set_hl(0, "NotifyTRACEBody", { bg = "none" })
vim.api.nvim_set_hl(0, "NotifyDEBUGBody", { bg = "none" })
vim.api.nvim_set_hl(0, "NotifyINFOTitle", { bg = "none" })
vim.api.nvim_set_hl(0, "NotifyERRORTitle", { bg = "none" })
vim.api.nvim_set_hl(0, "NotifyWARNTitle", { bg = "none" })
vim.api.nvim_set_hl(0, "NotifyTRACETitle", { bg = "none" })
vim.api.nvim_set_hl(0, "NotifyDEBUGTitle", { bg = "none" })
vim.api.nvim_set_hl(0, "NotifyINFOBorder", { bg = "none" })
vim.api.nvim_set_hl(0, "NotifyERRORBorder", { bg = "none" })
vim.api.nvim_set_hl(0, "NotifyWARNBorder", { bg = "none" })
vim.api.nvim_set_hl(0, "NotifyTRACEBorder", { bg = "none" })
vim.api.nvim_set_hl(0, "NotifyDEBUGBorder", { bg = "none" })
