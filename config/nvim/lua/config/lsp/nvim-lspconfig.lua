local M = {}

local utils = require("utils")

local server_configs = {
   basedpyright = {
      settings = {
         python = {
            pythonPath = utils.get_python_path(),
         },
         basedpyright = {
            -- Using Ruff's import organizer
            disableOrganizeImports = true,
            -- typeCheckingMode = "standard",
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
   },
   pyright = {
      settings = {
         pyright = {
            -- Using Ruff's import organizer
            disableOrganizeImports = true,
         },
      },
   },
   ruff = {
      on_attach = function(client, bufnr)
         client.server_capabilities.hoverProvider = false
      end
   },
   lua_ls = {
      settings = {
         Lua = {
            diagnostics = {
               globals = { "vim" },
            },
            format = {
               enable = true,
               defaultConfig = {
                  indent_style = "space",
                  indent_size = "2",
               }
            },
         },
      },
   },
   gopls = {
      settings = {
         analyses = {
            unusedparams = true,
         },
         staticcheck = true,
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
   },
   rust_analyzer = {
      settings = {
         ["rust-analyzer"] = {
            check = {
               enable = true,
               command = "clippy",
               features = "all",
            },
         },
      }
   },
   ts_ls = {
      settings = {
         typescript = {
            inlayHints = {
               includeInlayParameterNameHints = 'all',
               includeInlayParameterNameHintsWhenArgumentMatchesName = false,
               includeInlayFunctionParameterTypeHints = true,
               includeInlayVariableTypeHints = true,
               includeInlayVariableTypeHintsWhenTypeMatchesName = false,
               includeInlayPropertyDeclarationTypeHints = true,
               includeInlayFunctionLikeReturnTypeHints = true,
               includeInlayEnumMemberValueHints = true,
            }
         },
         javascript = {
            inlayHints = {
               includeInlayParameterNameHints = 'all',
               includeInlayParameterNameHintsWhenArgumentMatchesName = false,
               includeInlayFunctionParameterTypeHints = true,
               includeInlayVariableTypeHints = true,
               includeInlayVariableTypeHintsWhenTypeMatchesName = false,
               includeInlayPropertyDeclarationTypeHints = true,
               includeInlayFunctionLikeReturnTypeHints = true,
               includeInlayEnumMemberValueHints = true,
            }
         }
      }
   }
}

local function get_config(server_name)
   local config = server_configs[server_name] or { settings = {} }
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
   local lspconfig = require("lspconfig")
   local lsp_inlayhint = utils.safe_require{"lsp-inlayhints", ignore=true}
   local lsp_signature = utils.safe_require("lsp_signature")
   local lsp_status = utils.safe_require("lsp-status")
   local navbuddy = utils.safe_require("nvim-navbuddy")

   -- enable inlay hints
   if lsp_inlayhint then
      lsp_inlayhint.setup()
      -- vim.cmd([[
      --    augroup lsp_inlayhint
      --       autocmd!
      --       autocmd ColorScheme * highlight! link LspInlayHint Comment
      --    augroup END
      -- ]])
      -- vim.cmd([[doautocmd ColorScheme]])
   end

   -- LSP settings (for overriding per client)
   local handlers = {
      ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "single" }),
      ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help,
         { border = "single", focusable = false }),
   }

   vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('UserLspConfig', {}),
      callback = function(ev)
         -- mappings.
         local opts = { noremap = true, silent = true }
         vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
         vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
         vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist, opts)

         -- Buffer local mappings.
         -- See `:help vim.lsp.*` for documentation on any of the below functions
         local bufopts = { noremap = true, silent = true }
         vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
         vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
         vim.keymap.set("n", "gc", vim.lsp.buf.implementation, bufopts)
         vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
         vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, bufopts)
         vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
         -- vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
         -- vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, bufopts)
         -- vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
         -- vim.keymap.set('n', '<space>wl', function()
         --    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
         -- end, bufopts)
         vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, bufopts)
         vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, bufopts)
         vim.keymap.set('n', '<space>f', function()
            vim.lsp.buf.format { async = true }
         end, bufopts)

         local client = vim.lsp.get_client_by_id(ev.data.client_id)

         -- Signature help
         if lsp_signature then
            lsp_signature.on_attach({
               floating_window_above_cur_line = true,
               handler_opts = {
                  border = "single",
               },
            }, ev.buf)
         end

         -- Status help
         if lsp_status then
            lsp_status.on_attach(client)
         end

         if client.server_capabilities.documentSymbolProvider then
            if navbuddy then
               navbuddy.attach(client, ev.buf)
            end
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

         -- Inlay hints
         if client.server_capabilities.inlayHintProvider then
            if vim.lsp.inlay_hint then
               vim.lsp.inlay_hint.enable(true, {bufnr = ev.buf})
            else
               if lsp_inlayhint then
                  lsp_inlayhint.on_attach(client, ev.buf)
               end
            end
         end

         -- Disable highlight from lsp for TreeSitter
         client.server_capabilities.semanticTokensProvider = nil
      end,
   })


   -- Use a loop to conveniently call 'setup' on multiple servers and
   -- map buffer local keybindings when the language server attaches
   local servers = {
      "basedpyright",
      -- "pyright",
      "ruff",
      "gopls",
      "rust_analyzer",
      "bashls",
      "vimls",
      "lua_ls",
      "cmake",
      "clangd",
      "html",
      "cssls",
      "eslint",
      "ts_ls",
      "tailwindcss",
      "emmet_language_server",
      "yamlls",
      "ansiblels",
      "jsonls",
   }
   for _, server in ipairs(servers) do
      local config = get_config(server)
      lspconfig[server].setup {
         on_attach = config.on_attach,
         capabilities = config.capabilities,
         settings = config.settings,
         handlers = handlers,
      }
   end
end

return M
