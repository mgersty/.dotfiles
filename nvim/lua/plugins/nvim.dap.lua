return {
    {
        "leoluz/nvim-dap-go",
        dependencies = { "mfussenegger/nvim-dap" },
        config = function()
            require("dap-go").setup()
        end,
    },
    { "rcarriga/nvim-dap-ui", dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" } },
}
