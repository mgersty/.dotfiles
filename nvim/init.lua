-- Must be set before lazy.nvim loads, so plugin keymaps pick up the right leader.
vim.g.mapleader = " "

vim.lsp.log.set_level("debug")



-- Lazy vim setup
-- Bootstrap lazy.nvim itself, then hand it the specs in lua/plugins/. This has
-- to run before the requires below: config.lua sets the colorscheme, which only
-- exists once lazy has put tokyonight on the runtimepath.
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local out = vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    'https://github.com/folke/lazy.nvim.git',
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

vim.opt.rtp:prepend(lazypath)


require('lazy').setup({
  spec = { { import = 'plugins' } },
  -- Leftover plugins from the pre-reset config are still on disk; don't pull
  -- them back in on startup. Run :Lazy clean when you want them gone.
  install = { missing = true },
  checker = { enabled = false },
  change_detection = { notify = false },
})
-- lua/plugins/ is not required here: it only returns a lazy spec table, which
-- lazy.setup already imported above.
require("config")
require("keymap")
require("components")

