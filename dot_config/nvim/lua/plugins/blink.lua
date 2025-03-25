return {
  "saghen/blink.cmp",
  opts = {
    keymap = {
      ["<right>"] = { "accept", "fallback" },
    },
    completion = {
      documentation = { window = { border = "single" } },
      list = {
        selection = {
          preselect = true,
        },
      },
    },
  },
}
