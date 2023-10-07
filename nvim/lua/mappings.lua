--GLOBAL
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
local jdtls = require("jdtls")
vim.g.mapleader = " "

-- GENERAL MAPPINGS
map("n", "<C-H>", "<C-W>h", opts)
map("n", "<C-J>", "<C-W>j", opts)
map("n", "<C-L>", "<C-W>l", opts)
map("n", "<C-K>", "<C-W>k", opts)
map("n", "<C-S-i>", ":%!jq .", opts) --format json
map("n", "<C-S-d>", ":%bd|e#", opts) --format json

--NVIM-TREE
map("n", "<leader>e", ":NvimTreeToggle<CR>", opts)
map("n", "<leader>o", ":NvimTreeFocus<CR>", opts)
map("t", "<esc>", [[<C-\><C-n>]], {})

-- TELESCOPE
local telescope_builtins = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", telescope_builtins.find_files, {})
vim.keymap.set("n", "<leader>fg", telescope_builtins.live_grep, {})
vim.keymap.set("n", "<leader>fb", telescope_builtins.buffers, {})
vim.keymap.set("n", "<leader>fd", ":Telescope file_browser<CR>", {})
vim.keymap.set("n", "<leader>fh", telescope_builtins.help_tags, {})
vim.keymap.set("n", "<leader>fm", ":Telescope notify<CR>", {})

-- JDTLS
vim.keymap.set("n", "<A-o>", jdtls.organize_imports, opts)
vim.keymap.set("n", "<leader>tc", jdtls.test_class, opts)
vim.keymap.set("n", "<leader>tm", jdtls.test_nearest_method, opts)
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts, "Go to declaration")
vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts, "Go to definition")
vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts, "Go to implementation")

--DAP
vim.keymap.set("n", "<leader>bb", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", opts, "Set breakpoint")
vim.keymap.set("n", "<leader>br", "<cmd>lua require'dap'.clear_breakpoints()<cr>", opts, "Clear breakpoints")
vim.keymap.set("n", "<leader>bl", "<cmd>Telescope dap list_breakpoints<cr>", opts, "List breakpoints")
vim.keymap.set("n", "<leader>dc", "<cmd>lua require'dap'.continue()<cr>", opts, "Continue")
vim.keymap.set("n", "<leader>dj", "<cmd>lua require'dap'.step_over()<cr>", opts, "Step over")
vim.keymap.set("n", "<leader>dk", "<cmd>lua require'dap'.step_into()<cr>", opts, "Step into")
vim.keymap.set("n", "<leader>do", "<cmd>lua require'dap'.step_out()<cr>", opts, "Step out")
vim.keymap.set("n", "<leader>dd", "<cmd>lua require'dap'.disconnect()<cr>", opts, "Disconnect")
vim.keymap.set("n", "<leader>dt", "<cmd>lua require'dap'.terminate()<cr>", opts, "Terminate")
vim.keymap.set("n", "<leader>dr", "<cmd>lua require'dap'.repl.toggle()<cr>", opts, "Open REPL")
vim.keymap.set("n", "<leader>dl", "<cmd>lua require'dap'.run_last()<cr>", opts, "Run last")
vim.keymap.set("n", "<leader>di", function()
	require("dap.ui.widgets").hover()
end, opts, "Variables")
vim.keymap.set("n", "<leader>d?", function()
	local widgets = require("dap.ui.widgets")
	widgets.centered_float(widgets.scopes)
end, opts, "Scopes")
vim.keymap.set("n", "<leader>df", "<cmd>Telescope dap frames<cr>", opts, "List frames")
vim.keymap.set("n", "<leader>dh", "<cmd>Telescope dap commands<cr>", opts, "List commands")
vim.keymap.set("n", "<leader>duo", "<cmd>lua require'dapui'.open()<cr>", opts, "Open DAPUI")
vim.keymap.set("n", "<leader>duc", "<cmd>lua require'dapui'.close()<cr>", opts, "Close DAPUI")
