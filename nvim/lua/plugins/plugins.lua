return {
    {
        "williamboman/mason.nvim",
        dependencies = {
            "williamboman/mason-lspconfig.nvim",
        },
        config = function()
            require("mason").setup()
            require("mason-lspconfig").setup()
        end
    },
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.8',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            require("telescope").setup({
                defaults = {
                    path_display = {
                        shorten = {
                            len = 3,
                            exclude = { 1, -1 },
                        },
                        truncate = true,
                    },
                    dynamic_preview_title = true,
                },
                pickers = {
                    find_files = {
                        theme = "dropdown",
                        hidden = true,
                        find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
                    },
                }
            })
            vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
            vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Fuzzy find recent files" })
            vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find string in cwd" })
        end
    },
    {
        "nvim-treesitter/nvim-treesitter",
        event = { "BufReadPre", "BufNewFile" },
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "java",
                    "bash",
                    "lua",
                    "vim",
                    "typescript",
                    "javascript",
                    "python",
                    "yaml",
                },
                sync_install = false,
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
                indent = {
                    enable = true,
                },
                -- context_commentstring = {
                --         enable = true,
                -- },
                refactor = {
                    smart_rename = { enable = true, keymaps = { smart_rename = "grr" } },
                },
            })
        end
    },
    {
        'stevearc/conform.nvim',
        config = function()
            require('conform').setup({
                formatters_by_ft = {
                    lua = { "stylua" }
                },
                format_on_save = {
                    lsp_fallback = true,
                    timeout_ms = 250
                }
            })
        end
    },

    {
        "tpope/vim-commentary"
    },
    {
        "catppuccin/nvim",
        name = "catppuccin"
    }
}
