local M = {}

local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")
local mason_null_ls = require("mason-null-ls")

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
         "ansiblels",
         "bashls",
         "cmake",
         "clangd",
         "gopls@v0.13.2",
         "jsonls",
         "lua_ls",
         "pyright",
         "rust_analyzer",
         "tsserver",
         "vimls",
         "yamlls",
      },
      automatic_installation = true,
   })

   mason_null_ls.setup({
      ensure_installed = {
         "black", "isort", "ruff",
         "prettier",
         -- python 3.8 compatible
         "ansiblelint@6.13.1",
         "shellcheck", "shfmt",

         "debugpy", "js-debug-adapter", "codelldb", "delve", "bash-debug-adapter"
      },
   })
end

return M
