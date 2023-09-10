require("plugins.plugins-config")

vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

return require("packer").startup(function(use)
	use("wbthomason/packer.nvim")
	use("EdenEast/nightfox.nvim")
	use("arcticicestudio/nord-vim")
	use({
		"nvim-tree/nvim-tree.lua",
		requires = {
			"nvim-tree/nvim-web-devicons",
		},
	})
	use({
		"nvim-telescope/telescope.nvim",
		tag = "0.1.1",
		requires = { { "nvim-lua/plenary.nvim" } },
	})
	use("williamboman/mason.nvim")
	use("williamboman/mason-lspconfig.nvim")
	use("mfussenegger/nvim-dap")
	use("neovim/nvim-lspconfig")
	use("onsails/lspkind-nvim")
	use("hrsh7th/nvim-cmp")
	use("hrsh7th/cmp-nvim-lsp")
	use("saadparwaiz1/cmp_luasnip") --> Snippets source for nvim-cmp
	use("L3MON4D3/LuaSnip")
	use("jose-elias-alvarez/null-ls.nvim") --> inject lsp diagnistocs, formattings, code actions, and more ...
	use("tami5/lspsaga.nvim") --> icons for LSP diagnostics
	use("rcarriga/nvim-notify")
	use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" })
	use({
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
		end,
	})
	use("nvim-treesitter/nvim-treesitter-refactor")
	use("windwp/nvim-ts-autotag") -- auto complete html tags
	use("JoosepAlviste/nvim-ts-context-commentstring")
	use("lukas-reineke/indent-blankline.nvim")
	use({
		"nvim-lualine/lualine.nvim",
		requires = { "kyaxdani42/nvim-web-devicons", opt = true },
	})
	-- use({
	-- 	"romgrk/barbar.nvim",
	-- 	requires = { "kyaxdani42/nvim-web-devicons", opt = true },
	-- })
	use({
		"folke/trouble.nvim",
		requires = "nvim-tree/nvim-web-devicons",
		config = function()
			require("trouble").setup({})
		end,
	})
	-- use({
	-- 	"folke/which-key.nvim",
	-- 	config = function()
	-- 		vim.o.timeout = true
	-- 		vim.o.timeoutlen = 300
	-- 		require 'which-key'.setup({})
	-- 	end,
	-- })
	-- JAVA --
	use({ "mfussenegger/nvim-jdtls" })

	-- TYPESCRIPT --
	use("David-Kunz/jester")
end)
