return require("packer").startup(function(use)
	-- Dependency Management
	use("wbthomason/packer.nvim")
	use({
		"williamboman/mason.nvim",
		run = ":MasonUpdate", -- :MasonUpdate updates registry contents
	})
	use({
		"williamboman/mason-lspconfig.nvim",
	})

    -- Language Sever Dependencies
	use("neovim/nvim-lspconfig")
	use("mfussenegger/nvim-jdtls")
	use("mfussenegger/nvim-dap")
	use({ "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" } })
    use({'scalameta/nvim-metals', requires = { "nvim-lua/plenary.nvim" }})

    -- AutoCompletion
	use("hrsh7th/nvim-cmp") -- nvim auto completion

    -- Snippets Engine???
	use("hrsh7th/vim-vsnip") -- VSCodes(LSP)'s snippet feature in vim nvim

    -- Snippet Sources
    use("hrsh7th/cmp-nvim-lsp") -- nvim-cmp source for neovim's built-in languagage-server
    use("hrsh7th/cmp-vsnip") -- nvim-cmp source for vim-vsnip
    use("hrsh7th/cmp-nvim-lsp-document-symbol") -- nvim-cmp source for autosuggesting the nearest symbol i.e. function, variable etc..
    use("hrsh7th/cmp-nvim-lsp-signature-help") -- nvim-cmp source for showing details about the specific method you are looking at.
    use("hrsh7th/cmp-nvim-lua") -- nvim-cmp source for Neovim's Lua API


    -- Telescope
	use({
		"nvim-telescope/telescope.nvim",
		tag = "0.1.2",
		requires = { { "nvim-lua/plenary.nvim" } },
	})
	use("nvim-telescope/telescope-ui-select.nvim")
	use("nvim-telescope/telescope-file-browser.nvim")

    -- NVIM Tree
    use({
		"nvim-tree/nvim-tree.lua",
		requires = {
			"nvim-tree/nvim-web-devicons",
		},
	})
    -- Tree Sitter
    use({
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
	})

    -- Commenting
    use("tpope/vim-commentary")
	use("JoosepAlviste/nvim-ts-context-commentstring")


    -- Appearence & Style
    use("lukas-reineke/indent-blankline.nvim")
	use("folke/tokyonight.nvim")
	use("arcticicestudio/nord-vim")
	use({
		"nvim-lualine/lualine.nvim",
		requires = { "nvim-tree/nvim-web-devicons", opt = true },
	})
	use("rcarriga/nvim-notify")

    -- Utils
    use("nvim-lua/plenary.nvim")
	use("christoomey/vim-tmux-navigator")
    use("dusans/vim-hardmode")
end)
