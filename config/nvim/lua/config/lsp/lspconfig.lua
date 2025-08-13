local M = {}


local utils = require("utils")

local function get_config(server_name)
   local config = utils.safe_require("config.lsp.servers." .. server_name)
   if config == nil then
      config = {}
   end

   local capabilities = vim.lsp.protocol.make_client_capabilities()

   -- Add additional capabilities supported by nvim-cmp
   local cmp_nvim_lsp = utils.safe_require("cmp_nvim_lsp")
   if cmp_nvim_lsp then
      capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
   end
   local lsp_status = utils.safe_require("lsp-status")
   if lsp_status then
      capabilities = vim.tbl_extend("keep", capabilities, lsp_status.capabilities)
   end

   config.capabilities = capabilities
   return config
end


function M.setup()
   local configs_to_be_enabled = {}

   -- -- collect LSPs in a primary runtimepath
   -- for _, v in ipairs(vim.api.nvim_get_runtime_file('lsp/*', true)) do
   --    local name = vim.fn.fnamemodify(v, ':t:r')
   --    configs_to_be_enabled[name] = true
   -- end

   for _, file in ipairs(vim.api.nvim_get_runtime_file('lua/config/lsp/servers/*.lua', true)) do
      local file_name = file:match("[^/]*.lua$")
      local server = file_name:sub(0, #file_name - 4)
      local config = get_config(server)

      if vim.fn.has("nvim-0.11") == 1 then
         vim.lsp.config(server, {
            on_attach = config.on_attach,
            capabilities = config.capabilities,
            settings = config.settings,
         })
         configs_to_be_enabled[server] = true
      else
         local handlers = {
            ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "single" }),
            ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help,
               { border = "single", focusable = false }),
         }
         require("lspconfig")[server].setup {
            on_attach = config.on_attach,
            capabilities = config.capabilities,
            settings = config.settings,
            handlers = handlers,
         }
      end
   end

   -- enable LSPs
   if vim.fn.has("nvim-0.11") == 1 and next(configs_to_be_enabled) ~= nil then
      vim.lsp.enable(vim.tbl_keys(configs_to_be_enabled))
   end

   vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('UserLspConfig', {}),
      callback = function(ev)
         local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))

         -- Setup statusline
         local lsp_status = utils.safe_require({ "lsp-status", ignore = true })
         if lsp_status then
            lsp_status.on_attach(client)
         end

         -- Setup signature help
         local lsp_signature = utils.safe_require({ "lsp_signature", ignore = true })
         if lsp_signature then
            lsp_signature.on_attach({
               bind = true,
               floating_window_above_cur_line = true,
               handler_opts = {
                  border = "single",
               },
               toggle_key = "<M-x>",

            }, ev.buf)
         end

         -- Setup diagnostic mapping
         local opts = { noremap = true, silent = true }
         vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
         vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
         vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist, opts)

         -- Buffer local mappings.
         -- See `:help vim.lsp.*` for documentation on any of the below functions
         local bufopts = { noremap = true, silent = true, buffer = ev.buf }
         vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
         vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
         vim.keymap.set("n", "gc", vim.lsp.buf.implementation, bufopts)
         vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
         vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, bufopts)
         vim.keymap.set("n", "K", function()
            vim.lsp.buf.hover({ border = "single" })
         end, bufopts)
         -- vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
         -- vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, bufopts)
         -- vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
         -- vim.keymap.set('n', '<space>wl', function()
         --    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
         -- end, bufopts)
         vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, bufopts)
         vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, bufopts)
         vim.keymap.set('n', '<space>f', function()
            local conform = utils.safe_require("conform")
            if conform then
               conform.format({ async = true })
            else
               vim.lsp.buf.format { async = true }
            end
         end, bufopts)

         -- Setup inlay hints
         if client.server_capabilities.inlayHintProvider then
            -- Disalbe it by default since it is quite annoying sometimes
            if vim.lsp.inlay_hint then
               vim.lsp.inlay_hint.enable(false, { bufnr = ev.buf })
            end
            vim.api.nvim_buf_create_user_command(ev.buf, "LspToggleInlayHint", function()
               vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }))
            end, {})
            vim.keymap.set("n", "<space>h", "<cmd>LspToggleInlayHint<CR>", { buffer = true })
         end

         -- Highlight symbol under cursor
         if client.server_capabilities.documentHighlightProvider then
            vim.cmd([[
               augroup lsp_document_highlight
                  autocmd! * <buffer>
                  autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
                  autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
               augroup END
            ]])
         end

         -- Disable highlight from lsp for TreeSitter
         client.server_capabilities.semanticTokensProvider = nil
      end,
   })

   -- setup kubernetes yamlls
   local kubernetes = utils.safe_require("kubernetes")
   if kubernetes then
      -- only generate the schema if the files don't already exists.
      -- run `:KubernetesGenerateSchema` manually to generate the schema if needed.
      kubernetes.setup({ schema_generate_always = false })
   end
end

return M
