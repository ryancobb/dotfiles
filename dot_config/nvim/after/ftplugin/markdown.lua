local function get_hl_fg(name)
  local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
  return hl.fg
end

local function get_hl_bg(name)
  local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
  return hl.bg
end

local function setup_tag_highlights()
  local bg = get_hl_bg('StatusLineNC') or '#2a2a3a'

  local colors = {
    issue = get_hl_fg('DiagnosticError'),
    mr = get_hl_fg('DiagnosticInfo'),
    epic = get_hl_fg('Statement'),
    dev = get_hl_fg('DiagnosticWarn'),
    review = get_hl_fg('Number'),
    complete = get_hl_fg('DiagnosticOk'),
  }

  for tag, fg in pairs(colors) do
    local name = 'MarkdownTag' .. tag:gsub('^%l', string.upper)
    vim.api.nvim_set_hl(0, name, { fg = fg, bg = bg, bold = true })
    vim.fn.matchadd(name, '#' .. tag .. '\\>')
  end
end

setup_tag_highlights()

vim.api.nvim_create_autocmd('ColorScheme', {
  callback = setup_tag_highlights,
})
