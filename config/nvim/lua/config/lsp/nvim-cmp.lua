local this = (...):match("(.-)[^%.]+$")
local M = {}


local function luasnip_setup()
   local ls = require("luasnip")
   ls.filetype_extend("all", { "_" })
   require("luasnip.loaders.from_snipmate").lazy_load()
   -- require("luasnip.loaders.from_vscode").lazy_load()
end

-- https://github.com/lukas-reineke/cmp-under-comparator
local function underscore(entry1, entry2)
   local _, entry1_under = entry1.completion_item.label:find "^_+"
   local _, entry2_under = entry2.completion_item.label:find "^_+"
   entry1_under = entry1_under or 0
   entry2_under = entry2_under or 0
   if entry1_under > entry2_under then
      return false
   elseif entry1_under < entry2_under then
      return true
   end
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
               buffer = "[Buffer]",
               async_path = "[Path]",
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
         ["<C-b>"] = cmp.mapping.scroll_docs(-4),
         ["<C-f>"] = cmp.mapping.scroll_docs(4),
         ["<C-x><C-o>"] = cmp.mapping.complete(),
         ["<C-e>"] = cmp.mapping.close(),
         ["<C-y>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Insert,
            select = false,
         }),
         ["<C-n>"] = cmp.mapping(function(fallback)
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
         ["<C-p>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
               cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
               luasnip.jump(-1)
            else
               fallback()
            end
         end, { "i", "s" }),
      },
      sources = cmp.config.sources({
         { name = "nvim_lsp" },
         { name = "luasnip" },
         { name = "path" },
      }, {
         { name = "buffer", keyword_length = 3 },
         { name = "tmux",   max_item_count = 3 },
         { name = "emoji" },
      }),
      sorting = {
         comparators = {
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,
            underscore,
            cmp.config.compare.recently_used,
            cmp.config.compare.kind,
         },
      },
   })

   -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
   cmp.setup.cmdline(':', {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
         { name = 'path' }
      }, {
         { name = 'cmdline' }
      })
   })
end

function M.setup()
   luasnip_setup()
   cmp_setup()
end

return M
