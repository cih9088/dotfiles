local M = {}

local utils = require("utils")

function M.setup()
  local ibl = utils.safe_require("ibl")

  if ibl then
    ibl.setup({
      exclude = { filetypes = { "help", "checkhealth", "startify" } },
      scope = { show_start = false, show_end = false },
    })
  end
end

return M
