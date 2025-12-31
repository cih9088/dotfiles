return {
   settings = {
      Lua = {
         diagnostics = {
            globals = { "vim" },
         },
         format = {
            -- Using stylua
            enable = false,
            defaultConfig = {
               indent_style = "space",
               indent_size = "3",
            }
         },
         workspace = {
            library = {
               vim.env.VIMRUNTIME,
            },
         },
         telemetry = {
            enable = false,
         },
      },
   },
}
