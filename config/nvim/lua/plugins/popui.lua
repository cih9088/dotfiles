local M = {}

function M.setup()
   vim.ui.select = require("popui.ui-overrider")
   vim.ui.input = require("popui.input-overrider")
end

return M
