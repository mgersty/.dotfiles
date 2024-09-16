return {

    {
        'L3MON4D3/LuaSnip',
        dependencies = {
            'saadparwaiz1/cmp_luasnip',
            'rafamadriz/friendly-snippets'
        }
    },

    {
        "hrsh7th/nvim-cmp",
        config = function()
            local cmp = require("cmp")
            require('luasnip.loaders.from_vscode').lazy_load()
            cmp.setup({
                sources = {
                    { name = "nvim_lsp" },
                    { name = "nvim_lsp_signature_help" },
                    { name = "nvim_lua" },
                    { name = "luasnip" },
                },

                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                mapping = cmp.mapping.preset.insert({
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping.abort(),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
                }),
            })
        end
    },
    {                                           -- SNIPPET SOURCES
        "hrsh7th/cmp-nvim-lsp",                 -- nvim-cmp source for neovim's built-in languagage-server
        "hrsh7th/cmp-nvim-lsp-document-symbol", -- nvim-cmp source for autosuggesting the nearest symbol i.e. function, variable etc..
        "hrsh7th/cmp-nvim-lsp-signature-help",  -- nvim-cmp source for showing details about the specific method you are looking at.
        "hrsh7th/cmp-nvim-lua"                  -- nvim-cmp souce for Neovim's Lua API
    }
}
