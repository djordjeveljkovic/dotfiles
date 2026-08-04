return {
  -- Alpine.js completion snippets for blink.cmp (which uses the LuaSnip API
  -- via blink.compat). The HTML LSP already supplies attribute-name completions
  -- for x-data / x-show / x-on / x-model / x-bind etc., so these snippets focus
  -- on the *expansion shape* (the `="..."` part, <template> blocks, etc.).
  --
  -- We hook on the `User VeryLazy` pattern (emitted by LazyVim once everything
  -- is loaded) so blink.compat is guaranteed to be available.
  {
    "saghen/blink.cmp",
    opts = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        group = vim.api.nvim_create_augroup("alpine_js_snippets", { clear = true }),
        callback = function()
          local ok, luasnip = pcall(require, "luasnip")
          if not ok then
            return
          end

          local s = luasnip.snippet
          local t = luasnip.text_node
          local i = luasnip.insert_node

          local alpine = {
            s("xdata", { t('x-data="{ '), i(1, "state"), t(' }"') }, { desc = "Alpine: x-data" }),
            s("xshow", { t('x-show="'), i(1, "condition"), t('"') }, { desc = "Alpine: x-show" }),
            s("xhide", { t('x-show="!'), i(1, "condition"), t('"') }, { desc = "Alpine: x-show false" }),
            s("xif", {
              t('<template x-if="'), i(1, "condition"), t('">'),
              t({ "", "  " }), i(0),
              t({ "", "</template>" }),
            }, { desc = "Alpine: x-if template" }),
            s("xfor", {
              t('<template x-for="'), i(1, "item"), t(' in '), i(2, "items"), t('">'),
              t({ "", "  " }), i(0),
              t({ "", "</template>" }),
            }, { desc = "Alpine: x-for template" }),
            s("xmodel", { t('x-model="'), i(1, "property"), t('"') }, { desc = "Alpine: x-model" }),
            s("xtext", { t('x-text="'), i(1, "expression"), t('"') }, { desc = "Alpine: x-text" }),
            s("xhtml", { t('x-html="'), i(1, "expression"), t('"') }, { desc = "Alpine: x-html" }),
            s("xinit", { t('x-init="'), i(1, "expression"), t('"') }, { desc = "Alpine: x-init" }),
            s("xon", { t('x-on:'), i(1, "event"), t('="'), i(2, "handler"), t('"') }, { desc = "Alpine: x-on" }),
            s("xbind", { t('x-bind:'), i(1, "attr"), t('="'), i(2, "expression"), t('"') }, { desc = "Alpine: x-bind" }),
            s("xcloak", { t("x-cloak") }, { desc = "Alpine: x-cloak" }),
          }

          for _, ft in ipairs({ "html", "blade", "php" }) do
            luasnip.add_snippets(ft, alpine, { key = "alpine_js" })
          end
        end,
      })
    end,
  },
}
