require("plugins.plugins-config.nvim-tree")
require("plugins.plugins-config.barbar")
require("plugins.plugins-config.lualine")
require("plugins.plugins-config.mason")
require("plugins.plugins-config.treesitter")
-- require("plugins.plugins-config.java")
-- INDENTATION GUIDE
require("indent_blankline").setup({
	-- for example, context is off by default, use this to turn it on
	show_current_context = true,
	show_current_context_start = true,
})
-- TELESCOPE
require("telescope").setup({
	defaults = {
		file_ignore_patterns = { "node_modules" },
	},
})

require("jester").setup({
	path_to_jest_run = "npx jest",
})
