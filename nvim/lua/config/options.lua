-- SETTINGS --
vim.opt.signcolumn = "no"
vim.cmd(":hi statusline guifg=white")

-- Select the theme and matching line-number palette here.
local theme = "dark" -- change to "light" when using a light colorscheme

local themes = {
    dark = {
        colorscheme = "tokyonight-night",
        active = "#FFFFFF",
        inactive = "#8A8A8A",
    },
    light = {
        colorscheme = "tokyonight-day",
        active = "#000000",
        inactive = "#555555",
    },
}

local selected_theme = themes[theme]
assert(selected_theme, "Unknown theme: " .. tostring(theme))

vim.cmd.colorscheme(selected_theme.colorscheme)

-- Line number colors. Relative numbers use LineNrAbove/LineNrBelow.
local function set_line_number_colors(active_color, inactive_color)
    local active = { fg = active_color, bg = "NONE", bold = true }
    local inactive = { fg = inactive_color, bg = "NONE" }

    vim.api.nvim_set_hl(0, "LineNr", inactive)
    vim.api.nvim_set_hl(0, "LineNrAbove", inactive)
    vim.api.nvim_set_hl(0, "LineNrBelow", inactive)
    vim.api.nvim_set_hl(0, "CursorLineNr", active)
end

local function apply_line_number_colors()
    set_line_number_colors(selected_theme.active, selected_theme.inactive)
end

apply_line_number_colors()

vim.api.nvim_create_autocmd("ColorScheme", {
    callback = apply_line_number_colors,
})

-- vim.cmd.colorscheme("rose-pine-main")
-- vim.cmd.colorscheme("rose-pine-dawn")
-- vim.cmd.colorscheme("nord")
-- vim.cmd.colorscheme("visual_studio_code")
-- vim.cmd.colorscheme("atom")
-- vim.cmd.colorscheme("material-deep-ocean")
-- vim.cmd.colorscheme("material-darker")
-- vim.cmd.colorscheme("iceberg")

vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.wrap = false
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 8
vim.opt.signcolumn = "no"
vim.opt.winborder = "rounded"
vim.diagnostic.config({ virtual_text = false })

-- INDENT SETTINGS --
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true

-- SEARCH SETTINGS --
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true

-- VISUAL SETTINGS --
vim.opt.termguicolors = true
vim.opt.signcolumn = "no"
vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,i:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175"
vim.opt.showmatch = true
vim.opt.matchtime = 2
vim.opt.cmdheight = 1
vim.opt.completeopt = "menuone,noinsert,noselect"
vim.opt.showmode = false
vim.opt.pumheight = 10
vim.opt.pumblend = 10
vim.opt.winblend = 0
vim.opt.conceallevel = 1
vim.opt.concealcursor = ""
vim.opt.lazyredraw = true
vim.opt.synmaxcol = 300

-- FILE HANDLING SETTINGS --
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand("~/.vim/undodir")
vim.g.netrw_liststyle = 3
vim.g.netrw_bufsettings = "noma nomod rnu nobl nowrap ro"

-- BEHAVIOR SETTINGS --
vim.opt.updatetime = 300
vim.opt.timeoutlen = 500
vim.opt.ttimeoutlen = 0
vim.opt.autoread = true
vim.opt.autowrite = true
vim.opt.hidden = true
vim.opt.errorbells = false
vim.opt.backspace = "indent,eol,start"
vim.opt.iskeyword:append("-")
vim.opt.path:append("**")
vim.opt.selection = "exclusive"
vim.opt.modifiable = true
vim.opt.encoding = "UTF-8"

-- DEBUG SETTINGS
vim.fn.sign_define("DapBreakpoint", { text = "󰱯", texthl = "Search", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped", { text = "󰱯", texthl = "", linehl = "", numhl = "" })

-- HELPFUL FUNCTIONS
local augroup = vim.api.nvim_create_augroup("UserConfig", {})

vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = { "lua", "python", "java" },
    callback = function()
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = { "typescript", "json", "xml" },
    callback = function()
        vim.opt_local.tabstop = 2
        vim.opt_local.shiftwidth = 2
    end,
})

vim.api.nvim_create_autocmd("TermOpen", {
    group = augroup,
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.signcolumn = "no"
    end,
})

vim.api.nvim_create_autocmd("TermClose", {
    group = augroup,
    callback = function()
        if vim.v.event.status == 0 then
            vim.api.nvim_buf_delete(0, {})
        end
    end,
})

vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"
vim.opt.wildignore:append({ "*.o", "*.obj", "*.pyc", "*.class", "*.jar" })
vim.opt.diffopt:append("linematch:60")
vim.opt.redrawtime = 10000
vim.opt.maxmempattern = 20000

local undodir = vim.fn.expand("~/.vim/undodir")
if vim.fn.isdirectory(undodir) == 0 then
    vim.fn.mkdir(undodir, "p")
end

vim.cmd([[highlight StatusLineBold gui=bold cterm=bold]])

local function git_branch()
    local branch = vim.fn.system("git branch --show-current 2>/dev/null | tr -d '\\n'")
    return branch ~= "" and "  " .. branch .. " " or ""
end

local function file_type()
    local ft = vim.bo.filetype
    local icons = {
        lua = "󰢱", python = "", json = "󰘦", markdown = "", vim = "",
        sh = "", bash = "", java = "󰅶", go = "", tsx = "󰛦", ts = "󰛦",
    }
    return ft == "" and "  " or (icons[ft] or ft)
end

local function lsp_status()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients == 0 then return "" end
    local names = {}
    for _, client in ipairs(clients) do table.insert(names, client.name) end
    return "LSP: " .. table.concat(names, ", ")
end

local function file_size()
    local size = vim.fn.getfsize(vim.fn.expand("%"))
    if size < 0 then return "" end
    if size < 1024 then return size .. "B " end
    if size < 1024 * 1024 then return string.format("%.1fK", size / 1024) end
    return string.format("%.1fM", size / 1024 / 1024)
end

local function mode_icon()
    local mode = vim.fn.mode()
    local modes = {
        n = "NORMAL", i = "INSERT", v = "VISUAL", V = "V-LINE", ["\22"] = "V-BLOCK",
        c = "COMMAND", s = "SELECT", S = "S-LINE", ["\19"] = "S-BLOCK",
        R = "REPLACE", r = "REPLACE", ["!"] = "SHELL", t = "TERMINAL",
    }
    return modes[mode] or "  " .. mode:upper()
end

_G.mode_icon = mode_icon
_G.git_branch = git_branch
_G.file_type = file_type
_G.file_size = file_size
_G.lsp_status = lsp_status

local function setup_dynamic_statusline()
    vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
        callback = function()
            vim.opt_local.statusline = table.concat({
                "  ", "%#StatusLineBold#", "%{v:lua.mode_icon()}", "%#StatusLine#",
                "  %f %h%m%r", "%{v:lua.file_type()}", "  ", "%{v:lua.git_branch()}",
                "  ", "%{v:lua.lsp_status()}", "%=", "%l:%c  %P ",
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
