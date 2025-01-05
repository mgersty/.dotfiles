--GLOBAL
local map = vim.keymap.set
local opts = { noremap = true, silent = true }
vim.g.mapleader = " "

-- GENERAL MAPPINGS
map("n", "<", ":bprevious<cr>", opts)
map("n", ">", ":bnext<cr>", opts)
map("n", "bda", ":%bd|e#|bd#<cr>", opts)
map("n", "FF", ":w<cr>", opts)
map("t", "<Esc>", "<C-\\><C-n>", opts)

--TELESCOPE
local telescope_builtins = require("telescope.builtin")
map("n", "<leader>ff", telescope_builtins.find_files, opts)
map("n", "<leader>fg", telescope_builtins.live_grep, opts)
map("n", "<leader>fb", telescope_builtins.buffers, opts)
map("n", "<leader>fd", ":Telescope file_browser<CR>")

--Language Servers
local jdtls = require("jdtls")
local neotest = require("neotest")
map("n", "<leader>la", vim.lsp.buf.code_action, opts)
map("n", "<leader>lr", telescope_builtins.lsp_references, opts)
map("n", "<leader>li", telescope_builtins.lsp_implementations, opts)
map("n", "<leader>ld", telescope_builtins.lsp_definitions, opts)
map("n", "<leader>ltd", telescope_builtins.lsp_type_definitions, opts)
map("n", "<leader>ln", vim.lsp.buf.rename, opts)
map("n", "<leader>lo", jdtls.organize_imports, opts)
map("n", "<leader>la", vim.lsp.buf.code_action, opts)
map("n", "<leader>tm", neotest.run.run, opts)
map("n", "<leader>tc", neotest.run.run, opts)
map("n", "<leader>fm", vim.lsp.buf.format, opts)

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    pattern = { "*" },
    callback = function()
        local save_cursor = vim.fn.getpos(".")
        pcall(function()
            vim.cmd([[%s/\s\+$//e]])
        end)
        vim.fn.setpos(".", save_cursor)
    end,
})
