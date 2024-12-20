-- General Plugins
return {
    {
        "williamboman/mason.nvim",
        dependencies = {
            "williamboman/mason-lspconfig.nvim",
        },
        config = function()
            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "gopls",
                    "pyright",
                    "ruff",
                    "ts_ls",
                    "lua-ls",
                    "stylua",
                    "jdtls",
                },
            })
        end,
    },
    {
        "stevearc/conform.nvim",
        enable = false,
        config = function()
            require("conform").setup({
                formatters_by_ft = {
                    lua = { "stylua" },
                    python = { "ruff" },
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
        "stevearc/oil.nvim",
        ---@module 'oil'
        ---@type oil.SetupOpts
        opts = {},
        -- Optional dependencies
        dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
        config = function()
            require("oil").setup()
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
