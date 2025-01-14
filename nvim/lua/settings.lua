local set = vim.opt

set.hlsearch = true
set.ignorecase = true
set.autoindent = true
set.expandtab = true
set.tabstop = 4
set.shiftwidth = 4
set.splitbelow = true
set.splitright = true
set.wrap = false
set.scrolloff = 5
set.fileencoding = "utf-8"
set.termguicolors = true
set.relativenumber = true
vim.o.timeout = true
vim.o.timeoutlen = 300
set.number = true
set.cursorline = true
set.rnu = true
vim.cmd.colorscheme("deep-space")
vim.cmd("set foldmethod=manual")
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    pattern = { "*" },
    command = [[%s/\s\+$//e]],
})

-- vim.cmd([[
--   highlight Normal guibg=none
--   highlight NonText guibg=none
--   highlight Normal ctermbg=none
--   highlight NonText ctermbg=none
-- ]])
