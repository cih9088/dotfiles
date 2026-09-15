local M = {}

local utils = require("utils")

function M.setup()
  local dap = require("dap")
  local dapui = utils.safe_require({"dapui", ignore = true })
  local dap_view = utils.safe_require({"dap-view", ignore = true})
  local dapvt = utils.safe_require("nvim-dap-virtual-text")

  vim.fn.sign_define("DapBreakpoint", { text = "●" })
  vim.fn.sign_define("DapStopped", { text = "" })

  if dapui then
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
  end

  if dap_view then
    dap_view.setup({
      winbar = {
        sections = {
          "scopes",
          "watches",
          "breakpoints",
          "threads",
          "exceptions",
          "repl",
          "console",
        },
        default_section = "scopes",
        controls = {
          enabled = true,
        },
      },
    })
  end

  if dapvt then
    dapvt.setup({ virt_text_pos = "eol" })
  end

  dap.listeners.after.event_initialized["dap_view_config"] = function()
    if dap_view then
      dap_view.open()
    elseif dapui then
      dapui.open()
    end
  end

  -- dap.listeners.after.event_initialized["dapui_config"] = function()
  --   dapui.open()
  -- end
  -- do not close dap ui to see error message
  -- dap.listeners.before.event_terminated["dapui_config"] = function()
  --   dapui.close()
  -- end
  -- dap.listeners.before.event_exited["dapui_config"] = function()
  --   dapui.close()
  -- end
end

return M
