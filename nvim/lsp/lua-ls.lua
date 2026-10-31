
local root_markers1 = {
  '.emmyrc.json',
  '.luarc.json',
  '.luarc.jsonc',
}
local root_markers2 = {
  '.luacheckrc',
  '.stylua.toml',
  'stylua.toml',
  'selene.toml',
  'selene.yml',
}

---@type vim.lsp.Config
return {
  cmd = { vim.fn.exepath('lua-language-server') ~= '' and vim.fn.exepath('lua-language-server') or 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = vim.fn.has('nvim-0.11.3') == 1 and { root_markers1, root_markers2, { '.git' } }
    or vim.list_extend(vim.list_extend(root_markers1, root_markers2), { '.git' }),
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
        path = { '?.lua', '?/init.lua' },
      },
      diagnostics = {
        globals = { 'vim' },
      },
      workspace = {
        checkThirdParty = false,
        library = { vim.env.VIMRUNTIME },
      },
      codeLens = { enable = true },
      hint = { enable = true, semicolon = 'Disable' },
    },
  },
}
