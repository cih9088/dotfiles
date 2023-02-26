local M = {}

local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")

function M.setup()
   mason.setup({
      ui = {
         icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
         }
      }
   })
   mason_lspconfig.setup({
      ensure_installed = {
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
      }
   })
end

return M
