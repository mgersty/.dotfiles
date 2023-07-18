return require('packer').startup(function(use)
	-- Packer can manage itself
	use 'wbthomason/packer.nvim'
	use {
		"williamboman/mason.nvim",
		run = ":MasonUpdate" -- :MasonUpdate updates registry contents
	}
	use {
		"williamboman/mason-lspconfig.nvim",
	}
    use 'mfussenegger/nvim-dap'
	use 'mfussenegger/nvim-jdtls'
	use 'nvim-lua/plenary.nvim'
	use 'neovim/nvim-lspconfig'
    use 'hrsh7th/nvim-cmp'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-vsnip'
    use 'hrsh7th/vim-vsnip'
    use {
		'nvim-telescope/telescope.nvim', tag = '0.1.2',
		requires = { { 'nvim-lua/plenary.nvim' } }
	}
    use ({
        "nvim-tree/nvim-tree.lua",
        requires = {
            "nvim-tree/nvim-web-devicons"
        }
    })
    use 'nvim-telescope/telescope-ui-select.nvim'
    use 'nvim-telescope/telescope-file-browser.nvim'
	use {
		'nvim-treesitter/nvim-treesitter',
		run = ':TSUpdate'
	}
    use 'JoosepAlviste/nvim-ts-context-commentstring'
    use 'lukas-reineke/indent-blankline.nvim'
    use("EdenEast/nightfox.nvim")
    use("arcticicestudio/nord-vim")
    use({
        "nvim-lualine/lualine.nvim",
        requires = { "nvim-tree/nvim-web-devicons", opt = true },
    })
end)
