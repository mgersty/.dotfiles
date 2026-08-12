-- Git branch.
--
-- The statusline re-evaluates every component on every redraw -- each cursor
-- move, each mode change -- so this must never shell out inline. Instead the
-- lookup is resolved asynchronously off BufEnter and memoised per directory;
-- git_branch() itself only reads an already-computed buffer variable.
local branch_cache = {} -- absolute dir -> branch name ("" when not a repo)

local function buf_dir(buf)
    local name = vim.api.nvim_buf_get_name(buf)
    if name == "" then
        return vim.uv.cwd()
    end
    return vim.fn.fnamemodify(name, ":p:h")
end

local function resolve_branch(buf)
    if not vim.api.nvim_buf_is_valid(buf) then
        return
    end
    -- Resolve against the buffer's own directory rather than the cwd, so the
    -- branch stays correct when editing files outside the current project.
    local dir = buf_dir(buf)
    if not dir or vim.fn.isdirectory(dir) == 0 then
        return
    end

    local cached = branch_cache[dir]
    if cached then
        vim.b[buf].git_branch = cached
        return
    end

    vim.system({ "git", "-C", dir, "branch", "--show-current" }, { text = true }, function(res)
        local branch = res.code == 0 and vim.trim(res.stdout or "") or ""
        vim.schedule(function()
            branch_cache[dir] = branch
            if vim.api.nvim_buf_is_valid(buf) then
                vim.b[buf].git_branch = branch
                vim.cmd("redrawstatus")
            end
        end)
    end)
end

local git_augroup = vim.api.nvim_create_augroup("StatuslineGit", { clear = true })

vim.api.nvim_create_autocmd("BufEnter", {
    group = git_augroup,
    callback = function(args)
        resolve_branch(args.buf)
    end,
})

-- A checkout can happen behind our back: in a :terminal, in another pane, or
-- via :!git. Drop the memo on the events that imply we may have missed one.
vim.api.nvim_create_autocmd({ "FocusGained", "DirChanged", "ShellCmdPost" }, {
    group = git_augroup,
    callback = function()
        branch_cache = {}
        resolve_branch(vim.api.nvim_get_current_buf())
    end,
})

local function git_branch()
    local branch = vim.b.git_branch
    if branch and branch ~= "" then
        return "  " .. branch .. " "
    end
    return ""
end

-- File type with icon
local function file_type()
    local ft = vim.bo.filetype
    local icons = {
        lua = "󰢱",
        python = "",
        json = "󰘦",
        markdown = "",
        vim = "",
        sh = "",
        bash = "",
        java = "󰅶",
        go = "",
        tsx = "󰛦",
        ts = "󰛦",
    }

    if ft == "" then
        return "  "
    end

    return (icons[ft] or ft)
end

-- LSP status
local function lsp_status()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients > 0 then
        local names = {}
        for _, client in ipairs(clients) do
            table.insert(names, client.name)
        end
        local client_list = table.concat(names, ", ")
        return "LSP: " .. client_list
    end
    return ""
end

-- File size
local function file_size()
    local size = vim.fn.getfsize(vim.fn.expand("%"))
    if size < 0 then
        return ""
    end
    if size < 1024 then
        return size .. "B "
    elseif size < 1024 * 1024 then
        return string.format("%.1fK", size / 1024)
    else
        return string.format("%.1fM", size / 1024 / 1024)
    end
end

-- Mode indicators with icons
local function mode_icon()
    local mode = vim.fn.mode()
    local modes = {
        n = "NORMAL",
        i = "INSERT",
        v = "VISUAL",
        V = "V-LINE",
        ["\22"] = "V-BLOCK", -- Ctrl-V
        c = "COMMAND",
        s = "SELECT",
        S = "S-LINE",
        ["\19"] = "S-BLOCK", -- Ctrl-S
        R = "REPLACE",
        r = "REPLACE",
        ["!"] = "SHELL",
        t = "TERMINAL",
    }
    return modes[mode] or "  " .. mode:upper()
end

_G.mode_icon = mode_icon
_G.git_branch = git_branch
_G.file_type = file_type
_G.file_size = file_size
_G.lsp_status = lsp_status

vim.cmd([[
  highlight StatusLineBold gui=bold cterm=bold
]])

-- Function to change statusline based on window focus
local function setup_dynamic_statusline()
    vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
        callback = function()
            vim.opt_local.statusline = table.concat({
                "  ",
                "%#StatusLineBold#",
                "%{v:lua.mode_icon()}",
                "%#StatusLine#",
                "  %f %h%m%r",
                "%{v:lua.file_type()}",
                "  ",
                "%{v:lua.git_branch()}",
                "  ",
                "%{v:lua.lsp_status()}",
                "%=",         -- Right-align everything after this
                "%l:%c  %P ", -- Line:Column and Percentage
            })
        end,
    })
    vim.api.nvim_set_hl(0, "StatusLineBold", { bold = true })

    vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
        callback = function()
            vim.opt_local.statusline = "  %f %h%m%r │ %{v:lua.file_type()} | %=  %l:%c   %P "
        end,
    })
end

setup_dynamic_statusline()
vim.cmd(":hi statusline guibg=NONE")
vim.cmd(":hi statusline guifg=white")
