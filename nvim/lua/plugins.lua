local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

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
	use "rafamadriz/friendly-snippets"
	use { 'saadparwaiz1/cmp_luasnip' }
	use({
		"L3MON4D3/LuaSnip",
		tag = "v2.2.0",
		run = "make install_jsregexp"
	})

    -- Snippet Sources
	use("hrsh7th/cmp-nvim-lsp") -- nvim-cmp source for neovim's built-in languagage-server
	use("hrsh7th/cmp-nvim-lsp-document-symbol") -- nvim-cmp source for autosuggesting the nearest symbol i.e. function, variable etc..
	use("hrsh7th/cmp-nvim-lsp-signature-help") -- nvim-cmp source for showing details about the specific method you are looking at.
	use("hrsh7th/cmp-nvim-lua") -- nvim-cmp source for Neovim's Lua API

    -- Telescope
	use({
		"nvim-telescope/telescope.nvim",
		tag = "0.1.2",
		requires = { { "nvim-lua/plenary.nvim" } },
	})

	use("nvim-telescope/telescope-file-browser.nvim")
	use("nvim-telescope/telescope-packer.nvim")
	use("benfowler/telescope-luasnip.nvim")
    -- Tree Sitter
    use({
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
	})

    -- Commenting
    use("tpope/vim-commentary")
	use("JoosepAlviste/nvim-ts-context-commentstring")


    -- Appearence & Style
    use("tpope/vim-surround")
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
    use("simrat39/symbols-outline.nvim")
    use({
        "iamcco/markdown-preview.nvim",
         run = function() vim.fn["mkdp#util#install"]() end,
    })

    use("folke/which-key.nvim")

    if packer_bootstrap then
        require('packer').sync()
    end
end)



