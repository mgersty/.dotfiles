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

-- Debug Adapter Protocol
map("n", "<leader>bb", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", opts, "Set breakpoint")
map("n", "<leader>br", "<cmd>lua require'dap'.clear_breakpoints()<cr>", opts, "Clear breakpoints")
map("n", "<leader>bl", "<cmd>Telescope dap list_breakpoints<cr>", opts, "List breakpoints")
map("n", "<leader>dc", "<cmd>lua require'dap'.continue()<cr>", opts, "Continue")
map("n", "<leader>dj", "<cmd>lua require'dap'.step_over()<cr>", opts, "Step over")
map("n", "<leader>dk", "<cmd>lua require'dap'.step_into()<cr>", opts, "Step into")
map("n", "<leader>do", "<cmd>lua require'dap'.step_out()<cr>", opts, "Step out")
map("n", "<leader>dd", "<cmd>lua require'dap'.disconnect()<cr>", opts, "Disconnect")
map("n", "<leader>dt", "<cmd>lua require'dap'.terminate()<cr>", opts, "Terminate")
map("n", "<leader>dr", "<cmd>lua require'dap'.repl.toggle()<cr>", opts, "Open REPL")
map("n", "<leader>dl", "<cmd>lua require'dap'.run_last()<cr>", opts, "Run last")

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
