function _G.safe_require(module)
   local ok, result = pcall(require, module)
   if not ok then
      vim.notify(string.format("Error requiring: %s", module), vim.log.levels.ERROR)
      return ok
   end
   return result
end

function _G.dump(o)
   if type(o) == "table" then
      local s = "{ "
      for k, v in pairs(o) do
         if type(k) ~= "number" then
            k = '"' .. k .. '"'
         end
         s = s .. "[" .. k .. "] = " .. dump(v) .. ","
      end
      return s .. "} "
   else
      return tostring(o)
   end
end

