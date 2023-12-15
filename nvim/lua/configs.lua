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
})
require("telescope").load_extension("ui-select")
require("telescope").load_extension("file_browser")
require("telescope").load_extension("notify")

--NVIM-TREE
require("nvim-tree").setup({
    update_focused_file={
        enable=true
    },
    -- sync_root_with_cwd = true,
	-- hijack_cursor = true,
	renderer = {
		group_empty = true,
	},
	view = {
       float = {
            enable = true,
            -- open_win_config = {
            --     width=100,
            --     height=100
            -- }

        }
	}
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
require("dap.ext.vscode").load_launchjs()

-- Scala Configurations
-- dap.configurations.scala = {
--     {
--         type = "scala",
--         request = "launch",
--         name = "RunOrTest",
--         metals = {
--             runType = "runOrTestFile",
--             --args = { "firstArg", "secondArg", "thirdArg" }, -- here just as an example
--         },
--     },
--     {
--         type = "scala",
--         request = "launch",
--         name = "RunOrTest",
--         metals = {
--           runType = "runOrTestFile",
--           --args = { "firstArg", "secondArg", "thirdArg" }, -- here just as an example
--        }
--     }
-- }

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
        { name = "vsnip" }
	},

	snippet = {
		expand = function(args)
			vim.fn["vsnip#anonymous"](args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-d>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<CR>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		}),
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
cmp.setup.cmdline({'/','?'}, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' },
        { name = 'nvim_lsp_document_symbol' },
    }
})
--LUALINE Status Bar
local colors = {
  nord1  = '#3B4252',
  nord3  = '#4C566A',
  nord5  = '#E5E9F0',
  nord6  = '#ECEFF4',
  nord7  = '#8FBCBB',
  nord8  = '#88C0D0',
  nord13 = '#EBCB8B',
}

local customized_nord_theme = {
  normal = {
    a = { fg = colors.nord1, bg = colors.nord8, gui = 'bold' },
    b = { fg = colors.nord1, bg = colors.nord6 },
    c = { fg = colors.nord5, bg = colors.nord3 },
  },
  insert = { a = { fg = colors.nord1, bg = colors.nord6, gui = 'bold' } },
  visual = { a = { fg = colors.nord1, bg = colors.nord7, gui = 'bold' } },
  replace = { a = { fg = colors.nord1, bg = colors.nord13, gui = 'bold' } },
  inactive = {
    a = { fg = colors.nord1, bg = colors.nord8, gui = 'bold' },
    b = { fg = colors.nord5, bg = colors.nord1 },
    c = { fg = colors.nord5, bg = colors.nord1 },
  },
}

require("lualine").setup({

	options = {
		theme = customized_nord_theme,
		globalstatus = true,
		component_separators = "|",
	},
	winbar = {
		lualine_a = { 'mode' },
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
    terminal_colors=true,
    transparent=true
})
