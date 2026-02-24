local M = {}

local utils = require("utils")

function M.setup()
  local wk = utils.safe_require("which-key")
  if wk then
    wk.setup({})
  end
end

return M
