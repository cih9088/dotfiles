local M = {}

local utils = require("utils")

function M.setup()
   local conform = utils.safe_require("conform")

   if conform then
      conform.setup({
         -- log_level = vim.log.levels.DEBUG,
         formatters = {
            yamlfmt = {
               -- no indent at array
               -- prepend_args = { "-formatter", "indentless_arrays=true,retain_line_breaks_single=true" },
               prepend_args = function(self, ctx)
                  local ctr = 0
                  for line in utils.iter_lines_from(ctx.filename) do
                     -- look for first 10 lines
                     if not line or ctr > 10 then
                        break
                     end

                     -- k8s yaml file
                     if line:sub(1, #"apiVersion") == "apiVersion" then
                        return {
                           "-formatter",
                           "indentless_arrays=true,retain_line_breaks_single=true",
                        }
                     end

                     ctr = ctr + 1
                  end
                  return { "-formatter", "retain_line_breaks_single=true" }
               end,
            },
            shfmt = {
               prepend_args = { "--case-indent", "--indent", "2", "--binary-next-line" },
            },
         },
         formatters_by_ft = {
            python = function(bufnr)
               if conform.get_formatter_info("ruff_format", bufnr).available then
                  return { "ruff_format", "ruff_organize_imports" }
               else
                  return { "isort", "black" }
               end
            end,
            -- golines run goimports at the last stage so no need
            go = { "golines" },
            yaml = { "yamlfmt" },
            lua = { "stylua" },
            javascript = { "prettierd", "prettier", stop_after_first = true },
            javascriptreact = { "prettierd", "prettier", stop_after_first = true },
            typescript = { "prettierd", "prettier", stop_after_first = true },
            typescriptreact = { "prettierd", "prettier", stop_after_first = true },
            html = { "prettierd", "prettier", stop_after_first = true },
            json = { "prettierd", "prettier", stop_after_first = true },
            markdown = { "prettierd", "prettier", stop_after_first = true },
            sh = { "shfmt" },
            bash = { "shfmt" },
            zsh = { "shfmt" },
         },
         default_format_opts = {
            lsp_format = "fallback",
         },
      })

      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

      vim.keymap.set('n', '<space>f', function()
         conform.format({ async = true })
      end)
   end
end

return M
