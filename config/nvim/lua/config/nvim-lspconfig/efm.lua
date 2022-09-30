return {
   yaml = {
      {
         formatCommand = "prettier --stdin-filepath ${INPUT} --parser yaml",
         formatStdin = true,
      },
   },
   json = {
      {
         formatCommand = "prettier --stdin-filepath ${INPUT} --parser json",
         formatStdin = true,
      },
   },
   markdown = {
      {
         formatCommand = "prettier --stdin-filepath ${INPUT} --parser markdown",
         formatStdin = true,
      },
   },
   html = {
      {
         formatCommand = "prettier --stdin-filepath ${INPUT}",
         formatStdin = true,
      },
   },
   css = {
      {
         formatCommand = "prettier --stdin-filepath ${INPUT}",
         formatStdin = true,
      },
   },
   python = {
      {
         formatCommand = "black --quiet -",
         formatStdin = true,
      },
      {
         formatCommand = "isort --stdout --profile black --lines-after-imports 2 -",
         formatStdin = true,
      },
      {
         lintCommand = "flake8 --max-line-length 160 --format '%(path)s:%(row)d:%(col)d: %(code)s %(code)s %(text)s' --stdin-display-name ${INPUT} -",
         lintStdin = true,
         lintIgnoreExitCode = true,
         lintFormats = { "%f:%l:%c: %t%n%n%n %m" },
         lintSource = "flake8",
      },
      -- {
      --    lintCommand = "pylint --output-format text --score no --msg-template {path}:{line}:{column}:{C}:{msg} ${INPUT}",
      --    lintStdin = false,
      --    lintIgnoreExitCode = true,
      --    lintFormats = { "%f:%l:%c: %t%n%n%n %m" },
      --    lintSource = "pylint",
      -- },
   },
   lua = {
      {
         formatCommand = "stylua -s --indent-type Spaces --indent-width 3 -",
         formatStdin = true,
      },
   },
   sh = {
      {
         formatCommand = "shfmt -ci -i 2 -s -bn",
      },
      {
         lintCommand = "shellcheck -f gcc -x -",
         lintStdin = true,
         lintFormats = { "%f:%l:%c: %trror: %m", "%f:%l:%c: %tarning: %m", "%f:%l:%c: %tote: %m" },
         lintSource = "shellcheck",
      },
   },
}
