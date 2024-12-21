local keymap = vim.keymap.set
local jdtls = require("jdtls")
local opts = { noremap = true, silent = true }

keymap("n", "<leader>tc", jdtls.test_class, opts)
keymap("n", "<leader>tc", jdtls.test_nearest_method, opts)
