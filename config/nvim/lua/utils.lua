local M = {}

function M.safe_require(module)
   local ok, result = pcall(require, module)
   if not ok then
      vim.notify(string.format("Error requiring module: %s", module), vim.log.levels.ERROR)
      return ok
   end
   return result
end

function M.dump(o)
   if type(o) == "table" then
      local s = "{ "
      for k, v in pairs(o) do
         if type(k) ~= "number" then
            k = '"' .. k .. '"'
         end
         s = s .. "[" .. k .. "] = " .. M.dump(v) .. ","
      end
      return s .. "} "
   else
      return tostring(o)
   end
end


function M.is_windows()
   return vim.loop.os_uname().sysname:find("Windows", 1, true) and true
end

function M.get_python_path()
   local venv_path = os.getenv('VIRTUAL_ENV') or os.getenv('CONDA_PREFIX')
   if venv_path then
      if M.is_windows() then
         return venv_path .. '\\Scripts\\python.exe'
      end
      return venv_path .. '/bin/python'
   else
      local handle = io.popen("bash -c 'type -P python'")
      local result = nil
      if handle == nil then
         vim.notify("Error getting python path", vim.log.levels.ERROR)
      else
         result = handle:read("*a")
         -- get rid of new line
         result = result:sub(1, -2)
         handle:close()
      end
      return result
   end
end

return M
