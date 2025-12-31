local M = {}

local utils = require("utils")

function M.setup()
   local ts = utils.safe_require("nvim-treesitter")
   if not ts then
      return
   end

   local group = vim.api.nvim_create_augroup('TreesitterSetup', { clear = true })

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

   vim.api.nvim_create_autocmd('FileType', {
      group = group,
      callback = function(event)
         local lang = vim.treesitter.language.get_lang(event.match) or event.match

         -- install treesitter if not installed
         ts.install({ lang })

         -- it will be handeld by pearofducks/ansible-vim
         if event.match == "yaml.ansible" then
            return
         end

         enable_treesitter(event.buf, lang)
      end,
   })
end

return M
