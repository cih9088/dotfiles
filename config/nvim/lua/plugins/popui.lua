local M = {}

local utils = require("utils")

function M.setup()
  local popui = utils.safe_require("popui")

  if popui then
    vim.ui.select = popui["ui-overrider"]
    vim.ui.input = popui["input-overrider"]
  end
end

return M
