local M = {}

function M.setup()
   vim.keymap.set('n', '<Plug>DAPContinue', function() require('dap').continue() end, { noremap = true, silent = true })
   vim.keymap.set('n', '<Plug>DAPStepOver', function() require('dap').step_over() end, { noremap = true, silent = true })
   vim.keymap.set('n', '<Plug>DAPStepInto', function() require('dap').step_into() end, { noremap = true, silent = true })
   vim.keymap.set('n', '<Plug>DAPStepOut', function() require('dap').step_out() end, { noremap = true, silent = true })
   vim.keymap.set('n', '<Plug>DAPToggleBreakPoint', function() require('dap').toggle_breakpoint() end,
      { noremap = true, silent = true })
   vim.keymap.set('n', '<Plug>DAPSetBreakPoint',
      function() require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: ')) end,
      { noremap = true, silent = true })
   vim.keymap.set('n', '<Plug>DAPreplOpen', function() require('dap').repl.open() end, { noremap = true, silent = true })
   vim.keymap.set('n', '<Plug>DAPRunLast', function() require('dap').run_last() end, { noremap = true, silent = true })

   vim.keymap.set('n', '<leader>dc', '<Plug>DAPContinue')
   vim.keymap.set('n', '<leader>dn', '<Plug>DAPStepOver')
   vim.keymap.set('n', '<leader>di', '<Plug>DAPStepInto')
   vim.keymap.set('n', '<leader>do', '<Plug>DAPStepOut')
   vim.keymap.set('n', '<Leader>db', '<Plug>DAPToggleBreakPoint')
   vim.keymap.set('n', '<Leader>dB', '<Plug>DAPSetBreakPoint')
   vim.keymap.set('n', '<Leader>dr', '<Plug>DAPreplOpen')
   vim.keymap.set('n', '<Leader>dl', '<Plug>DAPRunLast')
end

return M
