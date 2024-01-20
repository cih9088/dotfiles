local M = {}

function M.setup()
   require("ibl").setup({
      exclude = { filetypes = { 'help', 'checkhealth', 'startify' } },
      scope = { show_start = false, show_end = false },
   })
end

return M
