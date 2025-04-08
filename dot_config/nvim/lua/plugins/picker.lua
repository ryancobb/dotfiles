return {
  "folke/snacks.nvim",
  keys = {
    {
      "<leader>st",
      function()
        Snacks.picker.grep()
      end,
      desc = "grep",
    },
    {
      "<leader>sr",
      function()
        Snacks.picker.resume()
      end,
      desc = "resume",
    },
    -- {
    --   "<leader>fa",
    --   function()
    --     local file_name_no_ext, _ = vim.fn.expand("%:t:r"):gsub("_spec", "")
    --     local relative_path, _ = vim.fn.fnamemodify(vim.fn.expand("%"), ":~:.")
    --
    --     Snacks.picker.files({ args = { file_name_no_ext }, exclude = { relative_path } })
    --   end,
    --   desc = "alternate",
    -- },
    {
      "<leader>fr",
      function()
        Snacks.picker.recent({ filter = { cwd = true } })
      end,
      desc = "Recent (cwd)",
    },
  },
}
