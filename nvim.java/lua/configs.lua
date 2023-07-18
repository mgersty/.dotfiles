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


-- CMP AutoCompletion

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
