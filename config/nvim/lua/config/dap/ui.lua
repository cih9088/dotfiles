local M = {}

function M.setup()
  local dap, dapui = require("dap"), require("dapui")

  dapui.setup({
    layouts = {
      {
        elements = {
          {
            id = "scopes",
            size = 0.25,
          },
          {
            id = "breakpoints",
            size = 0.25,
          },
          {
            id = "stacks",
            size = 0.25,
          },
          {
            id = "watches",
            size = 0.25,
          },
        },
        position = "left",
        size = 0.2,
      },
      {
        elements = {
          {
            id = "repl",
            size = 0.5,
          },
          {
            id = "console",
            size = 0.5,
          },
        },
        position = "bottom",
        size = 0.2,
      },
    },
  })

  dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
  end
  -- do not close dap ui to see error message
  -- dap.listeners.before.event_terminated["dapui_config"] = function()
  --   dapui.close()
  -- end
  -- dap.listeners.before.event_exited["dapui_config"] = function()
  --   dapui.close()
  -- end
end

return M
