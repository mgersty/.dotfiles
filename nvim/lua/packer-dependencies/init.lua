vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

return require('packer').startup(function()
    use 'wbthomason/packer.nvim'
    use 'EdenEast/nightfox.nvim'
    use {'nvim-tree/nvim-tree.lua',
            requires = {
                'nvim-tree/nvim-web-devicons',
            }
            
    }
    use 'neovim/nvim-lspconfig'
    use 'rcarriga/nvim-notify'
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'kyaxdani42/nvim-web-devicons', opt=true}
    }
    use {
        'romgrk/barbar.nvim',
        requires = { 'kyaxdani42/nvim-web-devicons', opt=true}
    }
 
end)
