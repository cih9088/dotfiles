local M = {}


function M.setup()
   local dap, dapui = require("dap"), require("dapui")

   dapui.setup()

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
