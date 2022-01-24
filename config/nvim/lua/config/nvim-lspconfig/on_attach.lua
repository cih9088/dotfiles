-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
return function(client, bufnr)
   local function buf_set_keymap(...)
      vim.api.nvim_buf_set_keymap(bufnr, ...)
   end
   local function buf_set_option(...)
      vim.api.nvim_buf_set_option(bufnr, ...)
   end

   -- -- Enable completion triggered by <c-x><c-o>
   -- buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

   -- Mappings.
   local opts = { noremap = true, silent = true }

   -- See `:help vim.lsp.*` for documentation on any of the below functions
   buf_set_keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
   buf_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
   buf_set_keymap("n", "gc", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
   buf_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
   buf_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
   -- buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
   -- buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
   -- buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
   -- buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
   buf_set_keymap("n", "<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
   buf_set_keymap("n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
   buf_set_keymap("n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
   -- buf_set_keymap("n", "<space>e", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
   buf_set_keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
   buf_set_keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
   buf_set_keymap("n", "<space>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
   buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)

   -- Signature help
   local lsp_signature = require("lsp_signature")
   if lsp_signature then
      lsp_signature.on_attach({
         floating_window_above_cur_line = true,
         handler_opts = {
            border = "rounded",
         },
      }, bufnr)
   end

   -- Status help
   require("lsp-status").on_attach(client)

   -- -- Highlight symbol under cursor
   -- if client.resolved_capabilities.document_highlight then
   --    vim.cmd([[
   --       hi LspReferenceRead cterm=bold ctermbg=red guibg=LightYellow
   --       hi LspReferenceText cterm=bold ctermbg=red guibg=LightYellow
   --       hi LspReferenceWrite cterm=bold ctermbg=red guibg=LightYellow
   --       augroup lsp_document_highlight
   --          autocmd! * <buffer>
   --          autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
   --          autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
   --       augroup END
   --    ]])
   -- end

   ---- So that the only client with format capabilities is efm
   -- if client.name ~= 'efm' then
   --  client.resolved_capabilities.document_formatting = false
   -- end

   -- if client.resolved_capabilities.document_formatting then
   --  vim.cmd [[
   --      augroup Format
   --        au! * <buffer>
   --        au BufWritePre <buffer> lua vim.lsp.buf.formatting_sync(nil, 1000)
   --      augroup END
   --    ]]
   -- end
end
