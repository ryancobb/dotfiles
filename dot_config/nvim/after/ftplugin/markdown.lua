-- Buffer-local todo checkbox keymaps for markdown (replaces checkmate.nvim).
-- The helper rewrites the marker on the line/selection; markview renders the
-- glyph. Tests use <leader>T (uppercase), so <leader>t* is free here.
local cb = require("lib.checkbox")

local function map(lhs, rhs, desc, modes)
  vim.keymap.set(modes or { "n", "v" }, lhs, rhs, { buffer = true, silent = true, desc = desc })
end

map("<leader>tt", cb.toggle, "Todo: toggle done", "n")
map("<leader>tu", function()
  cb.set(" ")
end, "Todo: unchecked")
map("<leader>tc", function()
  cb.set("x")
end, "Todo: done")
map("<leader>t-", function()
  cb.set("-")
end, "Todo: in progress")
map("<leader>t>", function()
  cb.set(">")
end, "Todo: deferred")
