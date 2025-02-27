return {
  "folke/snacks.nvim",
  keys = {
    {
      "<leader>fa",
      function()
        local file_name_no_ext, _ = vim.fn.expand("%:t:r"):gsub("_spec", "")
        local relative_path, _ = vim.fn.fnamemodify(vim.fn.expand("%"), ":~:.")

        Snacks.picker.files({ args = { file_name_no_ext }, exclude = { relative_path } })
      end,
      desc = "alternate",
    },
    {
      "<leader>fr",
      function()
        Snacks.picker.recent({ filter = { cwd = true } })
      end,
      desc = "Recent (cwd)",
    },
    { "<leader>fR", LazyVim.pick("oldfiles"), desc = "Recent" },
  },
  opts = {
    dashboard = { enabled = false },
    picker = {
      matcher = {
        frecency = true,
      },
      formatters = {
        file = {
          truncate = 80,
        },
      },
      previewers = {
        git = {
          native = true,
        },
      },
      layout = {
        layout = {
          width = 0.9,
          height = 0.9,
        },
      },
    },
  },
}
