---@diagnostic disable-next-line: missing-fields
local client = vim.lsp.start_client {
    name = "educationalsp",
    cmd = { "/home/gersty/sandbox/go.projects/go_lsp/lsp" },
}

if not client then
    vim.notify("shit went down")
end

vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
        vim.lsp.buf_attach_client(1, client)
    end
})
