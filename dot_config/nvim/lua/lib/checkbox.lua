-- Set/toggle markdown todo checkbox states on the current line or visual
-- selection. The state lives on disk as the single char between the brackets:
--   [ ] unchecked   [x] done   [-] in progress   [>] deferred
-- markview (see lua/plugins/markview.lua) renders each as a glyph. These keys
-- only edit lines that are already checkboxes; they never create a todo.
local M = {}

-- Swap the checkbox marker on `lnum` to `state`. No-op when the line is not
-- already a `- [ ]`-style checkbox.
local function set_line(lnum, state)
  local line = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1]
  if not line then
    return
  end

  local prefix, _, suffix = line:match("^(%s*[%-%*%+]%s+%[)(.?)(%].*)$")
  if not prefix then
    return
  end

  vim.api.nvim_buf_set_lines(0, lnum - 1, lnum, false, { prefix .. state .. suffix })
end

-- Set every line in the current normal/visual range to `state`.
function M.set(state)
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\22" then
    local s, e = vim.fn.line("v"), vim.fn.line(".")
    if s > e then
      s, e = e, s
    end
    for lnum = s, e do
      set_line(lnum, state)
    end
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
  else
    set_line(vim.fn.line("."), state)
  end
end

-- Flip the current line between done (`[x]`) and unchecked (`[ ]`). No-op when
-- the line is not already a checkbox.
function M.toggle()
  local lnum = vim.fn.line(".")
  local line = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1] or ""
  local marker = line:match("^%s*[%-%*%+]%s+%[(.?)%]")
  if not marker then
    return
  end
  set_line(lnum, (marker == "x" or marker == "X") and " " or "x")
end

return M
