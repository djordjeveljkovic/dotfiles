return {
    {
        "nvim-pack/nvim-spectre",
        lazy = true,
        cmd = { "Spectre" },   -- Load only when :Spectre command is used
        dependencies = {
            "nvim-lua/plenary.nvim", -- Required dependency
        },
        opts = function()
            return {
                highlight = {
                    search = "SpectreSearch", -- Highlight group for search results
                    replace = "SpectreReplace", -- Highlight group for replacement text
                },
                mapping = {
                    ["send_to_qf"] = {
                        map = "<C-q>", -- Shortcut to send results to quickfix list
                        cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
                        desc = "Send all items to quickfix",
                    },
                },
            }
        end,
        config = function(_, opts)
            require("spectre").setup(opts) -- Apply Spectre configuration
        end,
    },
}
