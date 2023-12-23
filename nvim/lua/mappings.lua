--GLOBAL
local map = vim.keymap.set
local opts = { noremap = true, silent = true }
local jdtls = require("jdtls")
vim.g.mapleader = " "

-- GENERAL MAPPINGS
map("n", "<", ":bprevious<cr>",opts)
map("n", ">", ":bnext<cr>",opts)

--NVIM-TREE
map("n", "<leader>e", ":NvimTreeToggle<CR>", opts)
map("n", "<leader>o", ":NvimTreeFocus<CR>", opts)
map("t", "<esc>", [[<C-\><C-n>]], {})

-- TELESCOPE
local telescope_builtins = require("telescope.builtin")
map("n", "<leader>ff", telescope_builtins.find_files, {})
map("n", "<leader>fg", telescope_builtins.live_grep, {})
map("n", "<leader>fb", telescope_builtins.buffers, {})
map("n", "<leader>fh", telescope_builtins.help_tags, {})
map("n", "<leader>fn", ":Telescope notify<CR>", {})
map("n", "<leader>fm", telescope_builtins.marks, {})
map("n", "<leader>fls", telescope_builtins.lsp_document_symbols, {})
map("n", "<leader>flr", telescope_builtins.lsp_references, {})
map("n", "<leader>fli", telescope_builtins.lsp_implementations, {})
map("n", "<leader>fld", telescope_builtins.lsp_definitions, {})
map("n", "<leader>fltd",telescope_builtins.lsp_type_definitions, {})

-- JDTLS
map("n", "<A-o>", jdtls.organize_imports, opts)
map("n", "<leader>tc", jdtls.test_class, opts)
map("n", "<leader>tm", jdtls.test_nearest_method, opts)
map("n", "<leader>ec", jdtls.extract_constant, opts)
map("n", "<leader>ev", jdtls.extract_variable_all, opts)
map("n", "<leader>em", jdtls.extract_method, opts)
map("n", "gD", vim.lsp.buf.declaration, opts, "Go to declaration")
map("n", "gd", vim.lsp.buf.definition, opts, "Go to definition")
map("n", "gi", vim.lsp.buf.implementation, opts, "Go to implementation")
map("n", "gI", jdtls.super_implementation, opts, "Go to Super Implementation")
map("n", "<space>ca", vim.lsp.buf.code_action, opts)
map("n", "<C-k>", vim.lsp.buf.signature_help, opts)
map("n", "K", vim.lsp.buf.hover, opts)
map("n", "<space>D", vim.lsp.buf.type_definition, opts)
map("n", "<space>rn", vim.lsp.buf.rename, opts)
map("n", "<space>em", jdtls.extract_method,opts)

--DAP
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
map("n", "<leader>di", function()
	require("dap.ui.widgets").hover()
end, opts, "Variables")
map("n", "<leader>d?", function()
	local widgets = require("dap.ui.widgets")
	widgets.centered_float(widgets.scopes)
end, opts, "Scopes")
map("n", "<leader>df", "<cmd>Telescope dap frames<cr>", opts, "List frames")
map("n", "<leader>dh", "<cmd>Telescope dap commands<cr>", opts, "List commands")
map("n", "<leader>duo", "<cmd>lua require'dapui'.open()<cr>", opts,"Open DAPUI")
map("n", "<leader>duc", "<cmd>lua require'dapui'.close()<cr>", opts, "Close DAPUI")

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    pattern = {"*"},
    callback = function()
      local save_cursor = vim.fn.getpos(".")
      pcall(function() vim.cmd [[%s/\s\+$//e]] end)
      vim.fn.setpos(".", save_cursor)
    end,
})
