local M = {}


local lspconfig = require("lspconfig")

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
   -- Mappings.
   local opts = { noremap = true, silent = true }
   vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
   vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
   vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
   vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist, opts)
   --
   local bufopts = { noremap = true, silent = true, buffer = bufnr }
   vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
   vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
   vim.keymap.set("n", "gc", vim.lsp.buf.implementation, bufopts)
   vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
   vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
   -- vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
   -- vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, bufopts)
   -- vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
   -- vim.keymap.set('n', '<space>wl', function()
   --    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
   -- end, bufopts)
   vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, bufopts)
   vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, bufopts)
   vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, bufopts)
   vim.keymap.set('n', '<space>f', function()
      vim.lsp.buf.format { async = true }
   end, bufopts)

   -- Signature help
   local lsp_signature = require("lsp_signature")
   if lsp_signature then
      lsp_signature.on_attach({
         floating_window_above_cur_line = true,
         handler_opts = {
            border = "rounded",
         },
      }, bufnr)
   end

   -- Status help
   require("lsp-status").on_attach(client)

   -- Highlight symbol under cursor
   if client.server_capabilities.documentHighlightProvider then
      vim.cmd([[
         augroup lsp_document_highlight
            autocmd! * <buffer>
            autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
            autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
         augroup END
      ]])
   end

   -- Inlay hints
   require("lsp-inlayhints").on_attach(client, bufnr)
   if client.server_capabilities.inlayHintProvider then
      vim.lsp.buf.inlay_hint(bufnr, true)
   end
end


local server_configs = {
   lua_ls = {
      settings = {
         Lua = {
            diagnostics = {
               globals = { "vim" },
            },
            format = {
               enable = true,
               defaultConfig = {
                  indent_style = "space",
                  indent_size = "2",
               }
            },
         },
      },
   },
   gopls = {
      settings = {
         analyses = {
            unusedparams = true,
         },
         staticcheck = true,
      }
   },
   rust_analyzer = {
      settings = {
         ["rust-analyzer"] = {
            check = {
               enable = true,
               command = "clippy",
               features = "all",
            },
         },
      }
   },
}

local function get_config(server_name)
   local config = server_configs[server_name] or { settings = {} }
   local capabilities = vim.lsp.protocol.make_client_capabilities()

   -- Add additional capabilities supported by nvim-cmp
   capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
   capabilities = vim.tbl_extend("keep", capabilities, require("lsp-status").capabilities)

   config.on_attach = on_attach
   config.capabilities = capabilities
   return config
end


function M.setup()
   -- enable inlay hints
   require("lsp-inlayhints").setup()
   vim.cmd([[
      augroup lsp_inlayhint
         autocmd!
         autocmd ColorScheme * highlight! link LspInlayHint Comment
      augroup END
   ]])
   vim.cmd([[doautocmd ColorScheme]])

   -- Use a loop to conveniently call 'setup' on multiple servers and
   -- map buffer local keybindings when the language server attaches
   local servers = {
      "pyright",
      "gopls",
      "rust_analyzer",
      "bashls",
      "vimls",
      "yamlls",
      "jsonls",
      "lua_ls",
      "ansiblels",
      "tsserver",
      "cmake"
   }
   for _, server in ipairs(servers) do
      local config = get_config(server)
      lspconfig[server].setup {
         on_attach = config.on_attach,
         capabilities = config.capabilities,
         settings = config.settings,
      }
   end
end

return M
