local metals = require("metals")
local metals_configs = metals.bare_config()


metals_configs.settings = {
    showImplicitArguments = true,
    excludedPackages = { "akka.actor.typed.javadsl" }
}

metals_configs.init_options.statusBarProvider="on"
metals_configs.capabilities = require("cmp_nvim_lsp").default_capabilities()

metals.setup_dap()
metals.initialize_or_attach(metals_configs)
