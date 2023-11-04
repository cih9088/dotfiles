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
      automatic_installation = true,
   })

   mason_null_ls.setup({
      ensure_installed = {
         "black", "isort", "ruff",
         "prettier",
         "ansiblelint",
         "shellcheck", "shfmt",
         "printenv",
         "gitsigns",

         "debugpy", "js-debug-adapter", "codelldb", "delve", "bash-debug-adapter"
      },
   })
end

return M
