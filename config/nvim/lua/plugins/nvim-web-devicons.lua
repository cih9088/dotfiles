local M = {}

local utils = require("utils")

function M.setup()
   local devicon = utils.safe_require("nvim-web-devicons")

   if devicon then
      devicon.setup({})
   end
end

return M
