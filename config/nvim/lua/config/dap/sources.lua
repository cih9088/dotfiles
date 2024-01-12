local M = {}

local dap = require('dap')

local is_windows = function()
   return vim.loop.os_uname().sysname:find("Windows", 1, true) and true
end


local function get_input(args)
   setmetatable(args, { __index = { default = nil, completion = nil, split = false } })
   local prompt, default, completion, split =
       args[1] or args.prompt,
       args[2] or args.default,
       args[3] or args.completion,
       args[4] or args.split

   local out
   vim.ui.input({ prompt = prompt, default = default, completion = completion }, function(value)
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
            return get_input { "Arguments: ", split = true }
         end,
         env = {},
         terminalKind = "integrated",
      }
   }
end

local function python_setup()
   local get_python_path = function()
      local venv_path = os.getenv('VIRTUAL_ENV') or os.getenv('CONDA_PREFIX')
      if venv_path then
         if is_windows() then
            return venv_path .. '\\Scripts\\python.exe'
         end
         return venv_path .. '/bin/python'
      else
         local handle = io.popen("bash -c 'type -P python'")
         local result = handle:read("*a")
         handle:close()
         -- get rid of new line
         return result:sub(1, -2)
      end
   end

   dap.adapters.python = function(cb, config)
      if config.request == 'attach' then
         local port = (config.connect or config).port
         local host = (config.connect or config).host or '127.0.0.1'
         cb({
            type = 'server',
            port = assert(port, '`connect.port` is required for a python `attach` configuration'),
            host = host,
            options = {
               source_filetype = 'python',
            }
         })
      else
         cb({
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
         name = 'Attach debugger to remote',
         connect = function()
            local host = get_input { "Host: ", default = "127.0.0.1" }
            local port = tonumber(get_input { "Port: ", default = "5678" })
            return { host = host, port = port }
         end,
      },
      {
         type = 'python',
         request = 'launch',
         name = "Launch file with arguments",
         pythonPath = get_python_path,
         program = function()
            return get_input {
               "File to execute: ",
               default = vim.fn.expand("%:p"),
               completion = "file",
            }
         end,
         args = function()
            return get_input { "Arguments: ", split = true }
         end,
         justMyCode = function()
            return get_input { "Enable JustMyCode? [y/n]: ", default = 'n' } == 'y'
         end,
      },
      {
         type = 'python',
         request = 'launch',
         name = "Launch pytest",
         module = "pytest",
         pythonPath = get_python_path,
         args = function()
            get_input { "Arguments: ", default = "-v -s .", split = true }
         end,
         justMyCode = function()
            return get_input { "Enable JustMyCode? [y/n]: ", default = 'n' } == 'y'
         end,
      }
   }
end

local function node_setup()
   dap.adapters["pwa-node"] = {
      type = "server",
      host = "localhost",
      port = "${port}",
      executable = {
         command = "node",
         args = {
            vim.fn.stdpath("data") .. '/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js',
            "${port}",
         },
      },
   }

   for _, language in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
      dap.configurations[language] = {
         {
            type = "pwa-node",
            request = "attach",
            name = "Attach debugger to existing `node --inspect` process",
            processId = function()
               return require 'dap.utils'.pick_process({ filter = "node" })
            end,
            cwd = "${workspaceFolder}",
            sourceMaps = true,
            resolveSourceMapLocations = { "${workspaceFolder}/**", "!**/node_modules/**" },
         },
         {
            type = "pwa-node",
            request = "launch",
            name = "Luanch node with debugger",
            runtimeExecutable = "npm",
            runtimeArgs = function()
               return get_input { "npm Arguments: ", default = "--inspect-brk run dev", split = true }
            end,
            autoAttachChildProcesses = true,
            cwd = "${workspaceFolder}",
            sourceMaps = true,
            resolveSourceMapLocations = { "${workspaceFolder}/**", "!**/node_modules/**" },
            protocol = "inspector",
            console = "integratedTerminal",
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
      }
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
   dap.configurations.rust = dap.configurations.cpp
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
            return get_input { "Arguments: ", split = true }
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
end

return M
