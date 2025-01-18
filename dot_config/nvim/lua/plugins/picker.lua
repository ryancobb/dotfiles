return {
  "folke/snacks.nvim",
  keys = {
    { "<leader>st", function() Snacks.picker.grep() end, desc = "Grep" },
  },
}
