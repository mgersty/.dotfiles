return {
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.8",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-file-browser.nvim",
        },
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
                    dynamic_preview_title = false,
                },
                pickers = {
                    find_files = {
                        theme = "ivy",
                        hidden = true,
                        find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
                    },
                },
            })
        end,
    },
}
