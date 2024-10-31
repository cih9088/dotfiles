local M = {}

local dap = require('dap')
local utils = require('utils')

-- keep argument for input
local default_args = ""


local function get_input(args)
   setmetatable(args, { __index = { default = nil, completion = nil, split = false } })
   local prompt, default, completion, split =
       args[1] or args.prompt,
       args[2] or args.default,
       args[3] or args.completion,
       args[4] or args.split

   local out
   vim.ui.input({ prompt = prompt, default = default, completion = completion }, function(value)
      default_args = value
      if split then
         value = vim.split(value or "", " +")
      end
      out = value
   end)
   return out
end


local function bashdb_setup()
   dap.adapters.bashdb = {
      type = 'executable',
      command = 'bash-debug-adapter',
      name = 'bashdb',
   }

   dap.configurations.sh = {
      {
         type = 'bashdb',
         request = 'launch',
         name = "Launch file with arguments",
         showDebugOutput = true,
         pathBashdb = vim.fn.stdpath("data") .. '/mason/packages/bash-debug-adapter/extension/bashdb_dir/bashdb',
         pathBashdbLib = vim.fn.stdpath("data") .. '/mason/packages/bash-debug-adapter/extension/bashdb_dir',
         trace = true,
         file = "${file}",
         program = "${file}",
         cwd = '${workspaceFolder}',
         pathCat = "cat",
         pathBash = "bash",
         pathMkfifo = "mkfifo",
         pathPkill = "pkill",
         args = function()
            return get_input { "Arguments: ", default = default_args, split = true }
         end,
         env = {},
         terminalKind = "integrated",
      }
   }
end

local function python_setup()
   dap.adapters.python = function(callback, config)
      if config.request == 'attach' then
         local port = (config.connect or config).port
         local host = (config.connect or config).host or '127.0.0.1'
         callback({
            type = 'server',
            port = assert(port, '`connect.port` is required for a python `attach` configuration'),
            host = host,
            options = {
               source_filetype = 'python',
            }
         })
      else
         callback({
            type = 'executable',
            command = 'debugpy-adapter',
            options = {
               source_filetype = 'python',
            }
         })
      end
   end

   dap.configurations.python = {
      {
         type = "python",
         request = "attach",
         name = 'Attach to remote',
         connect = function()
            local host = get_input { "Host: ", default = "127.0.0.1" }
            local port = tonumber(get_input { "Port: ", default = "5678" })
            return { host = host, port = port }
         end,
         console = "integratedTerminal",
      },
      {
         type = 'python',
         request = 'launch',
         name = "Launch file with arguments",
         pythonPath = utils.get_python_path,
         program = function()
            return get_input {
               "File to execute: ",
               default = vim.fn.expand("%:p"),
               completion = "file",
            }
         end,
         args = function()
            return get_input { "Arguments: ", default = default_args, split = true }
         end,
         console = "integratedTerminal",
         justMyCode = function()
            return get_input { "Enable JustMyCode? [y/n]: ", default = 'y' } == 'y'
         end,
      },
      {
         type = 'python',
         request = 'launch',
         name = "Launch pytest",
         module = "pytest",
         pythonPath = utils.get_python_path,
         args = function()
            get_input { "Arguments: ", default = "-v -s .", split = true }
         end,
         console = "integratedTerminal",
         justMyCode = function()
            return get_input { "Enable JustMyCode? [y/n]: ", default = 'y' } == 'y'
         end,
      }
   }
end

local function node_setup()
   for _, adapter in ipairs({ "pwa-node", "pwa-chrome" }) do
      dap.adapters[adapter] = {
         type = "server",
         host = "localhost",
         port = "${port}",
         executable = {
            command = vim.fn.stdpath("data") .. '/mason/packages/js-debug-adapter/js-debug-adapter',
            args = { "${port}" },
         },
      }
   end

   for _, language in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
      dap.configurations[language] = {
         {
            type = "pwa-node",
            request = "attach",
            name = "Attach to existing `node --inspect` process",
            processId = function()
               return require 'dap.utils'.pick_process({ filter = "node" })
            end,
            cwd = "${workspaceFolder}",
            skipFiles = { "<node_internals>/**", "**/node_modules/**" },
            smartStep = true,
            resolveSourceMapLocations = { "${workspaceFolder}/**", "!**/node_modules/**" },
            sourceMaps = true,
         },
         {
            type = "pwa-node",
            request = "launch",
            name = "Luanch node",
            runtimeExecutable = "npm",
            runtimeArgs = function()
               return get_input { "npm Arguments: ", default = "--inspect-brk run dev", split = true }
            end,
            autoAttachChildProcesses = true,
            console = "integratedTerminal",
            cwd = "${workspaceFolder}",
            skipFiles = { "<node_internals>/**", "**/node_modules/**" },
            smartStep = true,
            resolveSourceMapLocations = { "${workspaceFolder}/**", "!**/node_modules/**" },
            sourceMaps = true,
         },
         {
            type = "pwa-chrome",
            request = "attach",
            name = "Attach to Chrome",
            port = function()
               return tonumber(get_input { "Port: ", default = "9222", split = false })
            end,
            webRoot = "${workspaceFolder}",
            skipFiles = { "<node_internals>/**", "**/node_modules/**" },
            smartStep = true,
            resolveSourceMapLocations = { "${workspaceFolder}/**", "!**/node_modules/**" },
            sourceMaps = true,
         },
         {
            type = "pwa-chrome",
            request = "launch",
            name = "Launch Chrome",
            url = function()
               return get_input { "URL: ", default = "http://localhost:3000", split = false }
            end,
            runtimeArgs = { "--incognito" },
            webRoot = "${workspaceFolder}",
            skipFiles = { "<node_internals>/**", "**/node_modules/**" },
            smartStep = true,
            resolveSourceMapLocations = { "${workspaceFolder}/**", "!**/node_modules/**" },
            sourceMaps = true,
         },
         language == "javascript" and {
            type = "pwa-node",
            request = "launch",
            name = "Launch current file in a node process",
            program = "${file}",
            cwd = "${workspaceFolder}",
         } or nil,
      }
   end
end


local function codelldb_setup()
   dap.adapters.codelldb = {
      type = 'server',
      port = '${port}',
      executable = {
         command = vim.fn.stdpath("data") .. '/mason/bin/codelldb',
         args = { '--port', '${port}' }
      },
      enrich_config = function(config, on_config)
         if config["cargo"] ~= nil then
            config = require("config.dap.rust_enrich").inspect(config)
         end
         on_config(config)
      end,
   }

   dap.configurations.cpp = {
      {
         type = "codelldb",
         request = "launch",
         name = "Launch",
         program = function()
            return get_input {
               "File to execute: ",
               default = vim.fn.getcwd() .. '/',
               completion = "file",
            }
         end,
         cwd = '${workspaceFolder}',
         stopOnEntry = false,
      },
   }
   dap.configurations.c = dap.configurations.cpp

   dap.configurations.rust = {
      {
         type = "codelldb",
         request = "launch",
         name = "Launch",
         args = function()
            return get_input { "Arguments: ", default = default_args, split = true }
         end,
         cwd = '${workspaceFolder}',
         stopOnEntry = false,
         cargo = {
            args = { "build" }
         },
      },
      {
         type = "codelldb",
         request = "launch",
         name = "Launch test",
         cwd = '${workspaceFolder}',
         stopOnEntry = false,
         cargo = {
            args = { "test", "--no-run" }
         },
         args = function()
            return get_input {
               "Test arguments to execute: ",
               default = default_args,
               split = true,
            }
         end
      },
   }
end

local function delve_setup()
   dap.adapters.go = {
      type = "server",
      port = '${port}',
      executable = {
         command = vim.fn.stdpath("data") .. '/mason/bin/dlv',
         args = { "dap", "-l", "127.0.0.1:${port}" }
      }
   }

   dap.configurations.go = {
      {
         type = "go",
         request = "launch",
         name = "Launch file with arguments",
         program = function()
            return get_input {
               "File to execute: ",
               default = vim.fn.expand("%:p"),
               completion = "file",
            }
         end,
         args = function()
            return get_input { "Arguments: ", default = default_args, split = true }
         end
      },
   }
end

function M.setup()
   bashdb_setup()
   python_setup()
   node_setup()
   codelldb_setup()
   delve_setup()

   -- Override default configurations with `launch.json`
   require("dap.ext.vscode").load_launchjs(".vscode/launch.json")
end

return M
