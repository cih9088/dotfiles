local M = {}

local utils = require("utils")

function M.setup()
   local mason = utils.safe_require("mason")
   local mason_lspconfig = utils.safe_require("mason-lspconfig")
   local mason_null_ls = utils.safe_require("mason-null-ls")

   if mason then
      mason.setup({
         ui = {
            icons = {
               package_installed = "✓",
               package_pending = "➜",
               package_uninstalled = "✗"
            }
         }
      })
   end

   if mason_lspconfig then
      mason_lspconfig.setup({
         ensure_installed = {
            "basedpyright",
            "gopls",
            "rust_analyzer",
            "bashls",
            "vimls",
            "lua_ls",
            "cmake",
            "clangd",
            "html",
            "cssls",
            "ts_ls",
            "tailwindcss",
            "emmet_language_server",
            "yamlls",
            "ansiblels",
            "jsonls",
            "terraformls",
            "taplo",
            "zls",
         },
         automatic_installation = true,
      })
   end

   if mason_null_ls then
      mason_null_ls.setup({
         ensure_installed = {
            "black", "isort", "ruff",
            "prettierd", "eslint-lsp",
            "ansiblelint",
            "shellcheck", "shfmt",
            "goimports", "golines",
            "yamlfmt",

            "debugpy", "js-debug-adapter", "codelldb", "delve", "bash-debug-adapter",

            "tree-sitter-cli",
         },
      })
   end
end

return M
