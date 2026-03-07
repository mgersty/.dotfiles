-- General Plugins
return {
    {
        "pmizio/typescript-tools.nvim",
        dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
        opts = {},
    },

    { "nickjvandyke/opencode.nvim",
        version = "*", -- Latest stable release
        dependencies = {
            {
                -- `snacks.nvim` integration is recommended, but optional
                ---@module "snacks" <- Loads `snacks.nvim` types for configuration intellisense
                "folke/snacks.nvim",
                optional = true,
                opts = {
                    input = {}, -- Enhances `ask()`
                    picker = { -- Enhances `select()`
                        actions = {
                            opencode_send = function(...) return require("opencode").snacks_picker_send(...) end,
                        },
                        win = {
                            input = {
                                keys = {
                                    ["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
                                },
                            },
                        },
                    },
                },
            },
        },
        config = function()
            ---@type opencode.Opts
            vim.g.opencode_opts = {
                -- Your configuration, if any; goto definition on the type or field for details
            }

            vim.o.autoread = true -- Required for `opts.events.reload`

            -- Recommended/example keymaps
            vim.keymap.set({ "n", "x" }, "<C-a>", function() require("opencode").ask("@this: ", { submit = true }) end,
                { desc = "Ask opencode…" })
            vim.keymap.set({ "n", "x" }, "<C-x>", function() require("opencode").select() end,
                { desc = "Execute opencode action…" })
            vim.keymap.set({ "n", "t" }, "<C-.>", function() require("opencode").toggle() end,
                { desc = "Toggle opencode" })

            vim.keymap.set({ "n", "x" }, "go", function() return require("opencode").operator("@this ") end,
                { desc = "Add range to opencode", expr = true })
            vim.keymap.set("n", "goo", function() return require("opencode").operator("@this ") .. "_" end,
                { desc = "Add line to opencode", expr = true })

            vim.keymap.set("n", "<S-C-u>", function() require("opencode").command("session.half.page.up") end,
                { desc = "Scroll opencode up" })
            vim.keymap.set("n", "<S-C-d>", function() require("opencode").command("session.half.page.down") end,
                { desc = "Scroll opencode down" })

            -- You may want these if you use the opinionated `<C-a>` and `<C-x>` keymaps above — otherwise consider `<leader>o…` (and remove terminal mode from the `toggle` keymap)
            vim.keymap.set("n", "+", "<C-a>", { desc = "Increment under cursor", noremap = true })
            vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement under cursor", noremap = true })
        end,
    },
    { "echasnovski/mini.icons" },
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
                        Enum = { icon = "󰫲", hl = "Type" },
                        Struct = { icon = "", hl = "Structure" },
                        Object = { icon = "󰫶", hl = "Type" },
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
            require("ibl").setup({ indent = { char = "." } })
        end,
    },
    { "tpope/vim-commentary" },
    { "catppuccin/nvim",                 name = "catppuccin" },
    { "mfussenegger/nvim-jdtls",         dependencies = "mfussenegger/nvim-dap" },
    { "christoomey/vim-tmux-navigator" },
    { "arcticicestudio/nord-vim" },
    { "cocopon/iceberg.vim" },
    { "olivercederborg/poimandres.nvim" },
    { "Mofiqul/adwaita.nvim" },
    { "kyazdani42/blue-moon" },
    { "kvrohit/substrata.nvim" },
    { "FrenzyExists/aquarium-vim" },
    { "Verf/deepwhite.nvim" },
    { "marko-cerovac/material.nvim" },
    { "nyoom-engineering/oxocarbon.nvim" },
    { "gregsexton/Atom" },
    { "tyrannicaltoucan/vim-deep-space" },
    { "rose-pine/neovim" },
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
