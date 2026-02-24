local M = {}
local this = ...

function M.setup()
  require(this .. ".sources").setup()
  require(this .. ".mapping").setup()
  require(this .. ".ui").setup()
end

return M
