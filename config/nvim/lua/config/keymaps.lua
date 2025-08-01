-- ╭──────────────────────────────────────────────────────╮
-- │                Keymap Helper Setup                   │
-- ╰──────────────────────────────────────────────────────╯

-- General mapping helper
local function map(mode, lhs, rhs, opts)
    opts = vim.tbl_extend("force", { noremap = true, silent = true }, opts or {})
    vim.keymap.set(mode, lhs, rhs, opts)
end

-- Create mode-specific keymappers
local function create_mapper(mode)
    return function(lhs, rhs, opts)
        map(mode, lhs, rhs, opts)
    end
end

-- Mapping helpers
local nnoremap = create_mapper("n") -- normal
local inoremap = create_mapper("i") -- insert
local vnoremap = create_mapper("v") -- visual
local xnoremap = create_mapper("x") -- visual select/operator

-- ╭──────────────────────────────╮
-- │        Normal Mode           │
-- ╰──────────────────────────────╯

nnoremap("<space>", "<nop>")         -- Disable space (used as leader key)
nnoremap("<leader>'", "<C-^>")       -- Switch to last buffer
nnoremap("<leader>w", "<cmd>w<cr>")  -- Save file
nnoremap("<leader>q", "<cmd>q<cr>")  -- Quit current buffer
nnoremap("<leader>z", "<cmd>wq<cr>") -- Save and quit
nnoremap("<leader>f", ":Format<cr>") -- Format buffer
nnoremap("L", "$")                   -- Move to end of line
nnoremap("H", "^")                   -- Move to start of line
nnoremap("q:", ":q")                 -- Prevent opening command-line window accidentally
nnoremap("<A-j>", ":move .+1<CR>==") -- Move current line down
nnoremap("<A-k>", ":move .-2<CR>==") -- Move current line up

-- Toggle file explorer
vim.keymap.set("n", "<leader>e", function()
    local buf_ft = vim.bo.filetype
    if buf_ft == "netrw" then
        vim.cmd("bd") -- close netrw
    else
        vim.cmd("Ex") -- open netrw
    end
end, { desc = "Toggle netrw file explorer" })

-- ╭──────────────────────────────╮
-- │        Insert Mode           │
-- ╰──────────────────────────────╯

inoremap("jj", "<esc>")                     -- Quick exit insert mode with 'jj'
inoremap("kk", "<esc>")                     -- Quick exit insert mode with 'kk'
inoremap("<A-j>", "<Esc>:move .+1<CR>==gi") -- Move line down in insert mode
inoremap("<A-k>", "<Esc>:move .-2<CR>==gi") -- Move line up in insert mode

-- ╭──────────────────────────────╮
-- │        Visual Mode           │
-- ╰──────────────────────────────╯

vnoremap("<space>", "<nop>")             -- Disable space
vnoremap("L", "$")                       -- Move to end of selection
vnoremap("H", "^")                       -- Move to start of selection
vnoremap("<", "<gv")                     -- Indent left and reselect
vnoremap(">", ">gv")                     -- Indent right and reselect
vnoremap("y", "myy`y")                   -- Yank and return to original position
vnoremap("p", '"_dP')                    -- Paste without overwriting register
vnoremap("<A-j>", ":move '>+1<CR>gv=gv") -- Move block down
vnoremap("<A-k>", ":move '<-2<CR>gv=gv") -- Move block up

-- ╭──────────────────────────────╮
-- │     Visual/X Mode Common     │
-- ╰──────────────────────────────╯

xnoremap("<<", function() -- Indent left and reselect (xmode)
    vim.cmd("normal! <<")
    vim.cmd("normal! gv")
end)

xnoremap(">>", function() -- Indent right and reselect (xmode)
    vim.cmd("normal! >>")
    vim.cmd("normal! gv")
end)

-- ╭──────────────────────────────╮
-- │         Harpoon Bindings     │
-- ╰──────────────────────────────╯

local harpoon_ui = require("harpoon.ui")
local harpoon_mark = require("harpoon.mark")

nnoremap("<leader>ho", harpoon_ui.toggle_quick_menu) -- Open Harpoon UI
nnoremap("<leader>ha", harpoon_mark.add_file)        -- Add current file to Harpoon
nnoremap("<leader>hr", harpoon_mark.rm_file)         -- Remove current file from Harpoon
nnoremap("<leader>hc", harpoon_mark.clear_all)       -- Clear all Harpoon entries

-- Quickly jump to Harpoon files 1–5
for i = 1, 5 do
    nnoremap("<leader>" .. i, function() harpoon_ui.nav_file(i) end)
end

-- ╭──────────────────────────────╮
-- │       Find & Replace         │
-- ╰──────────────────────────────╯

-- Build substitute command with escaped content
local function build_substitute_command(range, search)
    local escaped = vim.fn.escape(search, "\\/.*$^~[]")
    escaped = escaped:gsub("\n", "\\n")
    return string.format("%ss/%s//gI", range, escaped)
end

-- Feed substitute command into cmdline with cursor placed in replacement field
local function execute_substitute_cmd(cmd)
    local keys = vim.api.nvim_replace_termcodes(":" .. cmd .. "<Left><Left><Left>", true, false, true)
    vim.api.nvim_feedkeys(keys, "n", false)
end

nnoremap("S", function() -- Replace word under cursor globally
    local word = vim.fn.expand("<cword>")
    execute_substitute_cmd(build_substitute_command("%", word))
end)

vnoremap("S", function() -- Replace selected text in visual mode
    local reg_save = vim.fn.getreg('"')
    vim.cmd('normal! "vy')
    local selection = vim.fn.getreg('"')
    vim.fn.setreg('"', reg_save)
    execute_substitute_cmd(build_substitute_command("%", selection))
end)

nnoremap("<leader>no", "<cmd>noh<cr>") -- Clear search highlights

-- ╭──────────────────────────────╮
-- │           Spectre            │
-- ╰──────────────────────────────╯

nnoremap("<leader>S", function() require("spectre").toggle() end)                             -- Toggle Spectre UI
nnoremap("<leader>sw", function() require("spectre").open_visual({ select_word = true }) end) -- Search word with Spectre

-- ╭──────────────────────────────╮
-- │           Telescope          │
-- ╰──────────────────────────────╯

local tb = require("telescope.builtin")
local theme_dropdown = require("telescope.themes").get_dropdown({ previewer = false })

nnoremap("<leader>?", tb.oldfiles, { desc = "[?] Find recently opened files" })                                       -- Find old files
nnoremap("<leader>sb", tb.buffers, { desc = "[S]earch Open [B]uffers" })                                              -- List open buffers
nnoremap("<leader>sf", function() tb.find_files({ hidden = true }) end, { desc = "[S]earch [F]iles" })                -- Find files, including hidden
nnoremap("<leader>sg", tb.live_grep, { desc = "[S]earch by [G]rep" })                                                 -- Live grep
nnoremap("<leader>sh", tb.help_tags, { desc = "[S]earch [H]elp" })                                                    -- Help tags
nnoremap("<leader>sc", function() tb.commands(theme_dropdown) end, { desc = "[S]earch [C]ommands" })                  -- List commands
nnoremap("<leader>/", function() tb.current_buffer_fuzzy_find(theme_dropdown) end,
    { desc = "[/] Fuzzy search in buffer" })                                                                          -- Buffer search
nnoremap("<leader>ss", function() tb.spell_suggest(theme_dropdown) end, { desc = "[S]earch [S]pelling suggestions" }) -- Spell suggestions
