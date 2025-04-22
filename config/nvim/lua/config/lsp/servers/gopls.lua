return {
   settings = {
      analyses = {
         unusedparams = true,
      },
      staticcheck = true,
      gofumpt = true,
      hints = {
         assignVariableTypes = true,
         compositeLiteralFields = true,
         compositeLiteralTypes = true,
         constantValues = true,
         functionTypeParameters = true,
         parameterNames = true,
         rangeVariableTypes = true,
      },
   }
}
