return {
  "chrishrb/gx.nvim",
  keys = {
    { "gx", "<cmd>Browse<cr>", mode = { "n", "x" } },
  },
  opts = {
    handler_options = {
      search_engine = "google",
    },
    handlers = {
      markdown = {
        name = "markdown",
        filetype = { "markdown" },
        filename = nil,
        handle = function(mode, line, _)
          local pattern = "%[.-%]%((.-)%)"
          local url = line:match(pattern)
          if url then
            return url
          end
        end,
      },
    },
  },
}
