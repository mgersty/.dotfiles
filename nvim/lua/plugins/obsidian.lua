local PERSONAL_NOTES_HOME=os.getenv("PERSONAL_NOTES_HOME")

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
                path = PERSONAL_NOTES_HOME
,
            },
        },
        completion = { nvim_cmp = false, blink = true, create_new=false},
        note_id_func = function(title)
            if title ~= nil and title ~= "" then
                return title
            else
                -- Fallback to generated ID if no title provided
                return require("obsidian.builtin").zettel_id()
            end
        end,
    },
}
