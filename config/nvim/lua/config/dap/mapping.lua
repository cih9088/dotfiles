local M = {}

function M.setup()
   vim.keymap.set('n', '<leader>dc', function() require('dap').continue() end)
   vim.keymap.set('n', '<leader>dn', function() require('dap').step_over() end)
   vim.keymap.set('n', '<leader>di', function() require('dap').step_into() end)
   vim.keymap.set('n', '<leader>do', function() require('dap').step_out() end)
   vim.keymap.set('n', '<Leader>db', function() require('dap').toggle_breakpoint() end)
   vim.keymap.set('n', '<Leader>dB', function() require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: ')) end)
   -- vim.keymap.set('n', '<Leader>lp', function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)
   vim.keymap.set('n', '<Leader>dr', function() require('dap').repl.open() end)
   vim.keymap.set('n', '<Leader>dl', function() require('dap').run_last() end)
end

return M
