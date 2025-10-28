return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  opts = {
    default_args = {
      DiffviewOpen = { "--imply-local" },
    },
    enhanced_diff_hl = true,
  },
}
