return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'
  use {
    "williamboman/mason.nvim",
    run = ":MasonUpdate" -- :MasonUpdate updates registry contents
}
  use 'mfussenegger/nvim-dap'
  use 'mfussenegger/nvim-jdtls'
  use 'nvim-lua/plenary.nvim'

  use 'neovim/nvim-lspconfig'
end)
