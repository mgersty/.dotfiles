-- GENERAL --
vim.opt.number = true         -- Line numbers
vim.opt.relativenumber = true -- Relative line numbers
vim.opt.cursorline = true     -- Highlight current line
vim.opt.wrap = false          -- Don't wrap lines
vim.opt.scrolloff = 10        -- Keep 10 lines above/below cursor
vim.opt.sidescrolloff = 8     -- Keep 8 columns left/right of cursor
vim.opt.signcolumn = "yes"
vim.opt.winborder = "rounded"

-- DIAGNOSTIC --
-- virtual_text is owned by tiny-inline-diagnostic, which disables it in favour
-- of its own renderer. Configure it there, not here.

-- INDENT --
vim.opt.tabstop = 2        -- Tab width
vim.opt.shiftwidth = 2     -- Indent width
vim.opt.softtabstop = 2    -- Soft tab stop
vim.opt.expandtab = true   -- Use spaces instead of tabs
vim.opt.smartindent = true -- Smart auto-indenting
vim.opt.autoindent = true  -- Copy indent from current line

-- SEARCH --
vim.opt.ignorecase = true -- Case insensitive search
vim.opt.smartcase = true  -- Case sensitive if uppercase in search
vim.opt.hlsearch = false  -- Don't highlight search results

-- VISUAL --
vim.cmd.colorscheme("tokyonight-night")
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
vim.opt.termguicolors = true -- Enable 24-bit colors
vim.opt.showmatch = true     -- Highlight matching brackets
vim.opt.matchtime = 2        -- How long to show matching bracket
vim.opt.cmdheight = 1        -- Command line height
vim.opt.showmode = false     -- Don't show mode in command line
vim.opt.pumheight = 10       -- Popup menu height
vim.opt.pumblend = 10        -- Popup menu transparency
vim.opt.winblend = 0         -- Floating window transparency
vim.opt.conceallevel = 1     -- Don't hide markup
vim.opt.concealcursor = ""   -- Don't hide cursor line markup
vim.opt.lazyredraw = true    -- Don't redraw during macros
vim.opt.synmaxcol = 300      -- Syntax highlighting limit
vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,i:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175"
vim.opt.redrawtime = 10000
vim.opt.maxmempattern = 20000


-- BEHAVIOR
vim.opt.updatetime = 300        -- CursorHold delay / swapfile write
vim.opt.timeoutlen = 500        -- Key timeout duration
vim.opt.ttimeoutlen = 0         -- Key code timeout
vim.opt.autowrite = true        -- Auto save
vim.opt.errorbells = false      -- No error bells
vim.opt.iskeyword:append("-")   -- Treat dash as part of word
vim.opt.path:append("**")       -- include subdirectories in search
vim.opt.selection = "exclusive" -- Selection behavior
