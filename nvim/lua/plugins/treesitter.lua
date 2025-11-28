return {
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
                "go",
                "c",
                "cpp",
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
    end,
}
