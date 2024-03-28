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
map("n", "<leader>duo", "<cmd>lua require'dapui'.open()<cr>", opts, "Open DAPUI")
map("n", "<leader>duc", "<cmd>lua require'dapui'.close()<cr>", opts, "Close DAPUI")

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
