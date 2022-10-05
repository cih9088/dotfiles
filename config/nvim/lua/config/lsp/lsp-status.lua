local this = (...):match("(.-)[^%.]+$")
local M = {}

local function setup_lsp_status()
   local lsp_status = require("lsp-status")

   lsp_status.config({
      kind_labels = require(this .. "kind"),

      current_function = true,
      show_filename = true,
      diagnostics = false,
      status_symbol = "",
   })
   lsp_status.register_progress()
end

function M.setup()
   setup_lsp_status()
end

return M
