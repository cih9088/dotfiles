local M = {}

local utils = require("utils")

function M.setup()
   local ts = utils.safe_require("nvim-treesitter.configs")

   if ts then
      ts.setup({
         highlight = {
            enable = true,
            disable = function(lang, bufnr)
               return lang == "yaml" and vim.bo.filetype == "yaml.ansible"
            end,
         },
      })
   end
end

return M
