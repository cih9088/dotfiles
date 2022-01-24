local this = (...):match("(.-)[^%.]+$")
local M = {}

local function luasnip_setup()
   local ls = require("luasnip")
   ls.filetype_extend("all", { "_" })
   require("luasnip.loaders.from_snipmate").load()
   -- require("luasnip.loaders.from_vscode").load()
end

local function tabnine_setup()
   local tabnine = require("cmp_tabnine.config")

   tabnine:setup({
      max_lines = 1000,
      max_num_results = 20,
      sort = true,
      run_on_every_keystroke = true,
      snippet_placeholder = "..",
   })
end

local function cmp_setup()
   local has_words_before = function()
      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
   end

   local luasnip = require("luasnip")
   local kind_icons = require(this .. "kind")

   local cmp = require("cmp")
   cmp.setup({
      formatting = {
         format = function(entry, vim_item)
            -- Kind icons
            vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind], vim_item.kind)
            -- Source
            vim_item.menu = ({
               nvim_lsp = "[LSP]",
               luasnip = "[LuaSnip]",
               -- cmp_tabnine = "[TabNine]",
               buffer = "[Buffer]",
               path = "[Path]",
               tmux = "[Tmux]",
            })[entry.source.name]
            return vim_item
         end,
      },
      snippet = {
         expand = function(args)
            -- vim.fn["UltiSnips#Anon"](args.body)
            require("luasnip").lsp_expand(args.body)
         end,
      },
      mapping = {
         ["<C-p>"] = cmp.mapping.select_prev_item(),
         ["<C-n>"] = cmp.mapping.select_next_item(),
         ["<C-d>"] = cmp.mapping.scroll_docs(-4),
         ["<C-f>"] = cmp.mapping.scroll_docs(4),
         ["<C-x><C-o>"] = cmp.mapping.complete(),
         ["<C-e>"] = cmp.mapping.close(),
         ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = false,
         }),
         ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
               cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
               luasnip.expand_or_jump()
            elseif has_words_before() then
               cmp.complete()
            else
               fallback()
            end
         end, { "i", "s" }),
         ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
               cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
               luasnip.jump(-1)
            else
               fallback()
            end
         end, { "i", "s" }),
      },
      sources = {
         { name = "nvim_lsp" },
         { name = "luasnip" },
         -- { name = 'ultisnips' },
         -- { name = "cmp_tabnine" },
         { name = "buffer", keyword_length = 5 },
         { name = "path" },
         { name = "tmux", max_item_count = 5 },
      },
   })

   -- cmp.setup.cmdline('/', {
   --    sources = {
   --       { name = 'buffer' }
   --    }
   -- })

   -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
   cmp.setup.cmdline(":", {
      sources = cmp.config.sources({
         { name = "path" },
      }, {
         { name = "cmdline" },
      }),
   })
end

function M.setup()
   luasnip_setup()
   -- tabnine_setup()
   cmp_setup()
end

return M
