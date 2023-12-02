return require("packer").startup(function(use)
	-- Dependency Management
	use("wbthomason/packer.nvim")
	use({
		"williamboman/mason.nvim",
		run = ":MasonUpdate", -- :MasonUpdate updates registry contents
	})

    -- Language Sever Dependencies
	use({
		"williamboman/mason-lspconfig.nvim",
	})
	use("neovim/nvim-lspconfig")
	use("mfussenegger/nvim-dap")
	use({ "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" } })
	use("mfussenegger/nvim-jdtls")
    use({'scalameta/nvim-metals', requires = { "nvim-lua/plenary.nvim" }})

    -- AutoCompletion
	use("hrsh7th/nvim-cmp")
    use("hrsh7th/cmp-nvim-lsp")

    -- Snippets
    use("hrsh7th/cmp-vsnip")
	use("hrsh7th/vim-vsnip")

	use("simrat39/symbols-outline.nvim")
	use("christoomey/vim-tmux-navigator")
	use({
		"nvim-telescope/telescope.nvim",
		tag = "0.1.2",
		requires = { { "nvim-lua/plenary.nvim" } },
	})
	use({
		"nvim-tree/nvim-tree.lua",
		requires = {
			"nvim-tree/nvim-web-devicons",
		},
	})
	use("nvim-telescope/telescope-ui-select.nvim")
	use("nvim-telescope/telescope-file-browser.nvim")
	use({
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
	})

    -- Commenting
    use("tpope/vim-commentary")
	use("JoosepAlviste/nvim-ts-context-commentstring")


    use("lukas-reineke/indent-blankline.nvim")
	use("folke/tokyonight.nvim")
	use("arcticicestudio/nord-vim")
	use({
		"nvim-lualine/lualine.nvim",
		requires = { "nvim-tree/nvim-web-devicons", opt = true },
	})
	use("rcarriga/nvim-notify")

    -- NVIM Utils
	use("nvim-lua/plenary.nvim")
end)
