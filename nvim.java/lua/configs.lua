require("mason").setup()
require("mason-lspconfig").setup()

-- TELESCOPE
require('telescope').setup({
	defaults = {
		  path_display = {
      shorten = {
        len = 3, exclude = {1, -1}
      },
      truncate = true
    },
    dynamic_preview_title = true,
	}
})
require("telescope").load_extension("ui-select")
require("telescope").load_extension("file_browser")

--NVIM-TREE
require("nvim-tree").setup({auto_reload_on_write = true })


--TREE-SITTER
require("nvim-treesitter.configs").setup({
        ensure_installed = {
                "java",
                "bash",
                "lua",
                "vim",
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
        refactor = {
                smart_rename = { enable = true, keymaps = { smart_rename = "grr" } },
        },
})


-- CMP AUTOCOMPLETION
local cmp = require('cmp')

cmp.setup {
  sources = {
    { name = 'nvim_lsp' },
    { name = 'nvim_lsp_signature_help' },
    { name = 'vsnip' },
  },
  snippet = {
    expand = function(args)
      -- Comes from vsnip
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  }

-- LUALINE Status Bar
  require("lualine").setup({
options = { theme = "nord" }
  })
