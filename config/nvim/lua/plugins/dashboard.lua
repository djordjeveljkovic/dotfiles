return {
  -- dashboard: show samurai wallpaper instead of the LazyVim ASCII header,
  -- keep the shortcut menu and startup footer below it
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        sections = {
          {
            section = "terminal",
            cmd = "chafa ~/Pictures/walls/samurai-white.jpg --format symbols --symbols vhalf --size 60x17 --stretch; sleep .1",
            height = 17,
            padding = 1,
          },
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
        },
      },
    },
  },
}
