return {
    {
        "rcasia/neotest-java",
        ft = "java",
        dependencies = {
            "mfussenegger/nvim-jdtls",
            "mfussenegger/nvim-dap",     -- for the debugger
            "rcarriga/nvim-dap-ui",      -- recommended
            "theHamsta/nvim-dap-virtual-text", -- recommended
        },
    },
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
