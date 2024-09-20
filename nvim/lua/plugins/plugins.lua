-- General Plugins
return {
    {
        "williamboman/mason.nvim",
        dependencies = {
            "williamboman/mason-lspconfig.nvim",
        },
        config = function()
            require("mason").setup()
            require("mason-lspconfig").setup()
        end,
    },
    {
        "stevearc/conform.nvim",
        enable = false,
        config = function()
            require("conform").setup({
                formatters_by_ft = {
                    lua = { "stylua" },
                },
                format_on_save = {
                    lsp_fallback = true,
                    timeout_ms = 250,
                },
            })
        end,
    },

    { "tpope/vim-commentary" },
    {
        "catppuccin/nvim",
        name = "catppuccin",
    },

    {
        "christoomey/vim-tmux-navigator",
    },
}
