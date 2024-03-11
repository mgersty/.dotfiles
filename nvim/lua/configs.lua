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
require("telescope").load_extension("notify")

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
        { name = "luasnip" }
	},

	snippet = {
		expand = function(args)
			require('luasnip').lsp_expand(args.body)
			-- vim.fn["vsnip#anonymous"](args.body)
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
require("ibl").setup()

--SNIPPETS
local ls = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()

ls.config.set_config({
	history=true,
	updateevents="TextChanged,TextChangedI",
	enable_autosnippets=true,
})

vim.keymap.set({"i"}, "<C-K>", function() ls.expand() end, {silent = true})
vim.keymap.set({"i", "s"}, "<C-L>", function() ls.jump( 1) end, {silent = true})
vim.keymap.set({"i", "s"}, "<C-J>", function() ls.jump(-1) end, {silent = true})

vim.keymap.set({"i", "s"}, "<C-E>", function()
	if ls.choice_active() then
		ls.change_choice(1)
	end
end, {silent = true})


-- WHICH KEY
local wk = require("which-key")
local telescope_builtins = require("telescope.builtin")
local jdtls = require("jdtls")

wk.register({
["<leader>"] ={
  f = {
    name = "find", -- optional group name
    f = { telescope_builtins.find_files, "find file" }, -- create a binding with label
    g = { telescope_builtins.live_grep, "find text" }, -- create a binding with label
    b = { telescope_builtins.buffers, "find buffer" }, -- create a binding with label
  },
  fl = {
    name = "find.lsp", -- optional group name
    s = { telescope_builtins.lsp_document_symbols, "find document symbols" }, -- create a binding with label
    r = { telescope_builtins.lsp_references, "find references"}, -- create a binding with label:
    i = { telescope_builtins.lsp_implementations, "find implementations"}, -- create a binding with label
    d = { telescope_builtins.lsp_definitions, "find definition"}, -- create a binding with label
    td = { telescope_builtins.lsp_type_definitions, "find type definition"}, -- create a binding with label
  },
  t = {
    name = "java.unit.test", -- optional group name
    m = { jdtls.test_metthod, "test nearest method" }, -- create a binding with label
    c = { jdtls.test_class, "test class"}, -- create a binding with label
  },
  e = {
    name = "java.refactor", -- optional group name
    em = { jdtls.extract_constant, "extract -> constant" }, -- create a binding with label
    ec = { jdtls.extract_method, "extract -> method"}, -- create a binding with label
    ev = { jdtls.extract_variable_all, "extract -> variable"}, -- create a binding with label
  },
}})



-- -- JDTLS
-- map("n", "<A-o>", jdtls.organize_imports, opts)
-- map("n", "<leader>tc", jdtls.test_class, opts)
-- map("n", "<leader>tm", jdtls.test_nearest_method, opts)
-- map("n", "<leader>ec", jdtls.extract_constant, opts)
-- map("n", "<leader>ev", jdtls.extract_variable_all, opts)
-- map("n", "<leader>em", jdtls.extract_method, opts)
-- map("n", "gD", vim.lsp.buf.declaration, opts, "Go to declaration")
-- map("n", "gd", vim.lsp.buf.definition, opts, "Go to definition")
-- map("n", "gi", vim.lsp.buf.implementation, opts, "Go to implementation")
-- map("n", "gI", jdtls.super_implementation, opts, "Go to Super Implementation")
-- map("n", "<space>ca", vim.lsp.buf.code_action, opts)
-- map("n", "<C-k>", vim.lsp.buf.signature_help, opts)
-- map("n", "K", vim.lsp.buf.hover, opts)
-- map("n", "<space>D", vim.lsp.buf.type_definition, opts)
-- map("n", "<space>rn", vim.lsp.buf.rename, opts)
-- map("n", "<space>em", jdtls.extract_method,opts)
