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
         "pyright",
         "gopls@v0.13.2",
         "rust_analyzer",
         "bashls",
         "vimls",
         "lua_ls",
         "cmake",
         "clangd",
         "html",
         "cssls",
         "tsserver",
         "tailwindcss",
         "emmet_language_server",
         "yamlls",
         "ansiblels",
         "jsonls",
      },
      automatic_installation = true,
   })

   mason_null_ls.setup({
      ensure_installed = {
         "black", "isort", "ruff",
         "prettierd", "eslint_d",
         -- python 3.8 compatible
         "ansiblelint@6.13.1",
         "shellcheck", "shfmt",

         "debugpy", "js-debug-adapter", "codelldb", "delve", "bash-debug-adapter"
      },
   })
end

return M
