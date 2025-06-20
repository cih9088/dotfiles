local M = {}

function M.safe_require(args)
   if type(args) ~= "table" then
      args = { module = args }
   end
   setmetatable(args, { __index = { ignore = false } })
   local module, ignore =
       args[1] or args.module,
       args[2] or args.ignore
   local ok, result = pcall(require, module)
   if not ok then
      if not ignore then
         vim.notify(string.format("Error requiring module: %s", module), vim.log.levels.ERROR)
      end
      return nil
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

-- see if the file exists
function M.file_exists(file)
   local f = io.open(file, "rb")
   if f then f:close() end
   return f ~= nil
end

-- get all lines from a file, returns an empty
-- list/table if the file does not exist
function M.lines_from(file)
   if not M.file_exists(file) then return {} end
   local lines = {}
   for line in io.lines(file) do
      lines[#lines + 1] = line
   end
   return lines
end

return M
