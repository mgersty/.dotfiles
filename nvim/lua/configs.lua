require("mason").setup()
require("mason-lspconfig").setup()

-- TELESCOPE
require("telescope").setup({
    defaults = {
        path_display = {
            shorten = {
                len = 3,
                exclude = { 1, -1 },
            },
            truncate = true,
        },
        dynamic_preview_title = true,
    },
    pickers = {
        find_files = {
            theme = "dropdown",
            hidden = true,
            find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
        },
    },
    extensions = {
        ["ui-select"] = {
            require("telescope.themes").get_dropdown({}),
        },
        ["luasnip"] = {
            require("telescope.themes").get_dropdown({}),
        },
    },
})
require("telescope").load_extension("notify")
require("telescope").load_extension("file_browser")
require("telescope").load_extension("luasnip")
require("telescope").load_extension("packer")
require("telescope").load_extension("ui-select")

--NVIM-TREE
require("nvim-tree").setup({
    update_focused_file = {
        enable = true,
    },
    -- sync_root_with_cwd = true,
    -- hijack_cursor = true,
    renderer = {
        group_empty = true,
    },
})

--TREE-SITTER
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
    -- 	enable = true,
    -- },
    refactor = {
        smart_rename = { enable = true, keymaps = { smart_rename = "grr" } },
    },
})
-- NVIM-DAP
local dap = require("dap")

-- Java Configurations
-- require("dap.ext.vscode").load_launchjs()

-- Scala Configurations
dap.configurations.scala = {
    {
        type = "scala",
        request = "launch",
        name = "RunOrTest",
        metals = {
            runType = "runOrTestFile",
            --args = { "firstArg", "secondArg", "thirdArg" }, -- here just as an example
        },
    },
    {
        type = "scala",
        request = "launch",
        name = "Test Target",
        metals = {
            runType = "testTarget",
        },
    },
}
-- General DAP Configs
dap.defaults.fallback.terminal_win_cmd = "tabnew"
vim.fn.sign_define("DapBreakpoint", { text = "󰱯", texthl = "Search", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped", { text = "󰱯", texthl = "", linehl = "", numhl = "" })

-- NVIM-DAP-UI
require("dapui").setup()

-- CMP AUTOCOMPLETION
local cmp = require("cmp")

cmp.setup({
    sources = {
        { name = "nvim_lsp" },
        { name = "nvim_lsp_signature_help" },
        { name = "nvim_lua" },
        { name = "luasnip" },
    },

    snippet = {
        expand = function(args)
            require("luasnip").lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            else
                fallback()
            end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            else
                fallback()
            end
        end, { "i", "s" }),
    }),
})
cmp.setup.cmdline({ "/", "?" }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = "buffer" },
        { name = "nvim_lsp_document_symbol" },
    },
})

-- FORMATTING
require("conform").setup({
    formatters_by_ft = {
        lua = { "stylua" },
        yaml = { { "prettierd", "prettier" } },
        json = { { "prettierd", "prettier" } },
        typescript = { { "prettierd", "prettier" } },
        xml = { "xmlformat" }
    },
    format_on_save = {
        -- I recommend these options. See :help conform.format for details.
        lsp_fallback = true,
        timeout_ms = 250,
    },
})

-- LUALINE Status Bar
local colors = {
    nord1 = "#3B4252",
    nord3 = "#4C566A",
    nord5 = "#E5E9F0",
    nord6 = "#ECEFF4",
    nord7 = "#8FBCBB",
    nord8 = "#88C0D0",
    nord13 = "#EBCB8B",
}

local customized_nord_theme = {
    normal = {
        a = { fg = colors.nord1, bg = colors.nord8, gui = "bold" },
        b = { fg = colors.nord1, bg = colors.nord6 },
        c = { fg = colors.nord5, bg = colors.nord3 },
    },
    insert = { a = { fg = colors.nord1, bg = colors.nord6, gui = "bold" } },
    visual = { a = { fg = colors.nord1, bg = colors.nord7, gui = "bold" } },
    replace = { a = { fg = colors.nord1, bg = colors.nord13, gui = "bold" } },
    inactive = {
        a = { fg = colors.nord1, bg = colors.nord8, gui = "bold" },
        b = { fg = colors.nord5, bg = colors.nord1 },
        c = { fg = colors.nord5, bg = colors.nord1 },
    },
}

require("lualine").setup({

    options = {
        theme = customized_nord_theme,
        globalstatus = false,
        component_separators = "|",
        section_separators = { left = " ", right = "" },
    },
    tabline = {
        lualine_a = { "mode" },
        lualine_b = { "buffers" },
        lualine_y = { "branch", "diff", "diagnostics" },
    },
    sections = {},
    inactive_sections = {},
})
-- SYMBOL OUTLINE
require("symbols-outline").setup({
    autofold_depth = 1,
})
-- NOTIFY
vim.notify = require("notify")

require("tokyonight").setup({
    terminal_colors = true,
    transparent = true,
})
require("ibl").setup()

--SNIPPETS
local ls = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()

ls.config.set_config({
    history = true,
    updateevents = "TextChanged,TextChangedI",
    enable_autosnippets = true,
})

-- WHICH KEY
local wk = require("which-key")
local telescope_builtins = require("telescope.builtin")

local jdtls = require("jdtls")
local dap = require("dap")
local telescope_dap = require("telescope").load_extension("dap")

wk.register({
    ["<leader>"] = {
        f = {
            name = "Find",                                                 -- optional group name
            f = { telescope_builtins.find_files, "find file" },            -- create a binding with label
            g = { telescope_builtins.live_grep, "find text" },             -- create a binding with label
            b = { telescope_builtins.buffers, "find buffer" },             -- create a binding with label
            d = { ":Telescope file_browser<CR>", "find file in browser" }, -- create a binding with label
            p = { ":Telescope packer<CR>", "find plugin" },                -- create a binding with label
            s = { ":Telescope luasnip<CR>", "find snippets" },             -- create a binding with label
            c = { telescope_builtins.git_commits, "find git commits" },
            m = { ":Telescope metals commands<CR>", "find metals commands" },
        },
        l = {
            name = "Language Server",                                                 -- optional group name
            a = { vim.lsp.buf.code_action, "show available code actions" },           -- create a binding with label
            s = { telescope_builtins.lsp_document_symbols, "find document symbols" }, -- create a binding with label
            r = { telescope_builtins.lsp_references, "find references" },             -- create a binding with label:
            i = { telescope_builtins.lsp_implementations, "find implementations" },   -- create a binding with label
            d = { telescope_builtins.lsp_definitions, "find definition" },            -- create a binding with label
            td = { telescope_builtins.lsp_type_definitions, "find type definition" }, -- create a binding with label
            n = { vim.lsp.buf.rename, "refactor -> rename" },
        },
        d = {
            name = "Debuggin",
            g = { dap.toggle_breakpoint, "toggle breakpoint" },
            bc = { dap.clear_breakpoint, "clear breakpoints" },
            bl = { telescope_dap.list_breakpoints, "list breakpoints" },
            c = { dap.continue, "start/continue" },
            j = { dap.step_over, "step over" },
            l = { dap.step_into, "step into" },
            k = { dap.step_out, "step out" },
            d = { dap.disconnect, "disconnect" },
            t = { dap.terminate, "terminate" },
            r = { dap.repl.toggle, "toggle repl" },
        },
        j = {
            name = "Java Language Server",                              -- optional group name
            o = { jdtls.organize_imports, "organize imports" },
            tm = { jdtls.test_nearest_method, "test nearest method" },  -- create a binding with label
            tc = { jdtls.test_class, "test class" },                    -- create a binding with label
            em = { jdtls.extract_constant, "extract -> constant" },     -- create a binding with label
            ec = { jdtls.extract_method, "extract -> method" },         -- create a binding with label
            ev = { jdtls.extract_variable_all, "extract -> variable" }, -- create a binding with label
        },
    },
})
