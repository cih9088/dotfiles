local M = {}

local function install_lscp()
   local lsp_installer = require("nvim-lsp-installer")

   -- List of lsp servers to install
   local servers = {
      "pyright",
      "gopls",
      "rust_analyzer",
      "bashls",
      "vimls",
      "yamlls",
      "jsonls",
      "efm",
      "sumneko_lua",
      "ansiblels",
      "tsserver",
   }

   for _, name in pairs(servers) do
      local server_available, server = lsp_installer.get_server(name)
      if server_available and not server:is_installed() then
         -- server:install() -- no UI
         lsp_installer.install(name) -- UI
      end
   end
end

function M.setup()
   install_lscp()
end

return M
