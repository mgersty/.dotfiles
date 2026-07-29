---@brief
---
--- https://github.com/microsoft/typespec
---
--- The language server for TypeSpec, a language for defining cloud service APIs and shapes.
---
--- `tsp-server` can be installed together with the typespec compiler via `npm`:
--- ```sh
--- npm install -g @typespec/compiler
--- ```

---@type vim.lsp.Config
return {
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = { 'typespec','ts','tsx' },
  root_markers = { 'tspconfig.yaml', '.git' },
}
