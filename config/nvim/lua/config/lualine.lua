local lualine = require("lualine")

local colours = require("lualine.themes.auto")

local conditions = {
   buffer_not_empty = function()
      return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
   end,
   hide_in_width = function()
      return vim.fn.winwidth(0) > 80
   end,
   check_git_workspace = function()
      local filepath = vim.fn.expand("%:p:h")
      local gitdir = vim.fn.finddir(".git", filepath .. ";")
      return gitdir and #gitdir > 0 and #gitdir < #filepath
   end,
}

-- Config
local config = {
   options = {
      -- Disable sections and component separators
      component_separators = "",
      section_separators = "",
      theme = "auto",
   },
   sections = {
      -- these are to remove the defaults
      lualine_a = {},
      lualine_b = {},
      lualine_y = {},
      lualine_z = {},
      -- These will be filled later
      lualine_c = {},
      lualine_x = {},
   },
}

table.insert(config.sections.lualine_a, {
   function()
      return "▊"
   end,
   color = { fg = colours.command.a.bg, bg = colours.command.a.fg },
   padding = { left = 0, right = 1 }, -- We don't need space before this
})

table.insert(config.sections.lualine_a, {
   "filetype",
})

-- table.insert(config.sections.lualine_b, {
--    "filetype",
--    icon_only = true,
--    padding = 1,
-- })

-- Inserts a component in lualine_c at left section
local function ins_left(component)
   table.insert(config.sections.lualine_c, component)
end

-- Inserts a component in lualine_x ot right section
local function ins_right(component)
   table.insert(config.sections.lualine_x, component)
end

-- ins_left({
--   function()
--     return '▊'
--   end,
--   color = { fg = colours.command.a.bg, bg = colours.command.a.fg  },
--   padding = { left = 0, right = 1 }, -- We don't need space before this
-- })

-- ins_left({
--   -- mode component
--   function()
--     -- auto change color according to neovims mode
--     local mode_color = {
--       n = colors.red,
--       i = colors.green,
--       v = colors.blue,
--       [''] = colors.blue,
--       V = colors.blue,
--       c = colors.magenta,
--       no = colors.red,
--       s = colors.orange,
--       S = colors.orange,
--       [''] = colors.orange,
--       ic = colors.yellow,
--       R = colors.violet,
--       Rv = colors.violet,
--       cv = colors.red,
--       ce = colors.red,
--       r = colors.cyan,
--       rm = colors.cyan,
--       ['r?'] = colors.cyan,
--       ['!'] = colors.red,
--       t = colors.red,
--     }
--     vim.api.nvim_command('hi! LualineMode guifg=' .. mode_color[vim.fn.mode()] .. ' guibg=' .. colors.bg)
--     return ''
--   end,
--   color = 'LualineMode',
--   padding = { right = 1 },
-- })

-- ins_left({
--   -- filesize component
--   'filesize',
--   cond = conditions.buffer_not_empty,
-- })
--

-- ins_left({
--    "filetype",
--    icon_only = true,
--    padding = { left = 1 },
-- })

ins_left({
   "filename",
   path = 1,
   color = { fg = colours.replace.a.bg, gui = "bold" },
})

-- Insert mid section. You can make any number of sections in neovim :)
-- for lualine it's any number greater then 2
ins_left({
   function()
      return '%='
   end,
})

ins_right({
   -- Lsp server name .
   function()
      local msg = "No Active Lsp"
      local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
      local clients = vim.lsp.buf_get_clients(0)
      if next(clients) == nil then
         return msg
      end
      if require('lsp-status').status() ~= " " then
         return require('lsp-status').status()
      end
      msg = ""
      for _, client in ipairs(clients) do
         local filetypes = client.config.filetypes
         if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
            msg = msg .. client.name .. " "
         end
      end
      return msg
   end,
   color = { gui = "bold" },
   icon = " ",
   cond = conditions.buffer_not_empty,
})

-- Add components to right sections
ins_right({
   "o:encoding", -- option component same as &encoding in viml
   fmt = string.upper, -- I'm not sure why it's upper case either ;)
   color = { fg = colours.insert.a.bg, gui = "bold" },
   cond = conditions.hide_in_width,
})

ins_right({
   "fileformat",
   fmt = string.upper,
   icons_enabled = true,
   color = { fg = colours.insert.a.bg, gui = "bold" },
})

ins_right({
   "branch",
   icon = "",
   color = { fg = colours.visual.a.bg, gui = "bold" },
   cond = conditions.hide_in_width,
})

ins_right({
   "diff",
   -- Is it me or the symbol for modified us really weird
   symbols = { added = " ", modified = "柳", removed = " " },
   -- diff_color = {
   --   added = 'DiffAdd',
   --   modified = 'DiffChange',
   --   removed = 'DiffDelete',
   -- },
   cond = conditions.hide_in_width,
})

ins_right({ "location" })

ins_right({ "progress", color = { gui = "bold" } })

ins_right({
   "diagnostics",
   sources = { "nvim_diagnostic", "coc" },
   symbols = { error = " ", warn = " ", info = " ", hint = " " },
   diagnostics_color = {
      -- Same values as the general color option can be used here.
      error = "DiagnosticError", -- Changes diagnostics' error color.
      warn = "DiagnosticWarn", -- Changes diagnostics' warn color.
      info = "DiagnosticInfo", -- Changes diagnostics' info color.
      hint = "DiagnosticHint", -- Changes diagnostics' hint color.
   },
})

ins_right({
   function()
      return "▊"
   end,
   color = { fg = colours.command.a.bg, bg = colours.command.a.fg },
   padding = { left = 1 },
})

-- Now don't forget to initialize lualine
lualine.setup(config)
