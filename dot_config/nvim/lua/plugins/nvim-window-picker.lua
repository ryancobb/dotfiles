return {
  {
    "s1n7ax/nvim-window-picker",
    name = "window-picker",
    event = "VeryLazy",
    opts = {
      hint = "floating-big-letter",
      filter_func = function(windows, rules)
        local function predicate(wid)
          cfg = vim.api.nvim_win_get_config(wid)
          if not cfg.focusable then
            return false
          end
          return true
        end
        local filtered = vim.tbl_filter(predicate, windows)

        local dfilter = require("window-picker.filters.default-window-filter"):new()
        dfilter:set_config(rules)
        return dfilter:filter_windows(filtered)
      end,
      filter_rules = {
        include_current_win = true,
        autoselect_one = true,
        bo = {
          filetype = { "neo-tree", "notify" },
        },
      },
    },
  },
}
