require("gitsigns").setup({
   on_attach = function(bufnr)
      local function buf_set_keymap(...)
         vim.api.nvim_buf_set_keymap(bufnr, ...)
      end

      local opts = { noremap = true, silent = true }

      -- Navigation
      buf_set_keymap("n", "]c", "<cmd>Gitsigns next_hunk<CR>", opts)
      buf_set_keymap("n", "[c", "<cmd>Gitsigns prev_hunk<CR>", opts)

      -- Actions
      buf_set_keymap("v", "<leader>ghs", "<cmd>Gitsigns stage_hunk<CR>", opts)
      buf_set_keymap("v", "<leader>ghu", "<cmd>Gitsigns undo_stage_hunk<CR>", opts)
   end,
})
