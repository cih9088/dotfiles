local M = {}

local dap = require('dap')

local is_windows = function()
   return vim.loop.os_uname().sysname:find("Windows", 1, true) and true
end

local function bashdb_setup()
   dap.adapters.bashdb = {
      type = 'executable';
      command = 'bash-debug-adapter';
      name = 'bashdb';
   }

   dap.configurations.sh = {
      {
         type = 'bashdb';
         request = 'launch';
         name = "Launch file";
         showDebugOutput = true;
         pathBashdb = vim.fn.stdpath("data") .. '/mason/packages/bash-debug-adapter/extension/bashdb_dir/bashdb';
         pathBashdbLib = vim.fn.stdpath("data") .. '/mason/packages/bash-debug-adapter/extension/bashdb_dir';
         trace = true;
         file = "${file}";
         program = "${file}";
         cwd = '${workspaceFolder}';
         pathCat = "cat";
         pathBash = "/bin/bash";
         pathMkfifo = "mkfifo";
         pathPkill = "pkill";
         args = {};
         env = {};
         terminalKind = "integrated";
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
         type = 'python';
         request = 'launch';
         name = "Launch file with arguments";
         pythonPath = get_python_path,
         program = function()
            local value = vim.fn.input("File to execute: ", vim.fn.expand('%:p'))
            return value
         end,
         args = function()
            local args_string = vim.fn.input('Arguments: ')
            return vim.split(args_string, " +")
         end;
         justMyCode = function()
            return vim.fn.input('Enable JustMyCode? [y/n]: ', 'n') == 'y'
         end,
      },
      {
         type = 'python';
         request = 'launch';
         name = "Launch pytest";
         module = "pytest",
         pythonPath = get_python_path,
         args = function()
            local args_string = vim.fn.input('Arguments: ', '.')
            local args = { "-v", "-s" }
            for k, v in pairs(vim.split(args_string, " +")) do table.insert(args, v) end
            return args
         end;
         justMyCode = function()
            return vim.fn.input('Enable JustMyCode? [y/n]: ', 'n') == 'y'
         end,
      }
   }
end

local function node2_setup()
   local dap = require('dap')

   dap.adapters.node2 = {
      type = 'executable',
      command = 'node-debug2-adapter',
   }

   dap.configurations.node2 = {
      {
         name = 'Node2: Launch',
         type = 'node2',
         request = 'launch',
         program = '${file}',
         cwd = vim.fn.getcwd(),
         sourceMaps = true,
         protocol = 'inspector',
         console = 'integratedTerminal',
      },
      {
         name = 'Node2: Attach to process',
         type = 'node2',
         request = 'attach',
         processId = require('dap.utils').pick_process,
      },
   }
end

function M.setup()
   bashdb_setup()
   python_setup()
   node2_setup()
end

return M
