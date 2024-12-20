vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("lsp_attach_disable_ruff_hover", { clear = true }),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client == nil then
            return
        end
        if client.name == "ruff" then
            -- Disable hover in favor of Pyright
            client.server_capabilities.hoverProvider = false
        end
    end,
    desc = "LSP: Disable hover capability from Ruff",
})

return {
    "neovim/nvim-lspconfig",

    config = function()
        local on_attach = function(client, bufnr)
            if client.name == "yamlls" then
                client.server_capabilities.documentFormattingProvider = true
            end
            if client.name == "ruff_lsp" then
                --Disable hover in favor of Pyright
                client.server_capabilities.hoverProvider = false
            end
        end

        local lsp_flags = {
            -- This is the default in Nvim 0.7+
            debounce_text_changes = 150,
        }
        local capabilities = require("cmp_nvim_lsp").default_capabilities()

        local lspconfig = require("lspconfig")

        local servers = { "lua_ls", "ts_ls", "bashls", "lemminx", "yamlls", "pyright", "gopls", "ruff" }

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

        lspconfig.pyright.setup({
            settings = {
                pyright = {
                    -- Using Ruff's import organizer
                    disableOrganizeImports = true,
                },
                python = {
                    analysis = {
                        -- Ignore all files for analysis to exclusively use Ruff for linting
                        ignore = { "*" },
                    },
                },
            },
        })
    end,
}
