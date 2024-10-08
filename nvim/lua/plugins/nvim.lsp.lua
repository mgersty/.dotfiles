return {
    "neovim/nvim-lspconfig",

    config = function()
        local on_attach = function(client, bufnr)
            if client.name == "yamlls" then
                client.server_capabilities.documentFormattingProvider = true
            end
        end

        local lsp_flags = {
            -- This is the default in Nvim 0.7+
            debounce_text_changes = 150,
        }
        local capabilities = require("cmp_nvim_lsp").default_capabilities()

        local lspconfig = require("lspconfig")

        local servers = { "lua_ls", "ts_ls", "bashls", "lemminx", "yamlls", "pyright" }

        for _, lsp in ipairs(servers) do
            lspconfig[lsp].setup({
                settings = {
                    Lua = {
                        diagnostics = {
                            -- Get the language server to recognize the `vim` global
                            globals = { "vim" },
                            disable = { "lowercase-global" },
                        },
                    },
                },
                on_attach = on_attach,
                flags = lsp_flags,
                capabilities = capabilities,
            })
        end
    end

}
