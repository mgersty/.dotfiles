local jdtls = vim.fn.stdpath("data")
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = os.getenv("HOME") .. "/.eclipse.workspaces/" .. project_name
local JDTLS_LOCATION = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
print(workspace_dir)
local config = {
	cmd = {
		"java",
		"-Declipse.application=org.eclipse.jdt.ls.core.id1",
		"-Dosgi.bundles.defaultStartLevel=4",
		"-Declipse.product=org.eclipse.jdt.ls.core.product",
		"-Dlog.protocol=true",
		"-Dlog.level=ALL",
		"-Xms1g",
		"--add-modules=ALL-SYSTEM",
		"--add-opens",
		"java.base/java.util=ALL-UNNAMED",
		"--add-opens",
		"java.base/java.lang=ALL-UNNAMED",
		"-jar",
		vim.fn.glob(JDTLS_LOCATION .. "/plugins/org.eclipse.equinox.launcher_*.jar"),
		"-configuration",
		JDTLS_LOCATION .. "/config_linux",
		"-data",
		workspace_dir,
	},
	root_dir = vim.fs.dirname(vim.fs.find({ ".git", "pom.xml" }, { upward = true })[1]),
}
require("jdtls").start_or_attach(config)
