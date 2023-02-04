local fn = vim.fn
local api = vim.api

local M = {}

M.trunc_width = setmetatable({
   git_status = 100,
   git_branch = 140,
   filename = 140,
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
   -- use fallback because it doesn't set this variable on the initial `BufEnter`
   local signs = vim.b.gitsigns_status_dict or { head = "", added = 0, changed = 0, removed = 0 }
   local is_head_empty = signs.head ~= ""

   if self:is_truncated(self.trunc_width.git_status) then
      return ""
   end

   local output = " "
   if is_head_empty then
      output = output .. string.format(" %s", signs.head)
      if self:is_truncated(self.trunc_width.git_branch) then
         return output
      end

      local added = string.format("%s", signs.added)
      local changed = string.format("%s", signs.changed)
      local removed = string.format("%s", signs.removed)

      if added ~= "0" and added ~= "nil" then
         output = output .. " %#SignAdd#" .. string.format(" %s", added) .. "%0*"
         -- output = output .. " " .. string.format(" %s", added)
      end
      if changed ~= "0" and changed ~= "nil" then
         output = output .. " %#SignChange#" .. string.format(" %s", changed) .. "%0*"
         -- output = output .. " " .. string.format(" %s", changed)
      end
      if removed ~= "0" and removed ~= "nil" then
         output = output .. " %#SignDelete#" .. string.format(" %s", removed) .. "%0*"
         -- output = output .. " " .. string.format(" %s", removed)
      end
   end

   return output
end

M.get_filepath = function(self)
   local filepath = fn.fnamemodify(fn.expand("%"), ":.:h")

   if filepath == "" or filepath == "." or self:is_truncated(self.trunc_width.filename) then
      return " "
   end

   return string.format(" %%<%s/", filepath)
end

M.get_filename = function()
   local filename = fn.expand("%:t")
   return filename == "" and "" or filename
end

M.get_fileflag = function()
   return "%m%r"
end

M.get_filetype = function()
   local filetype = vim.bo.filetype

   if vim.fn.exists("*WebDevIconsGetFileTypeSymbol") then
      filetype = vim.fn.WebDevIconsGetFileTypeSymbol() .. " " .. filetype
   end

  -- stylua: ignore
  return filetype == ""
    and " No FT "
    or string.format("%s ", filetype):lower()
end

M.get_fileformat = function(self)
   local fileformat = vim.o.fileformat

   if vim.fn.exists("*WebDevIconsGetFileFormatSymbol") then
      fileformat = vim.fn.WebDevIconsGetFileFormatSymbol()
   end

   if self:is_truncated(self.trunc_width.fileformat) then
      return ""
   end
   return string.format("%s ", fileformat):lower()
end

M.get_encoding = function(self)
   if self:is_truncated(self.trunc_width.encoding) then
      return ""
   end
   return string.format("%s ", vim.o.encoding):upper()
end

M.get_line_col = function()
   return " %10(%l:%c%V%) %4(%p%%%) "
end

M.lsp_status = function()
   local msg = " "
   local msg_fail = "[No Active LSP]"
   local clients = vim.lsp.buf_get_clients()

   if #clients == 0 then
      return msg_fail
   end

   for _, client in pairs(clients) do
      msg = msg .. client.name .. ","
   end
   msg = string.sub(msg, 1, -2)
   msg = msg .. require("lsp-status").status()

   return msg
end

M.lsp_diagnostic = function()
   local output = ""
   local err_ctr = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
   local err_sign = vim.fn.sign_getdefined("DiagnosticSignError")
   local warn_ctr = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
   local warn_sign = vim.fn.sign_getdefined("DiagnosticSignWarn")
   local hint_ctr = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
   local hint_sign = vim.fn.sign_getdefined("DiagnosticSignHint")
   local info_ctr = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
   local info_sign = vim.fn.sign_getdefined("DiagnosticSignInfo")

   if err_ctr > 0 then
      output = output .. "%#" .. err_sign[1].texthl .. "#" .. err_sign[1].text .. err_ctr .. " %0*"
      -- output = output .. err_sign[1].text .. err_ctr .. " "
   end
   if warn_ctr > 0 then
      output = output .. "%#" .. warn_sign[1].texthl .. "#" .. warn_sign[1].text .. warn_ctr .. " %0*"
      -- output = output .. warn_sign[1].text .. warn_ctr .. " "
   end
   if hint_ctr > 0 then
      output = output .. "%#" .. hint_sign[1].texthl .. "#" .. hint_sign[1].text .. hint_ctr .. " %0*"
      -- output = output .. hint_sign[1].text .. hint_ctr .. " "
   end
   if info_ctr > 0 then
      output = output .. "%#" .. info_sign[1].texthl .. "#" .. info_sign[1].text .. info_ctr .. " %0*"
      -- output = output .. info_sign[1].text .. info_ctr .. " "
   end

   return output
end

M.set_active = function(self)
   return table.concat({
      string.format("[%s] ", self:get_current_mode()),
      self:get_filetype(),
      self:get_filepath(),
      self.get_filename(),
      self.get_fileflag(),
      "%=",
      self:lsp_status(),
      "  ",
      -- "%#String#",
      self:get_encoding(),
      self:get_fileformat(),
      "%0*  ",
      self:get_git_status(),
      self:get_line_col(),
      "  ",
      self:lsp_diagnostic(),
   })
end

M.set_inactive = function()
   return "%#StatusLineNC#" .. "%= %F %="
end

Statusline = setmetatable(M, {
   __call = function(self, mode)
      return self["set_" .. mode](self)
   end,
})

-- set statusline
-- TODO(elianiva): replace this once we can define autocmd using lua
vim.cmd([[
  augroup Statusline
     autocmd!
     autocmd WinEnter,BufEnter * setlocal statusline=%!v:lua.Statusline('active')
     autocmd WinLeave,BufLeave * setlocal statusline=%!v:lua.Statusline('inactive')
  augroup END
]])

-- au WinEnter,BufEnter,FileType NvimTree setlocal statusline=%!v:lua.Statusline('netrw')
