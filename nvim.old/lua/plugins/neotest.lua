return {

    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter",
            "nvim-neotest/neotest-python",
            "nvim-neotest/neotest-go",
            "marilari88/neotest-vitest",
            "nvim-contrib/nvim-ginkgo",
        },
        config = function()
            require("neotest").setup({
                adapters = {
                    require("neotest-python")({
                        args = { "-s" },
                    }),
                    require("neotest-go"),
                    require("neotest-vitest"),
                    require("nvim-ginkgo"),
                },
                output = {
                    enabled = true,
                },
            })
        end,
    },
}
