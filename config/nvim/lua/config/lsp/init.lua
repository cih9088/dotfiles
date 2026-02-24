local M = {}
local this = ...

function M.setup()
  require(this .. ".diagnostic").setup()
  require(this .. ".mason").setup()
  require(this .. ".lspconfig").setup()
  -- require(this .. ".null-ls").setup()
  require(this .. ".nvim-cmp").setup()
end

return M
