return {
  "folke/snacks.nvim",
  keys = {
    { "<leader>st", function() Snacks.picker.grep() end, desc = "grep" },
    { "<leader>sr", function() Snacks.picker.resume() end, desc = "resume" },
  },
}
