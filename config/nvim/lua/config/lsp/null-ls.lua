local M = {}

local null_ls = require("null-ls")

function M.setup()
   null_ls.setup({
      debug = true,
      sources = {
         -- python
         null_ls.builtins.formatting.black,
         null_ls.builtins.formatting.isort.with({
            args = { "--stdout", "--profile", "black", "--lines-after-imports", "2", "--filename", "$FILENAME", "-" },
         }),
         null_ls.builtins.diagnostics.flake8,
         -- -- lua
         -- null_ls.builtins.formatting.stylua,

         null_ls.builtins.formatting.prettier,
         null_ls.builtins.diagnostics.ansiblelint,
         -- sh
         null_ls.builtins.formatting.shfmt.with({
            args = { "--case-indent", "--indent", "2", "--simplify", "--binary-next-lint", "--filename", "$FILENAME" },
         }),
         null_ls.builtins.diagnostics.shellcheck.with({
            args = { "--format", "json1", "--external-sources", "-" }
            -- args = { "--format", "json1", "--source-path=$DIRNAME", "--external-sources", "-" }
         }),
         null_ls.builtins.hover.printenv,
         -- general
         null_ls.builtins.code_actions.gitsigns,
      },
      diagnostics_format = "[#{s}/#{c}] #{m}"
   })
end

return M
