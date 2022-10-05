local M = {}


local lspconfig = require("lspconfig")

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)

   -- Mappings.
   local opts = { noremap = true, silent = true }
   vim.keymap.set("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
   vim.keymap.set("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
   vim.keymap.set("n", "<space>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
   --
   local bufopts = { noremap = true, silent = true, buffer = bufnr }
   vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", bufopts)
   vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", bufopts)
   vim.keymap.set("n", "gc", "<cmd>lua vim.lsp.buf.implementation()<CR>", bufopts)
   vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", bufopts)
   vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", bufopts)
   -- vim.keymap.set('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', bufopts)
   -- vim.keymap.set('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', bufopts)
   -- vim.keymap.set('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', bufopts)
   -- vim.keymap.set('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', bufopts)
   vim.keymap.set("n", "<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", bufopts)
   vim.keymap.set("n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", bufopts)
   vim.keymap.set("n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", bufopts)
   vim.keymap.set("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", bufopts)

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

   -- -- Highlight symbol under cursor
   -- if client.resolved_capabilities.document_highlight then
   --    vim.cmd([[
   --       hi LspReferenceRead cterm=bold ctermbg=red guibg=red
   --       hi LspReferenceText cterm=bold ctermbg=red guibg=red
   --       hi LspReferenceWrite cterm=bold ctermbg=red guibg=red
   --       augroup lsp_document_highlight
   --          autocmd! * <buffer>
   --          autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
   --          autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
   --       augroup END
   --    ]])
   -- end

   ---- So that the only client with format capabilities is efm
   -- if client.name ~= 'efm' then
   --  client.resolved_capabilities.document_formatting = false
   -- end

   -- if client.resolved_capabilities.document_formatting then
   --  vim.cmd [[
   --      augroup Format
   --        au! * <buffer>
   --        au BufWritePre <buffer> lua vim.lsp.buf.formatting_sync(nil, 1000)
   --      augroup END
   --    ]]
   -- end
end


local server_configs = {
   -- efm = {
   --    filetypes = vim.tbl_keys(efm_config),
   --    init_options = { documentFormatting = true },
   --    root_dir = lspconfig.util.root_pattern({ ".git/", "." }),
   --    settings = { languages = efm_config },
   -- },
   -- sumneko_lua = {
   --    settings = {
   --       Lua = {
   --          diagnostics = {
   --             globals = { "vim" },
   --          },
   --       },
   --    },
   -- },
}

local function get_config(server_name)
   local config = server_configs[server_name] or {}
   local capabilities = vim.lsp.protocol.make_client_capabilities()

   -- Add additional capabilities supported by nvim-cmp
   capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)
   capabilities = vim.tbl_extend("keep", capabilities, require("lsp-status").capabilities)

   config.on_attach = on_attach
   config.capabilities = capabilities
   return config
end

--
-- require("nvim-lsp-installer").on_server_ready(function(server)
--    server:setup(get_config(server.name))
--    -- vim.cmd [[ do User LspAttachBuffers ]]
-- end)


function M.setup()

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
      "sumneko_lua",
      "ansiblels",
      "tsserver",
   }
   for _, server in ipairs(servers) do
      local config = get_config(server)
      lspconfig[server].setup {
         on_attach = config.on_attach,
         capabilities = config.capabilities
      }
   end
end

return M
