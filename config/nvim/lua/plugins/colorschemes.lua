return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "macchiato",
        transparent_background = true,
        no_bold = true,
        no_italic = true,
        no_underline = true,
        integrations = {
          gitsigns = true,
          native_lsp = { enabled = true, inlay_hints = { background = true } },
          treesitter = true,
          treesitter_context = true,
          which_key = true,
          fidget = true,
          mason = true,
          neotest = true,
          dap_ui = true,
        },
      })
    end,
  },

  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = true,
    config = function()
      require("rose-pine").setup({
        variant = "moon", -- options: "main", "moon", "dawn"
        dark_variant = "moon",
        disable_background = true,
        disable_float_background = true,
        bold_vert_split = false,
        styles = {
          bold = false,
          italic = false,
          transparency = true,
        },
      })
    end,
  },

  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = {
      style = "night", -- options: "storm", "moon", "night", "day"
      transparent = true,
      terminal_colors = true,
      styles = {
        comments = { italic = false },
        keywords = { italic = false },
        functions = {},
        variables = {},
      },
    },
  },
}
