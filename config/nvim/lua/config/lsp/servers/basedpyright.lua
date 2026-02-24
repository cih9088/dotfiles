local utils = require("utils")

return {
  settings = {
    python = {
      pythonPath = utils.get_python_path(),
    },
    basedpyright = {
      autoSearchPaths = true,
      diagnosticMode = "openFilesOnly",
      useLibraryCodeForTypes = true,
      -- Using Ruff's import organizer
      disableOrganizeImports = true,
      typeCheckingMode = "standard",
      analysis = {
        diagnosticSeverityOverrides = {
          -- https://github.com/DetachHead/basedpyright/issues/168
          reportMissingSuperCall = false,
          reportUnusedImport = false,
          reportUnnecessaryIsInstance = false,
          reportImplicitStringConcatenation = false,
          reportIgnoreCommentWithoutRule = false,
          reportAny = false,
        },
      },
    },
  },
}
