-- ╭────────────────────────────────────────────────────────────────────────────╮
-- │                            BASIC EDITOR OPTIONS                            │
-- ╰────────────────────────────────────────────────────────────────────────────╯

local opt = vim.opt
local g = vim.g

-- opt.laststatus = 0                   -- Hide statusline
g.netrw_banner = 0            -- remove the banner

-- Line numbers
opt.number = true         -- Show absolute line number
opt.relativenumber = true -- Show relative line numbers

-- Indentation
opt.tabstop = 4        -- Width of <Tab> character
opt.shiftwidth = 4     -- Width for autoindents
opt.softtabstop = 4    -- Number of spaces when hitting <Tab>
opt.expandtab = true   -- Use spaces instead of tabs
opt.smartindent = true -- Smart auto-indenting
opt.autoindent = true  -- Copy indent from current line

-- Search behavior
opt.ignorecase = true -- Ignore case in search patterns
opt.smartcase = true  -- Override ignorecase if uppercase used
opt.hlsearch = false  -- Disable persistent search highlight
opt.incsearch = true  -- Show match while typing

-- UI tweaks
opt.termguicolors = true -- Enable 24-bit RGB colors
opt.signcolumn = "yes"   -- Always show sign column
opt.wrap = false         -- Disable line wrap
opt.cursorline = false   -- Disable cursorline highlight
opt.scrolloff = 10       -- Minimum lines above/below cursor
opt.sidescrolloff = 8    -- Minimum columns left/right of cursor
opt.showmatch = true     -- Briefly jump to matching bracket
opt.matchtime = 2        -- Time in 1/10 sec to show match

-- Completion and wildmenu
opt.completeopt = "menuone,noinsert,noselect" -- Completion menu behavior
opt.wildmode = "longest:full,full"            -- Command-line completion
opt.wildmenu = true                           -- Show wildmenu
opt.pumheight = 10                            -- Popup menu height
opt.pumblend = 10                             -- Transparency of popup
opt.winblend = 0                              -- No transparency for floating windows

-- File behavior
opt.undofile = true     -- Persistent undo
opt.backup = false      -- Disable backup file
opt.writebackup = false -- Disable write backup
opt.swapfile = false    -- Disable swap file
opt.updatetime = 200    -- Faster update time
opt.timeoutlen = 500    -- Mapped sequence timeout
opt.ttimeoutlen = 0     -- Key code timeout
opt.autoread = true     -- Reload if changed outside
opt.autowrite = false   -- Don’t auto save on certain events

-- Mouse and clipboard
opt.mouse = "" -- Disable mouse
-- opt.clipboard:append("unnamedplus") -- Use system clipboard

-- Behavior
opt.hidden = true                  -- Allow hidden buffers
opt.errorbells = false             -- Disable error sound
opt.backspace = "indent,eol,start" -- Allow unrestricted backspacing
opt.autochdir = false              -- Don’t auto change cwd
opt.iskeyword:append("-")          -- Treat dashes as part of words
opt.path:append("**")              -- Search recursively
opt.selection = "exclusive"        -- Make selections exclusive
opt.encoding = "utf-8"             -- Set encoding
opt.lazyredraw = false             -- Optimize redrawing
opt.synmaxcol = 300                -- Limit syntax highlighting width

-- Split behavior
opt.splitbelow = true -- Split below current window
opt.splitright = true -- Split right of current window

-- Cursor appearance
opt.guicursor = table.concat({
    "n-v-c:block",
    "i-ci-ve:block",
    "r-cr:hor20",
    "o:hor50",
    "a:blinkon250-blinkoff400-blinkwait700-Cursor/lCursor",
    "sm:block-blinkon175-blinkoff150-blinkwait175"
}, ",")


-- Persistent undo directory
local undodir = vim.fn.expand("~/.vim/undodir")
if vim.fn.isdirectory(undodir) == 0 then
    vim.fn.mkdir(undodir, "p")
end
opt.undodir = undodir

-- Wildignore (file patterns to ignore)
opt.wildignore:append({ "*.o", "*.obj", "*.pyc", "*.class", "*.jar" })

-- Diff options
opt.diffopt:append("linematch:60")

-- ╭────────────────────────────────────────────────────────────────────────────╮
-- │                        FILETYPE-SPECIFIC SETTINGS                          │
-- ╰────────────────────────────────────────────────────────────────────────────╯

local group = vim.api.nvim_create_augroup("FileTypeIndentOverrides", {})

-- 4-space indent for Lua & Python
vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "lua", "python" },
    callback = function()
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
    end,
})

-- 2-space indent for Web languages
vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "javascript", "typescript", "json", "html", "css" },
    callback = function()
        vim.opt_local.tabstop = 2
        vim.opt_local.shiftwidth = 2
    end,
})

-- if a file is a .env or .envrc file, set the filetype to sh
vim.filetype.add({
  filename = {
    [".env"] = "sh",
    [".envrc"] = "sh",
    ["*.env"] = "sh",
    ["*.envrc"] = "sh"
  }
})
-- ╭────────────────────────────────────────────────────────────────────────────╮
-- │                             GENERAL AUTOCMDS                               │
-- ╰────────────────────────────────────────────────────────────────────────────╯

-- Restore cursor position on file reopen
vim.api.nvim_create_autocmd("BufReadPost", {
    group = group,
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- Highlight text on yank
vim.api.nvim_create_autocmd("TextYankPost", {
    group = group,
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Auto resize splits on window resize
vim.api.nvim_create_autocmd("VimResized", {
    group = group,
    callback = function()
        vim.cmd("tabdo wincmd =")
    end,
})

-- Auto create folders on save
vim.api.nvim_create_autocmd("BufWritePre", {
    group = group,
    callback = function()
        local dir = vim.fn.expand('<afile>:p:h')
        if vim.fn.isdirectory(dir) == 0 then
            vim.fn.mkdir(dir, 'p')
        end
    end,
})

vim.api.nvim_create_user_command("Format", function()
    vim.lsp.buf.format({ timeout_ms = 2000 })
end, { desc = "Format current buffer using LSP" })

vim.api.nvim_create_autocmd("FileType", {
    pattern = "netrw",
    callback = function()
        vim.wo.number = true
        vim.wo.relativenumber = true
        vim.wo.cursorline = false
    end,
})
