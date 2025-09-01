return {
    {
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        commit = 'b4da76be54691e854d3e0e02c36b0245f945c2c7',
        -- tag = "0.1.8",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-file-browser.nvim",
        },
        config = function()
            require("telescope").setup({
                -- defaults = {
                    -- preview = {
                    --     enabled = false
                    -- },
                    -- path_display = {
                    --     shorten = {
                    --         len = 3,
                    --         exclude = { 1, -1 },
                    --     },
                    --     truncate = true,
                    -- },
                    -- dynamic_preview_title = false,
                -- },

                pickers = {
                    find_files = {
                        previewer=false,
                        theme = "dropdown",
                        -- hidden = true,
                        -- find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
                    },
                },
            })
        end,
    },
}
