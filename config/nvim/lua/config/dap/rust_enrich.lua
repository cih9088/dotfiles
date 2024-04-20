local M = {}

---Parse the build metadata emitted by Cargo to find the executable to debug.
---@param cargo_metadata string[] An array of JSON strings emitted by Cargo.
---@return string|nil #Returns the path of the debuggable executable built by Cargo or nil if an executable cannot be found.
local function parse_cargo_metadata(cargo_metadata)
   -- Iterate backwards through the metadata list since the executable
   -- will likely be near the end (usually second to last)
   local possible_json_table = ""
   for i = 1, #cargo_metadata do
      local json_table = cargo_metadata[#cargo_metadata + 1 - i]

      -- Some metadata lines may be blank, skip those
      if string.len(json_table) ~= 0 then
         -- Each metadata line is a JSON table,
         -- parse it into a data structure we can work with
         json_table = vim.fn.json_decode(json_table)

         -- Our binary will be the compiler artifact with an executable defined
         if json_table["reason"] == "compiler-artifact" and json_table["executable"] ~= vim.NIL then
            if possible_json_table == "" then
               possible_json_table = json_table
            elseif json_table["target"]["kind"][1] == "lib" then
               possible_json_table = json_table
            end
         elseif possible_json_table ~= "" then
            return possible_json_table["executable"]
         end
      end
   end

   return nil
end

---Create the window and associated buffer and channel that will display build messages.
---@param configuration_name string Name of the debug configuration. The window will be large enough to display the whole name or the size defined in options, whichever is greater.
---@param window_options {enabled: boolean, width: number, height: number, border: string[]|string} Display options for the window.
---@return {buffer: number, window: number, channel: number}|nil #Returns the buffer that stores text for the window, the window itself, and a channel to communicate with the buffer. Returns nil on failure.
---@return string|nil #If an error occurs, return a string with the error message, otherwise returns nil.
local function create_window(configuration_name, window_options)
   -- Create the buffer that will receive Cargo's build messages
   local new_buffer = vim.api.nvim_create_buf(false, true)
   if new_buffer == 0 then
      return nil, "Failed to create build progress message buffer."
   end

   -- Create a window that will display build messages from the buffer
   local window_width = math.max(#configuration_name + 1, window_options.width)
   local window_height = window_options.height
   local new_window = vim.api.nvim_open_win(new_buffer, false, {
      relative = "editor",
      width = window_width,
      height = window_height,
      col = vim.api.nvim_get_option_value("columns", {}) - window_width - 2,
      row = vim.api.nvim_get_option_value("lines", {})
          - vim.api.nvim_get_option_value("cmdheight", {})
          - window_options.height
          - 3,
      border = window_options.border,
      style = "minimal",
   })
   if new_window == 0 then
      return nil, "Failed to create build progress message window."
   end

   -- Open a channel to the buffer, so we can send build messages to it
   local new_channel = vim.api.nvim_open_term(new_buffer, {})
   if new_channel == 0 then
      return nil, "Failed to create build progress message channel."
   end

   -- Let the user know what's going on
   vim.api.nvim_chan_send(new_channel, "Building for debug configuration:\r\n")
   vim.api.nvim_chan_send(new_channel, configuration_name .. "\r\n")
   vim.api.nvim_chan_send(new_channel, string.rep("=", window_width - 1) .. "\r\n")

   return { buffer = new_buffer, window = new_window, channel = new_channel }
end

---Destroy the build message window and associated buffer and channel.
---@param window_objects {buffer: number, window: number, channel: number}
local function destroy_window(window_objects)
   if window_objects.channel ~= 0 then
      vim.fn.chanclose(window_objects.channel)
      window_objects.channel = nil
   end

   if window_objects.window ~= 0 then
      vim.api.nvim_win_close(window_objects.window, true)
      window_objects.window = nil
   end

   if window_objects.buffer ~= 0 then
      vim.api.nvim_buf_delete(window_objects.buffer, { force = true })
      window_objects.buffer = nil
   end
end

---Run the Cargo task. I use the term 'build' but Cargo will simply execute
---whatever arguments are passed to it from the debug configuration. Usually
---this will be a build command but nothing stops the user from passing other
---args and potentially not ending up with a debuggable executable (E.g.: cargo check, cargo build on a lib, etc...)
---@param progress_window {buffer: number, window: number, channel: number}|nil Window objects used to display build progress (nil if the user doesn't want a progress window).
---@param final_config table A debug configuration received from nvim-dap (which loaded it from .vscode/launch.json).
local function run_cargo_task(progress_window, final_config)
   require("plenary.job")
       :new({
          command = "cargo",
          args = final_config.cargo.args,
          cwd = final_config.cwd,
          env = final_config.cargo.env,
          -- Cargo emits build progress messages to `stderr`
          -- We can send that output directly to the progress window
          on_stderr = progress_window and function(error, data)
             if not error then
                vim.schedule(function()
                   vim.api.nvim_chan_send(progress_window.channel, data .. "\r\n")
                   vim.api.nvim_win_set_cursor(
                      progress_window.window,
                      { vim.api.nvim_buf_line_count(progress_window.buffer), 1 }
                   )
                end)
             else
                vim.schedule(function()
                   vim.api.nvim_err_writeln("Cargo Inspector Error:\n" .. error)
                end)
             end
          end or nil,
          -- Cargo emits build metadata to `stdout`
          -- We buffer that data and process it here after the Cargo process terminates
          on_exit = function(job, exit_code)
             if exit_code == 0 then
                vim.schedule(function()
                   local executable_name = parse_cargo_metadata(job:result())
                   if executable_name ~= nil then
                      final_config.program = executable_name
                   else
                      final_config.program = ""
                      vim.schedule(function()
                         vim.notify(
                            "Cargo could not find an executable for debug configuration:\n"
                            .. final_config.name,
                            vim.log.levels.ERROR
                         )
                      end)
                   end
                end)
             else
                vim.schedule(function()
                   vim.notify(
                      "Cargo failed to build debug configuration:\n" .. final_config.name,
                      vim.log.levels.ERROR
                   )
                end)

                final_config.program = ""
             end
          end,
       })
       :start()
end

---Determine the Rust compiler's commit hash for the source map.
---@return string|nil #Returns the Rust compiler's commit hash or nil if it cannot be found.
local function get_commit_hash()
   local rust_hash = nil

   require("plenary.job")
       :new({
          command = "rustc",
          args = { "--version", "--verbose" },
          on_exit = function(job, exit_code)
             if exit_code == 0 then
                for _, line in pairs(job:result()) do
                   local start, finish = string.find(line, "commit-hash: ", 1, true)

                   if start ~= nil then
                      rust_hash = string.sub(line, finish + 1)
                   end
                end
             end
          end,
       })
       :sync()

   return rust_hash
end

---Determine the path to Rust's source code.
---@return string|nil #Returns the path to Rust's source code or nil if it cannot be found.
local function get_source_path()
   local source_path = nil

   require("plenary.job")
       :new({
          command = "rustc",
          args = { "--print", "sysroot" },
          on_exit = function(job, exit_code)
             if exit_code == 0 then
                local result = job:result()

                if #result > 0 then
                   source_path = job:result()[1]
                end
             end
          end,
       })
       :sync()

   return source_path
end

---Parse the `cargo` table of a DAP configuration, running any Cargo tasks
---defined in the `cargo` table then extracting the debuggable binary that
---results. Also fills in Rust specific debugging hints for LLDB.
---@param dap_config table A debug configuration received from nvim-dap (which loaded it from .vscode/launch.json).
---@param user_options table|nil The user's options for Cargo Inspector.
---@return table #Returns a DAP configuration with the debuggable binary and some additional Rust debugging hints for LLDB.
function M.inspect(dap_config, user_options)
   local final_config = vim.deepcopy(dap_config)

   -- Default options
   local options = {
      window = {
         enabled = true,
         width = 64,
         height = 12,
         border = "single",
      },
   }

   -- Extend default option with user's choices
   if user_options then
      options = vim.tbl_deep_extend("force", options, user_options)
   end

   -- Verify that Cargo exists
   if vim.fn.exepath("cargo") == "" then
      vim.notify("Cargo Inspector Error:\nCargo cannot be found.", vim.log.levels.ERROR)
      return final_config
   end

   -- Verify that the rust compiler exists
   if vim.fn.exepath("rustc") == "" then
      vim.notify("Cargo Inspector Error:\nRust compiler (rustc) cannot be found.", vim.log.levels.ERROR)
      return final_config
   end

   -- Instruct Cargo to emit build metadata as JSON
   if final_config.cargo.args then
      table.insert(final_config.cargo.args, "--message-format=json")
   else
      final_config.cargo.args = { "--message-format=json" }
   end

   -- Create build progress window if desired
   local progress_window = nil
   if options.window.enabled then
      local window_error = nil
      progress_window, window_error = create_window(final_config.name, options.window)

      if not progress_window then
         vim.api.nvim_err_writeln("Cargo Inspector Error:\n" .. window_error)
      end
   end

   -- Get the Rust compiler's commit hash for the source map
   local rust_hash = get_commit_hash()

   -- Get the Rust source code path for the source map
   local rust_source_path = get_source_path()

   -- Build a source map so that the user can step into Rust's standard
   -- library while debugging instead of getting a screen full of ASM
   if rust_source_path and rust_hash then
      if final_config.sourceMap == nil then
         final_config["sourceMap"] = {}
      end
      final_config.sourceMap["/rustc/" .. rust_hash .. "/"] = rust_source_path .. "/lib/rustlib/src/rust/"
   end

   -- Enable LLDB's support for Rust's built-in data types.
   if final_config.sourceLanguages == nil then
      final_config.sourceLanguages = { "rust" }
   else
      table.insert(final_config.sourceLanguages, "rust")
   end

   -- Run the Cargo task to get the path to the debuggable executable
   run_cargo_task(progress_window, final_config)

   -- Spin our wheels until Cargo is done
   repeat
      vim.wait(250, function()
         vim.cmd("redraw")
      end)
   until final_config.program ~= nil

   -- Destroy build progress window
   if progress_window then
      vim.schedule(function()
         destroy_window(progress_window)
         progress_window = nil
      end)
   end

   return final_config
end

return M

