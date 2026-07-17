local M = {}

local icons = {
  ERROR = "",
  WARN = "",
  HINT = "",
  INFO = "",
}

local function diagnostic_override()
  vim.diagnostic.config({
    severity_sort = true,
    status = {
      format = function(counts)
        local items = {}
        for severity, count in pairs(counts) do
          local name = vim.diagnostic.severity[severity]
          local hl = "Diagnostic" .. name:sub(1, 1) .. name:sub(2):lower()
          table.insert(items, ("%%#%s#%s %d"):format(hl, icons[name], count))
        end
        return table.concat(items, " ")
      end,
    },
    virtual_text = {
      severity = vim.diagnostic.severity.ERROR,
      prefix = "",
      format = function(diagnostic)
        local message = icons[vim.diagnostic.severity[diagnostic.severity]]
        if diagnostic.source then
          message = string.format("%s %s", message, diagnostic.source)
        end
        if diagnostic.code then
          message = string.format("%s[%s]", message, diagnostic.code)
        end
        return message .. " "
      end,
    },
    float = {
      source = true,
      border = "single",
      prefix = function(diag)
        local level = vim.diagnostic.severity[diag.severity]
        local prefix = string.format(" %s  ", icons[level])
        return prefix, "Diagnostic" .. level:gsub("^%l", string.upper)
      end,
    },
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = icons["ERROR"],
        [vim.diagnostic.severity.WARN] = icons["WARN"],
        [vim.diagnostic.severity.HINT] = icons["HINT"],
        [vim.diagnostic.severity.INFO] = icons["INFO"],
      },
    },
  })

  -- Show diagnostics in a pop-up window on hover
  _G.LspDiagnosticsPopupHandler = function()
    local current_cursor = vim.api.nvim_win_get_cursor(0)
    local last_popup_cursor = vim.w.lsp_diagnostics_last_cursor or { nil, nil }

    -- Show the popup diagnostics window,
    -- but only once for the current cursor location (unless moved afterwards).
    if
      not (current_cursor[1] == last_popup_cursor[1] and current_cursor[2] == last_popup_cursor[2])
    then
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
  diagnostic_override()
end

return M
