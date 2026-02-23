local M = {}

local utils = require("utils")

function M.setup()
   -- HACK
   local ismaster = utils.safe_require({ 'nvim-treesitter.statusline', ignore = true})
   if ismaster then
      M.setup_master_branch()
   else
      M.setup_main_branch()
   end
end

function M.setup_master_branch()
   local ts = utils.safe_require("nvim-treesitter.configs")
   if not ts then
      return
   end

   ts.setup({
      auto_install = true,
      highlight = {
         enable = true,
         disable = function(lang, bufnr)
            return lang == "yaml" and vim.bo.filetype == "yaml.ansible"
         end,
      },
      indent = {
         enable = true,
         disable = { 'yaml' },
      },
   })

   -- folding
   vim.wo.foldmethod = 'expr'
   vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
end

function M.setup_main_branch()
   local ts = utils.safe_require("nvim-treesitter")
   if not ts then
      return
   end

   -- Enable treesitter for a buffer
   local function enable_treesitter(buf, lang)
      if not vim.api.nvim_buf_is_valid(buf) then
         return
      end

      local ok = pcall(vim.treesitter.start, buf, lang)
      if ok then
         -- indentation
         vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

         -- folding
         for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_get_buf(win) == buf and vim.api.nvim_win_is_valid(win) then
               vim.wo[win].foldmethod = 'expr'
               vim.wo[win].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
            end
         end
      end
   end

   local function enable_treesitter_when_ready(buf, lang, timeout_ms)
      timeout_ms = timeout_ms or 10000
      local interval = 500

      if vim.list_contains(ts.get_installed(), lang) then
         vim.schedule(function()
            enable_treesitter(buf, lang)
         end)
      elseif timeout_ms <= 0 then
         vim.notify(
            string.format("[TS] Timeout: '%s' parser failed to install.", lang),
            vim.log.levels.ERROR
         )
      else
         vim.defer_fn(function()
            enable_treesitter_when_ready(buf, lang, timeout_ms - interval)
         end, interval)
      end
   end

   local group = vim.api.nvim_create_augroup('TreesitterSetup', { clear = true })

   local ensure_installed = {
      "comment",
   }

   for _, parser in ipairs(ensure_installed) do
       ts.install(parser)
   end

   local ignore_filetypes = {
      "checkhealth",
      "startify",
      "netrw",
      "fugitive",
      "fzf",
      "mason",
      "cmp_menu",
      "cmp_docs",
   }

   vim.api.nvim_create_autocmd('FileType', {
      group = group,
      callback = function(event)
         if vim.tbl_contains(ignore_filetypes, event.match) then
           return
         end

         local lang = vim.treesitter.language.get_lang(event.match) or event.match

         if vim.list_contains(ts.get_installed(), lang) then
            enable_treesitter(event.buf, lang)
         elseif vim.list_contains(ts.get_available(), lang) then
            -- install treesitter parser
            ts.install({ lang })

            -- it will be handeld by pearofducks/ansible-vim
            if event.match == "yaml.ansible" then
               return
            end

            enable_treesitter_when_ready(event.buf, lang)
         end
      end,
   })
end

return M
