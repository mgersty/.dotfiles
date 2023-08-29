require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"java",
		"bash",
		"lua",
		"vim",
		"help",
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
	autotag = {
		enable = true,
	},
	rainbow = {
		enable = true,
	},
	refactor = {
		smart_rename = { enable = true, keymaps = { smart_rename = "grr" } },
	},
})
