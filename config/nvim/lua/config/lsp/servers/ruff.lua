return {
  settings = {
    fixAll = true,
    -- in favor of Conform
    organizeImports = false,
  },
  on_attach = function(client, bufnr)
    -- in favor of basedpyright
    client.server_capabilities.hoverProvider = false
    -- in favor of Conform
    client.server_capabilities.documentFormattingProvider = false
  end,
}
