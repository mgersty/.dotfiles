vim.lsp.log.set_level("debug")

require("core.lazy")
require("core.lsp")
require("config.options")
require("config.keymaps")

-- Toggle vim-table-mode on or off.
-- The command is guarded so this mapping is harmless if the plugin is disabled.
vim.keymap.set("n", "<leader>tm", function()
  if vim.fn.exists(":TableModeToggle") == 2 then
    vim.cmd("TableModeToggle")
  else
    vim.notify("vim-table-mode is not available", vim.log.levels.WARN)
  end
end, { desc = "Toggle table mode" })
