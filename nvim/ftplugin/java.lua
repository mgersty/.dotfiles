local pprint = require("pprint")
local status, jdtls = pcall(require, "jdtls")
if not status then
	return
end
local home = os.getenv("HOME")
if vim.fn.has("mac") == 1 then
	WORKSPACE_PATH = home .. "/.cache/jdtls/workspace/"
	CONFIG = "mac"
elseif vim.fn.has("unix") == 1 then
	WORKSPACE_PATH = home .. "/.cache/jdtls/workspace/"
	CONFIG = "linux"
else
	print("Unsupported system")
end

-- Find root of project
local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
local root_dir = require("jdtls.setup").find_root(root_markers)

local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")

local workspace_dir = WORKSPACE_PATH .. project_name

----------------------------
local java_debug_path = "~/.m2/repository/com/microsoft/java/com.microsoft.java.debug.plugin/0.49.0"
local vscode_java_test = "~/sandbox/node/vscode-java-test"
-- Prepare JAR dependencies
local bundles = {
	vim.fn.glob(java_debug_path .. "/com.microsoft.java.debug.plugin-*.jar"),
}

--Testing
for _, bundle in ipairs(vim.split(vim.fn.glob(vscode_java_test .. "/server/*.jar", 1), "\n")) do
	--These two jars are not bundles, therefore don't put them in the table
	if
		not vim.endswith(bundle, "com.microsoft.java.test.runner-jar-with-dependencies.jar")
		and not vim.endswith(bundle, "com.microsoft.java.test.runner.jar")
	then
		table.insert(bundles, bundle)
	end
end

print(pprint(bundles))
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local extendedClientCapabilities = jdtls.extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

local on_attach = function(client, bufnr)
	if client.name == "jdtls" then
		require("jdtls").setup_dap({ hotcodereplace = "auto" })
		require("jdtls.dap").setup_dap_main_class_configs()
	end
end
local config = {
	cmd = {

		"java", -- or '/path/to/java17_or_newer/bin/java'
		"-Declipse.application=org.eclipse.jdt.ls.core.id1",
		"-Dosgi.bundles.defaultStartLevel=4",
		"-Declipse.product=org.eclipse.jdt.ls.core.product",
		"-Dlog.protocol=true",
		"-Dlog.level=ALL",
		"-javaagent:" .. home .. "/.local/share/nvim/mason/packages/jdtls/lombok.jar",
		"-Xms1g",
		"--add-modules=ALL-SYSTEM",
		"--add-opens",
		"java.base/java.util=ALL-UNNAMED",
		"--add-opens",
		"java.base/java.lang=ALL-UNNAMED",

		"-jar",
		vim.fn.glob(home .. "/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"),
		"-configuration",
		home .. "/.local/share/nvim/mason/packages/jdtls/config_" .. CONFIG,
		"-data",
		workspace_dir,
	},
	-- 💀
	-- This is the default if not provided, you can remove it. Or adjust as needed.
	-- One dedicated LSP server & client will be started per unique root_dir
	root_dir = root_dir,

	-- Here you can configure eclipse.jdt.ls specific settings
	-- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
	-- for a list of options
	settings = {
		java = {
			eclipse = {
				downloadSources = true,
			},
			configuration = {
				updateBuildConfiguration = "interactive",
				runtimes = {
					{
						name = "JavaSE-1.8",
						-- path = '/usr/lib/jvm/java-8-openjdk-amd64/bin',
						path = "/home/linuxbrew/.linuxbrew/opt/openjdk@8/bin",
					},
					{
						name = "JavaSE-17",
						path = "/usr/lib/jvm/java-17-openjdk-amd64",
					},
					-- {
					-- 	name = "JavaSE-11",
					-- 	path = "/opt/homebrew/Cellar/openjdk@11/11.0.18/libexec/openjdk.jdk/Contents/Home",
					-- },
					-- {
					-- 	name = "JavaSE-19",
					-- 	path = "/opt/homebrew/Cellar/openjdk/19.0.2/libexec/openjdk.jdk/Contents/Home",
					-- },
				},
			},
			maven = {
				downloadSources = true,
			},
			implementationsCodeLens = {
				enabled = false, --Don't automatically show implementations
			},
			referencesCodeLens = {
				enabled = false, --Don't automatically show references
			},
			references = {
				includeDecompiledSources = true,
			},
			format = {
				enabled = false,
				-- settings = {
				--   profile = "asdf"
				-- }
			},
		},
	},
	signatureHelp = { enabled = true },
	completion = {
		favoriteStaticMembers = {
			"org.hamcrest.MatcherAssert.assertThat",
			"org.hamcrest.Matchers.*",
			"org.hamcrest.CoreMatchers.*",
			"org.junit.jupiter.api.Assertions.*",
			"java.util.Objects.requireNonNull",
			"java.util.Objects.requireNonNullElse",
			"org.mockito.Mockito.*",
		},
	},
	contentProvider = { preferred = "fernflower" },
	extendedClientCapabilities = extendedClientCapabilities,
	sources = {
		organizeImports = {
			starThreshold = 9999,
			staticStarThreshold = 9999,
		},
	},
	codeGeneration = {
		toString = {
			template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
		},
		useBlocks = true,
	},
	flags = {
		allow_incremental_sync = true,
	},
	-- Language server `initializationOptions`
	-- You need to extend the `bundles` with paths to jar files
	-- if you want to use additional eclipse.jdt.ls plugins.
	--
	-- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
	--
	-- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
	-- Language server `initializationOptions`
	-- You need to extend the `bundles` with paths to jar files
	-- if you want to use additional eclipse.jdt.ls plugins.
	--
	-- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
	--
	-- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
	init_options = {
		bundles = bundles,
		extendedClientCapabilities = extendedClientCapabilities,
	},
	on_attach = on_attach,
	capabilities = capabilities,
}
-- This starts a new client & server,
-- or attaches to an existing client & server depending on the `root_dir`.
require("jdtls").start_or_attach(config)
