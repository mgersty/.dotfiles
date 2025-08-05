-- General
local opts = { noremap = true, silent = true }
vim.g.mapleader = " "
vim.keymap.set("n", "<", ":bprevious<cr>", opts)
vim.keymap.set("n", ">", ":bnext<cr>", opts)
vim.keymap.set("n", "bda", ":%bd|e#|bd#<cr>", opts)
vim.keymap.set("n", "FF", ":w<cr>", opts)
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", opts)

-- Normal Mode Mappings
vim.keymap.set("n", "<leader>c", ":nohlsearch<CR>", { desc = "Clear search highlights" })

-- Center screen when jumping
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- Move lines up/down
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

vim.keymap.set('n', '<leader>o', ':update<CR> :source<CR>', {desc="shout out"})
vim.keymap.set('n', '<leader>w', ':write<CR>')
vim.keymap.set('n', '<leader>q', ':quit!<CR>')
vim.keymap.set('n', '<leader>x', ':x!<CR>')

-- Telescope
local telescope_builtins = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", telescope_builtins.find_files, opts)
vim.keymap.set("n", "<leader>fg", telescope_builtins.live_grep, opts)
vim.keymap.set("n", "<leader>fb", telescope_builtins.buffers, opts)
vim.keymap.set("n", "<leader>fd", ":Telescope file_browser<CR>")

-- Language Servers
local jdtls = require("jdtls")
local neotest = require("neotest")
vim.keymap.set("n", "grr", telescope_builtins.lsp_references, opts)
vim.keymap.set("n", "gri", telescope_builtins.lsp_implementations, opts)
vim.keymap.set("n", "grd", telescope_builtins.lsp_definitions, opts)
vim.keymap.set("n", "<leader>lo", jdtls.organize_imports, opts)
vim.keymap.set("n", "<leader>tm", neotest.run.run, opts)
vim.keymap.set("n", "<leader>tc", neotest.run.run, opts)
vim.keymap.set("n", "<leader>fm", vim.lsp.buf.format, opts)

-- Debug Adapter Protocol
-- vim.keymap.set("n", "<leader>bb", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", opts({ desc = "Set breakpoint" }))
-- vim.keymap.set("n", "<leader>br", "<cmd>lua require'dap'.clear_breakpoints()<cr>", opts({ desc = "Clear breakpoints" }))
-- vim.keymap.set("n", "<leader>bl", "<cmd>Telescope dap list_breakpoints<cr>", opts({ desc = "List breakpoints" }))
-- vim.keymap.set("n", "<leader>dc", "<cmd>lua require'dap'.continue()<cr>", opts({ desc = "Continue" }))
-- vim.keymap.set("n", "<leader>dj", "<cmd>lua require'dap'.step_over()<cr>", opts({ desc = "Step over" }))
-- vim.keymap.set("n", "<leader>dk", "<cmd>lua require'dap'.step_into()<cr>", opts({ desc = "Step into" }))
-- vim.keymap.set("n", "<leader>do", "<cmd>lua require'dap'.step_out()<cr>", opts({ desc = "Step out" }))
-- vim.keymap.set("n", "<leader>dd", "<cmd>lua require'dap'.disconnect()<cr>", opts({ desc = "Disconnect" }))
-- vim.keymap.set("n", "<leader>dt", "<cmd>lua require'dap'.terminate()<cr>", opts({ desc = "Terminate" }))
-- vim.keymap.set("n", "<leader>dr", "<cmd>lua require'dap'.repl.toggle()<cr>", opts({ desc = "Open REPL" }))
