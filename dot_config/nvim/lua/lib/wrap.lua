local M = {}

local path = vim.fn.stdpath("data") .. "/wrap_state.json"

function M.read()
  local f = io.open(path, "r")
  if not f then return false end
  local content = f:read("*a")
  f:close()
  local ok, data = pcall(vim.json.decode, content)
  return ok and type(data) == "table" and data.wrap == true
end

function M.write(wrap)
  local f = io.open(path, "w")
  if not f then return end
  f:write(vim.json.encode({ wrap = wrap }))
  f:close()
end

function M.apply(wrap)
  vim.o.wrap = wrap
  vim.o.linebreak = wrap
end

function M.toggle()
  local wrap = not vim.o.wrap
  M.apply(wrap)
  M.write(wrap)
  vim.notify("Wrap " .. (wrap and "on" or "off"))
end

return M
