local utils = require("utils")

return {
   settings = {
      yaml = {
         schemaStore = {
            enable = false,
            -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
            url = "",
         },
         schemas = {
            ['https://json.schemastore.org/kustomization.json'] = 'kustomization.{yml,yaml}',
            ['https://raw.githubusercontent.com/docker/compose/master/compose/config/compose_spec.json'] =
            'docker-compose*.{yml,yaml}',
         },
      }
   },
   on_attach = function(client, bufnr)
      local bufname = vim.api.nvim_buf_get_name(bufnr)
      local filepath = vim.fn.fnamemodify(bufname, ":p")
      local ctr = 0

      for line in utils.iter_lines_from(filepath) do
         -- look for first 10 lines only
         if not line or ctr > 10 then
            break
         end

         if line:sub(1,#"apiVersion") == "apiVersion" then
            local kubernetes = utils.safe_require("kubernetes")
            if kubernetes then
               client.config.settings.yaml.schemas[kubernetes.yamlls_schema()] = "*"
            else
               client.config.settings.yaml.schemas["kubernetes"] = "*"
            end
            break
         end

         ctr = ctr + 1
      end
   end
}
