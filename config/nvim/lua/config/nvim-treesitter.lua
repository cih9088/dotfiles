local M = {}
local ts = require("nvim-treesitter.configs")

function M.setup()
   ts.setup({
      highlight = {
         enable = true,
         use_languagetree = false,
         disable = function(lang, bufnr)
            return lang == "yaml" and vim.bo.filetype == "yaml.ansible"
         end,
      },
   })
end

return M
