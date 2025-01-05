local HOME_DIR = os.getenv("HOME")
---@diagnostic disable-next-line: missing-fields
local client = vim.lsp.start_client({
    name = "educationalsp",
    cmd = { HOME_DIR .. "/sandbox/lsp.projects/rust_lsp/target/release/rust_lsp" },
})

if not client then
    vim.notify("shit went down")
end

vim.api.nvim_create_autocmd("FileType", {
    pattern = "*.txt",
    callback = function()
        vim.lsp.buf_attach_client(0, client)
    end,
})
