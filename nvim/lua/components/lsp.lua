-- LSP Setup
local servers = {
    "luals",
    "jls",
    "rustls",
    -- "intellij"
}

vim.lsp.enable(servers)

-- Don't pop the menu on every keystroke (:h ins-autocompletion); the LSP client
-- autotriggers on trigger characters instead -- see the LspAttach handler below.
vim.o.autocomplete = false
vim.o.completeopt = 'menuone,noselect,popup,fuzzy'

vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'Route LSP completions through the built-in completion menu',
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client:supports_method('textDocument/completion') then
        vim.notify("Autocompletion not supported :(")
      return
    end

    -- Servers advertise several trigger chars (":", "@", "<", ...); we only
    -- want the menu to appear after a dot.
    local provider = client.server_capabilities.completionProvider
    if provider then
      provider.triggerCharacters = { '.' }
    end

    -- Sets 'omnifunc', which the "o" source below pulls from. autotrigger fires
    -- completion on the trigger characters narrowed above.
    vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })

    -- LSP first, then buffer words as fallback, each source capped.
    vim.bo[args.buf].complete = 'o,.^5,w^5,b^5'
  end,
})
