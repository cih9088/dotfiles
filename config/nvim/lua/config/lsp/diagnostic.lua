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
      -- virtual_lines = {
      --    -- Only show virtual line diagnostics for the current cursor line
      --    current_line = true,
      --    format = function(diagnostic)
      --       return ('%s: %s [%s]'):format(diagnostic.source, diagnostic.message, diagnostic.code)
      --    end,
      -- },
      severity_sort = true,
      virtual_text = {
         severity = vim.diagnostic.severity.ERROR,
      },
      float = {
         source = true,
         focusable = false, -- See neovim#16425
         border = "single",
      },
   })

   -- Show diagnostics in a pop-up window on hover
   _G.LspDiagnosticsPopupHandler = function()
      local current_cursor = vim.api.nvim_win_get_cursor(0)
      local last_popup_cursor = vim.w.lsp_diagnostics_last_cursor or { nil, nil }

      -- Show the popup diagnostics window,
      -- but only once for the current cursor location (unless moved afterwards).
      if not (current_cursor[1] == last_popup_cursor[1] and current_cursor[2] == last_popup_cursor[2]) then
         vim.w.lsp_diagnostics_last_cursor = current_cursor
         local _, winnr = vim.diagnostic.open_float({ bufnr = 0, scope = "cursor" })
         if winnr ~= nil then
            -- opacity for diagnostics
            vim.wo[winnr].winblend = 0
         end
      end
   end
   vim.cmd([[
      augroup LSPDiagnosticsOnHover
         autocmd!
         autocmd CursorHold * lua _G.LspDiagnosticsPopupHandler()
      augroup END
   ]])
end

function M.setup()
   symbols_override()
   diagnostic_override()
end

return M
