local M = {}

local utils = require("utils")

function M.setup()
   local ts_context = utils.safe_require("treesitter-context")
   if not ts_context then
      return
   end

   ts_context.setup({
      max_lines = 3,
      -- Match the context lines to the source code.
      multiline_threshold = 1,
      -- Disable it when the window is too small.
      min_window_height = 20,

   })
end

return M
