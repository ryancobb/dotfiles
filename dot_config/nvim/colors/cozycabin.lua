-- Cozy cabin is a nightfox palette that lives in this config
-- (lua/nightfox/palette/cozycabin.lua), so lazy.nvim's colorscheme handler does
-- not know that nightfox provides it: load the plugin by hand first.
require("lazy").load({ plugins = { "nightfox.nvim" } })

-- Useful when debugging, as nightfox's own colors files do
if vim.g.nightfox_debug then
  require("nightfox.util.reload")()
end

require("nightfox.palette.cozycabin") -- registers the fox
require("nightfox.config").set_fox("cozycabin")
require("nightfox").load()
