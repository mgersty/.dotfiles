local HOME = os.getenv("HOME")

return {
    "obsidian-nvim/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = "markdown",
    ---@module 'obsidian'
    ---@type obsidian.config
    opts = {
        workspaces = {
            {
                name = "home",
                path = HOME .. '/google.drive/personal.vault'
,
            },
        },
        completion = { nvim_cmp = false, blink = true, create_new=false},
    },
}
