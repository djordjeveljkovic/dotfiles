return {
    {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",                                   -- Use a stable branch
        dependencies = {
            "nvim-lua/plenary.nvim",                        -- Required utility library
            {
                "nvim-telescope/telescope-fzf-native.nvim", -- Optional native sorter (faster)
                build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && " ..
                    "cmake --build build --config Release && " ..
                    "cmake --install build --prefix build",
                cond = vim.fn.executable("cmake") == 1, -- Only build if cmake is available
            }
        },
        opts = function()
            local actions = require("telescope.actions")

            return {
                defaults = {
                    file_ignore_patterns = { -- Files/folders to ignore
                        "node_modules",
                        "yarn.lock",
                        ".git",
                        ".sl",
                        "_build",
                        ".next",
                    },
                    hidden = true, -- Show hidden files
                },
            }
        end,
        config = function(_, opts)
            require("telescope").setup(opts)

            -- Attempt to load optional native fzf extension
            pcall(require("telescope").load_extension, "fzf")
        end,
    },
}
