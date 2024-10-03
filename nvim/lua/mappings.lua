--GLOBAL
local map = vim.keymap.set
local opts = { noremap = true, silent = true }
vim.g.mapleader = " "

-- GENERAL MAPPINGS
map("n", "<", ":bprevious<cr>", opts)
map("n", ">", ":bnext<cr>", opts)
map("n", "bda", ":%bd|e#|bd#<cr>", opts)
map("t", "<Esc>", "<C-\\><C-n>", opts)

map("n", "<leader>e", ":NvimTreeToggle<CR>", opts)
map("n", "<leader>o", ":NvimTreeFocus<CR>", opts)

-- DIFF MAPPINGS
local isDiffMode = vim.opt.diff:get()

if isDiffMode then
    map("n", "<S-n>", "[c", opts)
    map("n", "n", "]c", opts)
end
local conform = require("conform")
vim.keymap.set({ "n", "v" }, "<leader>fm", function()
    conform.format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 1000,
    })
end, { desc = "Format file or range (in visual mode)" })

--TELESCOPE
telescope_builtins = require("telescope.builtin")

map("n", "<leader>ff", telescope_builtins.find_files, opts)
map("n", "<leader>fg", telescope_builtins.live_grep, opts)
map("n", "<leader>fb", telescope_builtins.buffers, opts)

local jdtls = require("jdtls")
--Language Servers
map("n", "<leader>la", vim.lsp.buf.code_action, opts)
map("n", "<leader>lr", telescope_builtins.lsp_references, opts)
map("n", "<leader>li", telescope_builtins.lsp_implementations, opts)
map("n", "<leader>ld", telescope_builtins.lsp_definitions, opts)
map("n", "<leader>ltd", telescope_builtins.lsp_type_definitions, opts)
map("n", "<leader>ln", vim.lsp.buf.rename, opts)
map("n", "<leader>lo", jdtls.organize_imports, opts)

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
