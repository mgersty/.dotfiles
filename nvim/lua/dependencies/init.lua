vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

return require('packer').startup(function()
    use 'wbthomason/packer.nvim'
    use 'EdenEast/nightfox.nvim'
    use {'nvim-tree/nvim-tree.lua',
            requires = {
                'nvim-tree/nvim-web-devicons',
            }
            
    }
    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.1',
        requires = { {'nvim-lua/plenary.nvim'} }
    }
    use 'williamboman/mason.nvim'
	use 'williamboman/mason-lspconfig.nvim'
    use 'neovim/nvim-lspconfig'
    use 'onsails/lspkind-nvim'
    use 'hrsh7th/nvim-cmp'
    use 'hrsh7th/cmp-nvim-lsp'
    use("saadparwaiz1/cmp_luasnip") --> Snippets source for nvim-cmp
    use("L3MON4D3/LuaSnip")
    use 'rcarriga/nvim-notify'
    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
    use { 
        'numToStr/Comment.nvim', 
        config=function() 
            require('Comment').setup()
        end 
    }
    use 'nvim-treesitter/nvim-treesitter-refactor'
    use 'p00f/nvim-ts-rainbow'
    use 'windwp/nvim-ts-autotag' -- auto complete html tags    
    use 'JoosepAlviste/nvim-ts-context-commentstring'
    use "lukas-reineke/indent-blankline.nvim"
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'kyaxdani42/nvim-web-devicons', opt=true}
    }
    use {
        'romgrk/barbar.nvim',
        requires = { 'kyaxdani42/nvim-web-devicons', opt=true}
    }
 
end)
