local M = {}

local utils = require("utils")

function M.setup()
  local null_ls = utils.safe_require("null-ls")

  if null_ls then
    null_ls.setup({
      debug = false,
      sources = {
        -- ruff will take care of it
        -- -- python
        -- null_ls.builtins.formatting.black,
        -- null_ls.builtins.formatting.isort.with({
        --    args = { "--stdout", "--profile", "black", "--lines-after-imports", "2", "--filename", "$FILENAME", "-" },
        -- }),

        -- go
        -- golines run goimports at the last stage so no need
        -- null_ls.builtins.formatting.goimports,
        null_ls.builtins.formatting.golines,

        -- lua
        -- null_ls.builtins.formatting.stylua,

        -- remove yaml for yamlfmt
        null_ls.builtins.formatting.prettierd.with({
          filetype = {
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
            "vue",
            "css",
            "scss",
            "less",
            "html",
            "json",
            "jsonc",
            "markdown",
            "markdown.mdx",
            "graphql",
            "handlebars",
            "svelte",
            "astro",
            "htmlangular",
          },
        }),

        -- yaml (no indent at arrays)
        null_ls.builtins.formatting.yamlfmt.with({
          args = { "-formatter", "indentless_arrays=true,retain_line_breaks_single=true", "-" },
        }),

        -- yaml.ansible
        null_ls.builtins.diagnostics.ansiblelint,

        -- sh
        null_ls.builtins.formatting.shfmt.with({
          args = {
            "--case-indent",
            "--indent",
            "2",
            "--simplify",
            "--binary-next-line",
            "--filename",
            "$FILENAME",
          },
        }),
        -- null_ls.builtins.diagnostics.shellcheck,
        null_ls.builtins.hover.printenv,

        -- general
        null_ls.builtins.code_actions.gitsigns,
      },
      diagnostics_format = "[#{s}/#{c}] #{m}",
    })
  end
end

return M
