local set = vim.opt

set.hlsearch = true
set.ignorecase = true

vim.o.tabstop = 2      -- A TAB character looks like 4 spaces
vim.o.expandtab = true -- Pressing the TAB key will insert spaces instead of a TAB character
vim.o.softtabstop = 2  -- Number of spaces inserted instead of a TAB character
vim.o.shiftwidth = 2   -- Number of spaces inserted when indenting

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
-- vim.o.shortmess = vim.o.shortmess:gsub("F", "")
vim.cmd.colorscheme("catppuccin")
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
vim.cmd("set foldmethod=manual")
-- set.foldexpr = "nvim_treesitter_nvim#foldexpr()"
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    pattern = { "*" },
    command = [[%s/\s\+$//e]],
})

