--GLOBAL
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
vim.g.mapleader = " "

-- GENERAL MAPPINGS
map("n", "<C-H>", "<C-W>h", opts)
map("n", "<C-J>", "<C-W>j", opts)
map("n", "<C-L>", "<C-W>l", opts)
map("n", "<C-K>", "<C-W>k", opts)

--NVIM-TREE
map("n", "<leader>e", ":NvimTreeToggle<CR>", opts)
map("n", "<leader>o", ":NvimTreeFocus<CR>", opts)
map("t", "<esc>", [[<C-\><C-n>]], {})
-- TELESCOPE
local telescope_builtins = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", telescope_builtins.find_files, {})
vim.keymap.set("n", "<leader>fg", telescope_builtins.live_grep, {})
vim.keymap.set("n", "<leader>fb", telescope_builtins.buffers, {})
--vim.keymap.set('n', '<leader>fb', ":Telescope file_browser<CR>", {})
vim.keymap.set("n", "<leader>fh", telescope_builtins.help_tags, {})

--LSP
vim.keymap.set(
	"v",
	"<space>ca",
	"<ESC><CMD>lua vim.lsp.buf.range_code_action()<CR>",
	{ noremap = true, silent = true, buffer = bufnr, desc = "Code actions" }
)

-- key_mapping --
local key_map = function(mode, key, result)
	vim.api.nvim_set_keymap(mode, key, result, { noremap = true, silent = true })
end

-- run debug
function get_test_runner(test_name, debug)
	if debug then
		return 'mvn test -Dmaven.surefire.debug -Dtest="' .. test_name .. '"'
	end
	return 'mvn test -Dtest="' .. test_name .. '"'
end

function run_java_test_method(debug)
	local utils = require("utils")
	local method_name = utils.get_current_full_method_name("\\#")
	vim.cmd("term " .. get_test_runner(method_name, debug))
end

function run_java_test_class(debug)
	local utils = require("utils")
	local class_name = utils.get_current_full_class_name()
	vim.cmd("term " .. get_test_runner(class_name, debug))
end

function get_spring_boot_runner(profile, debug)
	local debug_param = ""
	if debug then
		debug_param =
			' -Dspring-boot.run.jvmArguments="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=5005" '
	end

	local profile_param = ""
	if profile then
		profile_param = " -Dspring-boot.run.profiles=" .. profile .. " "
	end

	return "mvn spring-boot:run " .. profile_param .. debug_param
end

function run_spring_boot(debug)
	vim.cmd("term " .. get_spring_boot_runner("local", debug))
end

vim.keymap.set("n", "<leader>tm", function()
	run_java_test_method()
end)
vim.keymap.set("n", "<leader>TM", function()
	run_java_test_method(true)
end)
vim.keymap.set("n", "<leader>tc", function()
	run_java_test_class()
end)
vim.keymap.set("n", "<leader>TC", function()
	run_java_test_class(true)
end)
vim.keymap.set("n", "<F9>", function()
	run_spring_boot()
end)
vim.keymap.set("n", "<F10>", function()
	run_spring_boot(true)
end)

-- setup debug
key_map("n", "<leader>b", ':lua require"dap".toggle_breakpoint()<CR>')
key_map("n", "<leader>B", ':lua require"dap".set_breakpoint(vim.fn.input("Condition: "))<CR>')
key_map("n", "<leader>bl", ':lua require"dap".set_breakpoint(nil, nil, vim.fn.input("Log: "))<CR>')
key_map("n", "<leader>dr", ':lua require"dap".repl.open()<CR>')

-- view informations in debug
function show_dap_centered_scopes()
	local widgets = require("dap.ui.widgets")
	widgets.centered_float(widgets.scopes)
end
key_map("n", "gs", ":lua show_dap_centered_scopes()<CR>")

-- move in debug
key_map("n", "<F5>", ':lua require"dap".continue()<CR>')
key_map("n", "<F8>", ':lua require"dap".step_over()<CR>')
key_map("n", "<F7>", ':lua require"dap".step_into()<CR>')
key_map("n", "<S-F8>", ':lua require"dap".step_out()<CR>')

function attach_to_debug()
	local dap = require("dap")
	dap.configurations.java = {
		{
			type = "java",
			request = "attach",
			name = "Attach to the process",
			hostName = "localhost",
			port = "5005",
		},
	}
	dap.continue()
end

key_map("n", "<leader>da", ":lua attach_to_debug()<CR>")
