-- Cozy cabin: the Quartz claude-code theme (chezmoi quartz/custom.scss) as a
-- nightfox palette. The Ghostty theme dot_config/ghostty/themes/cozycabin.ghostty
-- is the same set, so edit both.
local C = require("nightfox.lib.color")
local Shade = require("nightfox.lib.shade")

-- Nightfox finds a palette only by a name in its `foxes` list, and
-- palette.load falls back to the nightfox palette for an unknown name with no
-- error. So this module registers itself, and every entry point (the colors
-- file, the lualine theme, plugins/colorscheme.lua) requires it first.
local foxes = require("nightfox.palette").foxes
if not vim.tbl_contains(foxes, "cozycabin") then
  table.insert(foxes, "cozycabin")
end

local meta = {
  name = "cozycabin",
  light = false,
}

-- Base and bright are the Quartz --vt-* tokens; a dim of -0.15 is nightfox's
-- own step (carbonfox uses it). The Quartz sel0 sits 3 points off bg1, which
-- no terminal can see, so Visual takes the Quartz sel1, and search and popup
-- selections take an ember-tinted step above it.
-- stylua: ignore
local palette = {
  black   = Shade.new("#37312c", "#625850", "#2b2622"), -- bg3, bg4, bg2
  red     = Shade.new("#c48b80", "#d4a197", -0.15), -- worn flannel
  green   = Shade.new("#a4ab85", "#b8bd9c", -0.15), -- dusty moss
  yellow  = Shade.new("#cdb282", "#dbc59b", -0.15), -- lamp honey
  blue    = Shade.new("#95a3ad", "#aab6bf", -0.15), -- dusk smoke
  magenta = Shade.new("#b09aa6", "#c2aeb8", -0.15), -- heather
  cyan    = Shade.new("#8fa89a", "#a6bbae", -0.15), -- pine
  white   = Shade.new("#dcd0c0", "#ebe1d3", -0.15), -- cream, then --vt-white
  orange  = Shade.new("#cf9c78", "#ddb292", -0.15), -- dim ember (the accent)
  pink    = Shade.new("#c79a9c", 0.15, -0.15),

  comment = "#857a6d",

  bg0     = "#1b1815", -- Dark bg (status line and float)
  bg1     = "#221e1b", -- Default bg: smoked walnut
  bg2     = "#2b2622", -- Lighter bg (colorcolm folds)
  bg3     = "#37312c", -- Lighter bg (cursor line)
  bg4     = "#625850", -- Conceal, border fg

  fg0     = "#e4d9ca", -- Lighter fg (between fg1 and white; Quartz has no fg0)
  fg1     = "#dcd0c0", -- Default fg: cream
  fg2     = "#b5a998", -- Darker fg (status line)
  fg3     = "#8f8476", -- Darker fg (line numbers, fold colums)

  sel0    = "#4d3d33", -- Popup bg, visual selection bg (the Quartz sel1)
  sel1    = "#675041", -- Popup sel bg, search bg
}

local function generate_spec(pal)
  -- stylua: ignore start
  local spec = {
    bg0  = pal.bg0,  -- Dark bg (status line and float)
    bg1  = pal.bg1,  -- Default bg
    bg2  = pal.bg2,  -- Lighter bg (colorcolm folds)
    bg3  = pal.bg3,  -- Lighter bg (cursor line)
    bg4  = pal.bg4,  -- Conceal, border fg

    fg0  = pal.fg0,  -- Lighter fg
    fg1  = pal.fg1,  -- Default fg
    fg2  = pal.fg2,  -- Darker fg (status line)
    fg3  = pal.fg3,  -- Darker fg (line numbers, fold colums)

    sel0 = pal.sel0, -- Popup bg, visual selection bg
    sel1 = pal.sel1, -- Popup sel bg, search bg
  }

  -- The roles follow the Quartz --vt-syn-* tokens, base shades like the site:
  -- keywords ember, strings moss, numbers and constants honey, types heather,
  -- functions dusk, identifiers pine, preprocs pink, variables cream.
  spec.syntax = {
    bracket     = spec.fg2,           -- Brackets and Punctuation
    builtin0    = pal.red.base,       -- Builtin variable
    builtin1    = pal.cyan.bright,    -- Builtin type
    builtin2    = pal.yellow.bright,  -- Builtin const
    builtin3    = pal.red.bright,     -- Not used
    comment     = pal.comment,        -- Comment
    conditional = pal.orange.bright,  -- Conditional and loop
    const       = pal.yellow.bright,  -- Constants, imports and booleans
    dep         = spec.fg3,           -- Deprecated
    field       = pal.blue.base,      -- Field
    func        = pal.blue.base,      -- Functions and Titles
    ident       = pal.cyan.base,      -- Identifiers
    keyword     = pal.orange.base,    -- Keywords
    number      = pal.yellow.base,    -- Numbers
    operator    = spec.fg2,           -- Operators
    preproc     = pal.pink.base,      -- PreProc
    regex       = pal.yellow.bright,  -- Regex
    statement   = pal.orange.base,    -- Statements
    string      = pal.green.base,     -- Strings
    type        = pal.magenta.base,   -- Types
    variable    = pal.white.base,     -- Variables
  }

  spec.diag = {
    error = pal.red.base,
    warn  = pal.yellow.base,
    info  = pal.blue.base,
    hint  = pal.green.base,
    ok    = pal.green.base,
  }

  spec.diag_bg = {
    error = C(spec.bg1):blend(C(spec.diag.error), 0.2):to_css(),
    warn  = C(spec.bg1):blend(C(spec.diag.warn), 0.2):to_css(),
    info  = C(spec.bg1):blend(C(spec.diag.info), 0.2):to_css(),
    hint  = C(spec.bg1):blend(C(spec.diag.hint), 0.2):to_css(),
    ok    = C(spec.bg1):blend(C(spec.diag.ok), 0.2):to_css(),
  }

  spec.diff = {
    add    = C(spec.bg1):blend(C(pal.green.dim), 0.15):to_css(),
    delete = C(spec.bg1):blend(C(pal.red.dim), 0.15):to_css(),
    change = C(spec.bg1):blend(C(pal.blue.dim), 0.15):to_css(),
    text   = C(spec.bg1):blend(C(pal.cyan.dim), 0.25):to_css(),
  }

  spec.git = {
    add      = pal.green.base,
    removed  = pal.red.base,
    changed  = pal.yellow.base,
    conflict = pal.orange.base,
    ignored  = pal.comment,
  }
  -- stylua: ignore end

  return spec
end

return { meta = meta, palette = palette, generate_spec = generate_spec }
