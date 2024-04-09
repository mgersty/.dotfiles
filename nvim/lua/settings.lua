local set = vim.opt

set.hlsearch = true
set.ignorecase = true

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
vim.o.shortmess = vim.o.shortmess:gsub("F", "")
vim.cmd.colorscheme "dawnfox"
vim.cmd("set foldmethod=manual")

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    pattern = { "*" },
    command = [[%s/\s\+$//e]],
})
