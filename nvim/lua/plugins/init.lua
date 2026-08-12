-- General Plugins
return {
    {
        'nvim-treesitter/nvim-treesitter',
        lazy = false,
        build = ':TSUpdate'
    },
    "nvim-lua/plenary.nvim",
    {
        "pmizio/typescript-tools.nvim",
        dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
        opts = {},
    },
    "echasnovski/mini.icons",
    {
        "rachartier/tiny-inline-diagnostic.nvim",
        event = "VeryLazy", -- Or `LspAttach`
        priority = 1000,    -- needs to be loaded in first
        config = function()
            require('tiny-inline-diagnostic').setup({
                preset = "ghost"
            })
            vim.diagnostic.config({ virtual_text = false }) -- Only if needed in your configuration, if you already have native LSP diagnostics
        end
    },
    {
        "hedyhli/outline.nvim",
        lazy = true,
        cmd = { "Outline", "OutlineOpen" },
        keys = { -- Example mapping to toggle outline
            { "<leader>o", "<cmd>Outline<CR>", desc = "Toggle outline" },
        },
        config = function()
            require("outline").setup({
                outline_window = {
                    position = "left",
                    show_relative_numbers = true,
                    width = 100,
                },
                outline_items = {
                    show_symbol_details = true,
                },
                -- preview_window={
                --     auto_preview=true
                -- },
                symbols = {
                    -- icon_fetcher = function()
                    --     return ""
                    -- end,
                    icons = {
                        File = { icon = '󰈔', hl = 'Identifier' },
                        Module = { icon = '󰕳', hl = 'Include' },
                        Namespace = { icon = '', hl = 'Include' },
                        Package = { icon = '󰏖', hl = 'Include' },
                        Class = { icon = '', hl = 'Type' },
                        Method = { icon = '󰡱', hl = 'Function' },
                        Property = { icon = '', hl = 'Identifier' },
                        Field = { icon = '', hl = 'Identifier' },
                        Constructor = { icon = '', hl = 'Special' },
                        Enum = { icon = '', hl = 'Type' },
                        Interface = { icon = '', hl = 'Type' },
                        Function = { icon = '󰡱', hl = 'Function' },
                        Variable = { icon = '󰫧', hl = 'Constant' },
                        Constant = { icon = '', hl = 'Constant' },
                        String = { icon = '', hl = 'String' },
                        Number = { icon = '', hl = 'Number' },
                        Boolean = { icon = '', hl = 'Boolean' },
                        Array = { icon = '󰅪', hl = 'Constant' },
                        Object = { icon = '⦿', hl = 'Type' },
                        Key = { icon = '🔐', hl = 'Type' },
                        Null = { icon = 'NULL', hl = 'Type' },
                        EnumMember = { icon = '', hl = 'Identifier' },
                        Event = { icon = '🗲', hl = 'Type' },
                        Operator = { icon = '+', hl = 'Identifier' },
                        TypeParameter = { icon = '𝙏', hl = 'Identifier' },
                        Component = { icon = '󰅴', hl = 'Function' },
                        Fragment = { icon = '󰅴', hl = 'Constant' },
                        TypeAlias = { icon = ' ', hl = 'Type' },
                        Parameter = { icon = ' ', hl = 'Identifier' },
                        StaticMethod = { icon = ' ', hl = 'Function' },
                        Macro = { icon = ' ', hl = 'Function' },
                    },
                },
            })
        end,
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        ---@module "ibl"
        ---@type ibl.config
        opts = {},
        config = function()
            require("ibl").setup({
                indent = { char = "." },
                scope = { enabled = false },
            })
        end,
    },
    "tpope/vim-commentary",
    { "catppuccin/nvim",         name = "catppuccin" },
    { "mfussenegger/nvim-jdtls", dependencies = "mfussenegger/nvim-dap" },
    "christoomey/vim-tmux-navigator",
    "arcticicestudio/nord-vim",
    "cocopon/iceberg.vim",
    "olivercederborg/poimandres.nvim",
    "Mofiqul/adwaita.nvim",
    "kyazdani42/blue-moon",
    "kvrohit/substrata.nvim",
    "FrenzyExists/aquarium-vim",
    "Verf/deepwhite.nvim",
    "marko-cerovac/material.nvim",
    "nyoom-engineering/oxocarbon.nvim",
    "gregsexton/Atom",
    "tyrannicaltoucan/vim-deep-space",
    "rose-pine/neovim",
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        opts = {},
    },
    {
        "askfiy/visual_studio_code",
        config = function()
            require("visual_studio_code").setup({
                mode = "light",
            })
        end,
    },
    { "rakr/vim-one" },
}
