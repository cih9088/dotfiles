local M = {}

local function python_setup()
   local dap = require('dap')

   dap.adapters.python = {
      type = 'executable',
      command = 'debugpy-adapter',
   }

   dap.configurations.python = {
      {
         type = 'python';
         request = 'launch';
         name = "Launch file";
         program = function()
            local value = vim.fn.input("file to execute: ", vim.fn.expand('%:p'))
            return value
         end,
         args = function()
           local args = {}
           local i = 1
           while true do
               local arg = vim.fn.input("Argument [" .. i .. "]: ")
               if arg == '' then
                   break
               end
               args[i] = arg
               i = i + 1
           end
           return args
         end,
         justMyCode = function()
           return vim.fn.input('justMyCode? [y/n]: ') == 'y'
         end,
      },
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
   python_setup()
   node2_setup()
end

return M
