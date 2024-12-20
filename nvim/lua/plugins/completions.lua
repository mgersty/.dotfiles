return {
    {
        "saghen/blink.cmp",
        dependencies = "rafamadriz/friendly-snippets",
        version = "v0.*",
        opts = {
            -- 'default' for mappings similar to built-in completion
            -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
            -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
            -- see the "default configuration" section below for full documentation on how to define
            -- your own keymap.
            keymap = { preset = "super-tab" },

            appearance = {
                use_nvim_cmp_as_default = true,
                nerd_font_variant = "mono",
            },

            -- default list of enabled providers defined so that you can extend it
            -- elsewhere in your config, without redefining it, due to `opts_extend`
            sources = {
                default = { "lsp", "path", "snippets", "buffer" },
                -- optionally disable cmdline completions
                -- cmdline = {},
            },

            -- experimental signature help support
            signature = { enabled = true },
        },
        -- allows extending the providers array elsewhere in your config
        -- without having to redefine it
        opts_extend = { "sources.default" },
    },
}
