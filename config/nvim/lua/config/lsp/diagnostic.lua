local M = {}

local function symbols_override()
   local signs = { Error = "", Warn = " ", Hint = " ", Info = " " }
   -- local signs = { Error = "•", Warn = "•", Hint = "•", Info = "•" }
   for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
   end
end

local function diagnostic_override()
   vim.diagnostic.config({
      virtual_text = {
         severity = vim.diagnostic.severity.ERROR,
      },
      float = {
         severity_sort = true,
         source = "always",
         focusable = false, -- See neovim#16425
         border = "single",
      },
   })
   _G.LspDiagnosticsShowPopup = function()
      return vim.diagnostic.open_float(nil, { scope = "cursor" })
   end

   -- Show diagnostics in a pop-up window on hover
   _G.LspDiagnosticsPopupHandler = function()
      local current_cursor = vim.api.nvim_win_get_cursor(0)
      local last_popup_cursor = vim.w.lsp_diagnostics_last_cursor or { nil, nil }

      -- Show the popup diagnostics window,
      -- but only once for the current cursor location (unless moved afterwards).
      if not (current_cursor[1] == last_popup_cursor[1] and current_cursor[2] == last_popup_cursor[2]) then
         vim.w.lsp_diagnostics_last_cursor = current_cursor
         local _, winnr = _G.LspDiagnosticsShowPopup()
         if winnr ~= nil then
            vim.api.nvim_win_set_option(winnr, "winblend", 20) -- opacity for diagnostics
         end
      end
   end
   vim.cmd([[
      augroup LSPDiagnosticsOnHover
         autocmd!
         autocmd CursorHold *   lua _G.LspDiagnosticsPopupHandler()
      augroup END
   ]])
end

function M.setup()
   symbols_override()
   diagnostic_override()
end

return M
