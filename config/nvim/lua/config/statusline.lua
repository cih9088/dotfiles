local fn = vim.fn
local api = vim.api

local utils = require("utils")

local lsp_status = utils.safe_require({ "lsp-status", ignore = true })
if lsp_status ~= nil then
  lsp_status.config({
    current_function = false,
    show_filename = true,
    diagnostics = false,
    status_symbol = "",
  })
  lsp_status.register_progress()
end

local M = {}

-- TODO
vim.cmd([[
  function! StatuslineColor()

    let guibg = synIDattr(synIDtrans(hlID('StatusLine')), 'bg')
    if synIDattr(synIDtrans(hlID('StatusLine')), 'reverse') == 1
       let guibg = synIDattr(synIDtrans(hlID('StatusLine')), 'fg')
    endif

    let git_add_fg = synIDattr(synIDtrans(hlID('GitSignsAdd')), 'fg', 'gui')
    if len(git_add_fg) == 0
      let git_add_fg = synIDattr(synIDtrans(hlID('GitGutterAdd')), 'fg', 'gui')
    end

    let git_change_fg = synIDattr(synIDtrans(hlID('GitSignsChange')), 'fg', 'gui')
    if len(git_change_fg) == 0
      let git_change_fg = synIDattr(synIDtrans(hlID('GitGutterChange')), 'fg', 'gui')
    end

    let git_delete_fg = synIDattr(synIDtrans(hlID('GitSignsDelete')), 'fg', 'gui')
    if len(git_delete_fg) == 0
      let git_delete_fg = synIDattr(synIDtrans(hlID('GitGutterDelete')), 'fg', 'gui')
    end

    exec 'highlight StatusGitSignsAdd' .
        \' guibg=' . guibg .
        \' guifg=' . git_add_fg
    exec 'highlight StatusGitSignsChange' .
        \' guibg=' . guibg .
        \' guifg=' . git_change_fg
    exec 'highlight StatusGitSignsDelete' .
        \' guibg=' . guibg .
        \' guifg=' . git_delete_fg
    exec 'highlight StatusDiagnosticSignError' .
        \' guibg=' . guibg .
        \' guifg=' . synIDattr(synIDtrans(hlID('DiagnosticSignError')), 'fg', 'gui')
    exec 'highlight StatusDiagnosticSignWarn' .
        \' guibg=' . guibg .
        \' guifg=' . synIDattr(synIDtrans(hlID('DiagnosticSignWarn')), 'fg', 'gui')
    exec 'highlight StatusDiagnosticSignHint' .
        \' guibg=' . guibg .
        \' guifg=' . synIDattr(synIDtrans(hlID('DiagnosticSignHint')), 'fg', 'gui')
    exec 'highlight StatusDiagnosticSignInfo' .
        \' guibg=' . guibg .
        \' guifg=' . synIDattr(synIDtrans(hlID('DiagnosticSignInfo')), 'fg', 'gui')
  endfunction

  augroup StatuslineColor
     autocmd!
     autocmd VimEnter,ColorScheme * call StatuslineColor()
  augroup END
]])

M.trunc_width = setmetatable({
  git_branch = 140,
  filepath = 80,
  filetype = 50,
}, {
  __index = function()
    return 100
  end,
})

M.is_truncated = function(_, width)
  local current_width = api.nvim_win_get_width(0)
  return current_width < width
end

M.modes = setmetatable({
  ["n"] = "N",
  ["no"] = "N·P",
  ["v"] = "V",
  ["V"] = "V·L",
  [""] = "V·B", -- this is not ^V, but it's , they're different
  ["s"] = "S",
  ["S"] = "S·L",
  [""] = "S·B", -- same with this one, it's not ^S but it's 
  ["i"] = "I",
  ["ic"] = "I",
  ["R"] = "R",
  ["Rv"] = "V·R",
  ["c"] = "C",
  ["cv"] = "V·E",
  ["ce"] = "E",
  ["r"] = "P",
  ["rm"] = "RM",
  ["r?"] = "C",
  ["!"] = "S",
  ["t"] = "T",
}, {
  __index = function()
    return "U" -- handle edge cases
  end,
})

M.get_current_mode = function(self)
  local current_mode = api.nvim_get_mode().mode
  return string.format("%s", self.modes[current_mode]):upper()
end

M.get_git_status = function(self)
  if self:is_truncated(self.trunc_width.git_status) then
    return ""
  end

  -- use fallback because it doesn't set this variable on the initial `BufEnter`
  local signs = vim.b.gitsigns_status_dict or { head = "", added = 0, changed = 0, removed = 0 }
  local is_head_empty = signs.head ~= ""

  local output = ""
  if is_head_empty then
    output = string.format(" %s", signs.head)
    if self:is_truncated(self.trunc_width.git_branch) then
      return output
    end

    local added = string.format("%s", signs.added)
    local changed = string.format("%s", signs.changed)
    local removed = string.format("%s", signs.removed)

    if added ~= "0" and added ~= "nil" then
      output = output .. " %#StatusGitSignsAdd#" .. string.format(" %s", added) .. "%0*"
    end
    if changed ~= "0" and changed ~= "nil" then
      output = output .. " %#StatusGitSignsChange#" .. string.format(" %s", changed) .. "%0*"
    end
    if removed ~= "0" and removed ~= "nil" then
      output = output .. " %#StatusGitSignsDelete#" .. string.format(" %s", removed) .. "%0*"
    end
  end

  return output
end

M.get_filepath = function(self)
  local filepath = fn.fnamemodify(fn.expand("%"), ":.:h")

  if filepath == "" or filepath == "." or self:is_truncated(self.trunc_width.filepath) then
    return ""
  end

  return string.format("%%<%s/", filepath)
end

M.get_filename = function()
  return fn.expand("%:t")
end

M.get_fileflag = function()
  return "%{&modified ? '🖋️' : !&modifiable ? '🔒' : &readonly ? '👀' : '🌸'}"
end

M.get_filetype = function(self)
  if self:is_truncated(self.trunc_width.filetype) then
    return ""
  end

  local icon
  local filetype = vim.bo.filetype

  if package.loaded["nvim-web-devicons"] ~= nil then
    icon = require("nvim-web-devicons").get_icon_by_filetype(filetype)
  elseif vim.fn.exists("*WebDevIconsGetFileTypeSymbol") == 1 then
    icon = vim.fn.WebDevIconsGetFileTypeSymbol()
  end

  if icon then
    filetype = icon
  end

  return string.format("%s", filetype):upper()
end

M.get_fileformat = function(self)
  if self:is_truncated(self.trunc_width.fileformat) then
    return ""
  end

  local icon
  local fileformat = vim.o.fileformat

  if vim.fn.exists("*WebDevIconsGetFileFormatSymbol") == 1 then
    icon = vim.fn.WebDevIconsGetFileFormatSymbol()
  else
    local format_icons = {
        unix = "",
        dos  = "",
        mac  = "",
      }
    icon = format_icons[fileformat] or ""
  end

  if icon then
    fileformat = icon
  end

  return string.format("%s", fileformat):lower()
end

M.get_encoding = function(self)
  if self:is_truncated(self.trunc_width.encoding) then
    return ""
  end
  return string.format("%s", vim.o.encoding):upper()
end

M.get_meta = function(self)
  local filetype = self:get_filetype()
  local encoding = self:get_encoding()
  local fileformat = self:get_fileformat()

  local components = {}
  if filetype ~= "" then table.insert(components, filetype) end
  if encoding ~= "" then table.insert(components, encoding) end
  if fileformat ~= "" then table.insert(components, fileformat) end

  if #components == 0 then
    return ""
  end

  return string.format("[ %s ]", table.concat(components, " | "))
end

M.get_line_col = function()
  return "%(%l:%c%V%) %4(%p%%%)"
end

M.lsp_status = function(self)
  if self:is_truncated(self.trunc_width.lsp_status) then
    return ""
  end

  local clients = vim.lsp.get_clients()
  if #clients == 0 then
    return ""
  end

  local msg = ""
  -- for _, client in pairs(clients) do
  --    msg = msg .. client.name .. ","
  -- end
  -- msg = string.sub(msg, 1, -2)

  if lsp_status ~= nil then
    msg = msg .. require("lsp-status").status()
  end

  return msg
end

M.diagnostic = function(self)
  if self:is_truncated(self.trunc_width.diagnostic) then
    return ""
  end
  return vim.diagnostic.status()
end

M.set_active = function(self)
  return table.concat({
    -- "▊ ",
    "[%n] ",
    self:get_fileflag(),
    " ",
    -- string.format("[%s] ", self:get_current_mode()),
    self:get_filepath(),
    self:get_filename(),
    " ",
    self:get_git_status(),
    " ",
    "%=",
    " ",
    self:lsp_status(),
    " ",
    self:diagnostic(),
    " ",
    self:get_meta(),
    "%0* ",
    self:get_line_col(),
    -- " ▊",
  })
end

M.set_inactive = function(self)
  return table.concat({
    -- "▊ ",
    "[%n] ",
    self:get_filepath(),
    self:get_filename(),
    -- " ▊",
  })
end

Statusline = setmetatable(M, {
  __call = function(self, mode)
    return self["set_" .. mode](self)
  end,
})

-- set statusline
vim.cmd([[
   augroup Statusline
      autocmd!
      autocmd WinEnter,BufEnter * setlocal statusline=%!v:lua.Statusline('active')
      autocmd WinLeave,BufLeave * setlocal statusline=%!v:lua.Statusline('inactive')
   augroup END
]])
