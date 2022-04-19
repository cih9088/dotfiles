require("nvim-treesitter.configs").setup({
   highlight = {
      enable = true,
      use_languagetree = false,
      disable = function(lang, bufnr)
         return lang == "yaml" and vim.bo.filetype == "yaml.ansible"
      end,
   },
})
