
local servers = {
  -- "angularls",
  "bashls",
  "clangd",
  "jsonls",
  "lemminx",
  "lua-ls",
  "pylsp",
  "ruff",
}

for _, server in ipairs(servers) do
  local ok, config = pcall(require, "lsp." .. server)
  if ok then
    vim.lsp.config(server, config)
  end
end

vim.lsp.enable(servers)

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
  end,
})

vim.opt.completeopt:append("noselect")
