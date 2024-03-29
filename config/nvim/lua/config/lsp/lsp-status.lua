local this = (...):match("(.-)[^%.]+$")
local M = {}

local utils = require("utils")

local function setup_lsp_status()
   local lsp_status = utils.safe_require("lsp-status")

   if lsp_status then
      lsp_status.config({
         kind_labels = require(this .. "kind"),

         current_function = true,
         show_filename = true,
         diagnostics = false,
         status_symbol = "",
      })
      lsp_status.register_progress()
   end
end

function M.setup()
   setup_lsp_status()
end

return M
