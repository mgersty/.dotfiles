-- General
local opts = { noremap = true, silent = true }
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

vim.keymap.set('n', '<leader>q', ':quit!<CR>')
vim.keymap.set('n', '<leader>w', ':silent! write<CR>')
vim.keymap.set('n', '<leader>x', ':x!<CR>')

-- Completion menu: Tab/Shift-Tab cycle, Enter accepts the selection.
-- Each falls through to its normal behaviour when the popup isn't open.
vim.keymap.set("i", "<Tab>", function()
	return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>"
end, { expr = true, desc = "Next completion item" })

vim.keymap.set("i", "<S-Tab>", function()
	return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
end, { expr = true, desc = "Previous completion item" })
vim.keymap.set("i", "<CR>", function()
	-- 'noselect' means the popup can be open with nothing highlighted; in that
	-- case Enter should still break the line rather than silently dismiss.
	if vim.fn.pumvisible() == 1 and vim.fn.complete_info({ "selected" }).selected ~= -1 then
		return "<C-y>"
	end
	return "<CR>"
end, { expr = true, desc = "Accept completion item" })

-- Diagnostics
vim.keymap.set("n", "<leader>d", function()
	vim.diagnostic.setqflist()
	vim.cmd("copen")
end, { silent = true })

-- Language Servers --
vim.keymap.set("n", "<leader>fm", vim.lsp.buf.format, opts)
-- "gra" (Normal and Visual mode) is mapped to vim.lsp.buf.code_action()
-- "gri" is mapped to vim.lsp.buf.implementation()
-- "grn" is mapped to vim.lsp.buf.rename()
-- "grr" is mapped to vim.lsp.buf.references()
-- "grt" is mapped to vim.lsp.buf.type_definition()
-- "grx" is mapped to vim.lsp.codelens.run()
-- "gO" is mapped to vim.lsp.buf.document_symbol()
-- CTRL-S (Insert mode) is mapped to vim.lsp.buf.signature_help()
