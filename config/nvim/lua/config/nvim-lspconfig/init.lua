local this = ...

require(this .. ".ui").setup()
require(this .. ".nvim-lsp-installer").setup()
require(this .. ".lsp-status").setup()
require(this .. ".nvim-cmp").setup()

local on_attach = require(this .. ".on_attach")
local efm_config = require(this .. ".efm")

local lsp_config = require("lspconfig")

local servers = {
   efm = {
      filetypes = vim.tbl_keys(efm_config),
      init_options = { documentFormatting = true },
      root_dir = lsp_config.util.root_pattern({ ".git/", "." }),
      settings = { languages = efm_config },
   },
   sumneko_lua = {
      settings = {
         Lua = {
            diagnostics = {
               globals = { "vim" },
            },
         },
      },
   },
}

local function get_config(server_name)
   local config = servers[server_name] or {}
   local capabilities = vim.lsp.protocol.make_client_capabilities()

   capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)
   capabilities = vim.tbl_extend("keep", capabilities, require("lsp-status").capabilities)

   config.on_attach = on_attach
   config.capabilities = capabilities
   return config
end

require("nvim-lsp-installer").on_server_ready(function(server)
   server:setup(get_config(server.name))
   -- vim.cmd [[ do User LspAttachBuffers ]]
end)

-- -- Add additional capabilities supported by nvim-cmp
-- local capabilities = vim.lsp.protocol.make_client_capabilities()
-- capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)
--
-- -- Use a loop to conveniently call 'setup' on multiple servers and
-- -- map buffer local keybindings when the language server attaches
-- local servers = { 'pyright' }
-- for _, lsp in ipairs(servers) do
--  lsp_config[lsp].setup {
--    on_attach = on_attach,
--    capabilities = capabilities,
--    flags = {
--      debounce_text_changes = 150,
--    }
--  }
-- end
