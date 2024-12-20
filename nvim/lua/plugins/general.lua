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
                    go = { "gofmt" },
                },
                format_on_save = {
                    lsp_fallback = true,
                    timeout_ms = 250,
                },
            })
        end,
    },
    {
        "stevearc/aerial.nvim",
        opts = {},
        -- Optional dependencies
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("aerial").setup()
        end,
    },
    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {},
    },
    { "tpope/vim-commentary" },
    { "catppuccin/nvim", name = "catppuccin" },
    { "mfussenegger/nvim-jdtls", dependencies = "mfussenegger/nvim-dap" },
    { "christoomey/vim-tmux-navigator" },
}
