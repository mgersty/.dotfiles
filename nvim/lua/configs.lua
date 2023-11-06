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
	auto_reload_on_write = true,
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
	},
	sync_install = false,
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
	indent = {
		enable = true,
	},
	context_commentstring = {
		enable = true,
	},
	refactor = {
		smart_rename = { enable = true, keymaps = { smart_rename = "grr" } },
	},
})
-- NVIM-DAP
require("dap.ext.vscode").load_launchjs()

local dap = require("dap")
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
		{ name = "vsnip" },
	},
	snippet = {
		expand = function(args)
			-- Comes from vsnip
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
-- NULL LS --

local null_ls = require("null-ls")

local formatting = null_ls.builtins.formatting
local code_actions = null_ls.builtins.code_actions
local diagnostics = null_ls.builtins.diagnostics

local sources = {
	--[[ formatting ]]
	formatting.eslint_d,
	formatting.prettier,
	formatting.stylua,
	-- formatting.google_java_format,
	formatting.black,
	-- formatting.xmlformat,

	--[[ code actions ]]
	code_actions.eslint_d,

	--[[ diagnostics ]]
	diagnostics.eslint_d,
}

local lsp_formatting = function(bufnr)
	vim.lsp.buf.format({
		filter = function(client)
			-- apply whatever logic you want (in this example, we'll only use null-ls)
			return client.name == "null-ls"
		end,
		bufnr = bufnr,
	})
end

-- if you want to set up formatting on save, you can use this as a callback
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local on_attach = function(client, bufnr)
	if client.supports_method("textDocument/formatting") then
		vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = augroup,
			buffer = bufnr,
			callback = function()
				lsp_formatting(bufnr)
			end,
		})
	end
end

null_ls.setup({
	sources = sources,
	on_attach = on_attach,
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

-- SYMBOLS OUTLINE:
require("symbols-outline").setup({
	autofold_depth = 1,
})

-- NOTIFY
 vim.notify = require("notify")

require("tokyonight").setup({
    terminal_colors=true,
    transparent=true
})


