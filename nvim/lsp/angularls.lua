
return {
  cmd = {"ngserver", "--stdio"},
  filetypes = { "html" },
  init_options = {
    provideFormatter = true,
  },
  root_markers = { '.git' },
}
