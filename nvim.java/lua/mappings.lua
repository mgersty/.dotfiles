--GLOBAL
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
vim.g.mapleader = " "

-- TELESCOPE
local telescope_builtins = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', telescope_builtins.find_files, {})
vim.keymap.set('n', '<leader>fg', telescope_builtins.live_grep, {})
vim.keymap.set('n', '<leader>fb', telescope_builtins.buffers, {})
--vim.keymap.set('n', '<leader>fb', ":Telescope file_browser<CR>", {})
vim.keymap.set('n', '<leader>fh', telescope_builtins.help_tags, {})


--LSP 
vim.keymap.set('v', "<space>ca", "<ESC><CMD>lua vim.lsp.buf.range_code_action()<CR>",{ noremap=true, silent=true, buffer=bufnr, desc = "Code actions" })
