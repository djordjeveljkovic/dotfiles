return {
  -- Autotags
  {
    "windwp/nvim-ts-autotag",
    opts = {},
  },

  -- comments
  {
    "numToStr/Comment.nvim",
    opts = {},
    lazy = false,
  },
  -- useful when there are embedded languages in certain types of files (e.g. Vue or React)
  { "joosepalviste/nvim-ts-context-commentstring", lazy = true },

  -- Neovim notifications and LSP progress messages
  {
    "j-hui/fidget.nvim",
  },

  {
    {
      "folke/lazydev.nvim",
      ft = "lua", -- only load on lua files
      opts = {
        library = {
          -- See the configuration section for more details
          -- Load luvit types when the `vim.uv` word is found
          { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
      },
    },
    -- {
    --   "saghen/blink.cmp",
    --   opts = {
    --     sources = {
    --       -- add lazydev to your completion providers
    --       default = { "lazydev", "lsp", "path", "snippets", "buffer" },
    --       providers = {
    --         lazydev = {
    --           name = "LazyDev",
    --           module = "lazydev.integrations.blink",
    --           -- make lazydev completions top priority (see `:h blink.cmp`)
    --           score_offset = 100,
    --         },
    --       },
    --     },
    --   },
    -- }
  },
}
