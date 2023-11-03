local M = {}

local dap = require('dap')

local is_windows = function()
   return vim.loop.os_uname().sysname:find("Windows", 1, true) and true
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
         name = "Launch file",
         showDebugOutput = true,
         pathBashdb = vim.fn.stdpath("data") .. '/mason/packages/bash-debug-adapter/extension/bashdb_dir/bashdb',
         pathBashdbLib = vim.fn.stdpath("data") .. '/mason/packages/bash-debug-adapter/extension/bashdb_dir',
         trace = true,
         file = "${file}",
         program = "${file}",
         cwd = '${workspaceFolder}',
         pathCat = "cat",
         pathBash = "/bin/bash",
         pathMkfifo = "mkfifo",
         pathPkill = "pkill",
         args = {},
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

   dap.adapters.python = {
      type = 'executable',
      command = 'debugpy-adapter',
   }

   dap.configurations.python = {
      {
         type = 'python',
         request = 'launch',
         name = "Launch file with arguments",
         pythonPath = get_python_path,
         program = function()
            local value = vim.fn.input("File to execute: ", vim.fn.expand('%:p'))
            return value
         end,
         args = function()
            local args_string = vim.fn.input('Arguments: ')
            return vim.split(args_string, " +")
         end,
         justMyCode = function()
            return vim.fn.input('Enable JustMyCode? [y/n]: ', 'n') == 'y'
         end,
      },
      {
         type = 'python',
         request = 'launch',
         name = "Launch pytest",
         module = "pytest",
         pythonPath = get_python_path,
         args = function()
            local args_string = vim.fn.input('Arguments: ', '.')
            local args = { "-v", "-s" }
            for k, v in pairs(vim.split(args_string, " +")) do table.insert(args, v) end
            return args
         end,
         justMyCode = function()
            return vim.fn.input('Enable JustMyCode? [y/n]: ', 'n') == 'y'
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
            name = "Luanch Nest.js",
            runtimeExecutable = "npm",
            runtimeArgs = {
               "run",
               "start:debug",
            },
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
         name = "Launch",
         type = "codelldb",
         request = "launch",
         program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
         end,
         cwd = '${workspaceFolder}',
         stopOnEntry = false,
      },
   }
   dap.configurations.c = dap.configurations.cpp
   dap.configurations.rust = dap.configurations.cpp
end

function M.setup()
   bashdb_setup()
   python_setup()
   node_setup()
   codelldb_setup()
end

return M
