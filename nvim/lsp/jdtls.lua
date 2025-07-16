local status, jdtls = pcall(require, "jdtls")
if not status then
    return
end

local HOME = os.getenv("HOME")
local ROOT_DIR = require("jdtls.setup").find_root({ 'pom.xml' })

local function retrieve_supplementary_dependecies()
    local dependency_bundle = {}
    local jdtls_dependencies_dir = HOME .. "/.dotfiles/nvim/jdtls_dependencies"
    local dep_jars = vim.fn.glob(jdtls_dependencies_dir .. "test/*.jar", true)
    if dep_jars ~= "" then
        for _, jar in ipairs(vim.split(dep_jars, "\n")) do
            if jar ~= "" and vim.fn.filereadable(jar) == 1 then
                table.insert(dependency_bundle, jar)
            end
        end
    end

    print(vim.inspect(dependency_bundle))
    return dependency_bundle
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local extendedClientCapabilities = require("jdtls").extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true


return {
    cmd = {
        "java",
        --        "/usr/lib/jvm/java-17-openjdk-amd64/bin/java",
        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
        "-Dosgi.bundles.defaultStartLevel=4",
        "-Declipse.product=org.eclipse.jdt.ls.core.product",
        "-Dlog.protocol=true",
        "-Dlog.level=ALL",
        "-javaagent:" .. HOME .. "/.local/share/nvim/mason/packages/jdtls/lombok.jar",
        "-Xms1g",
        "--add-modules=ALL-SYSTEM",
        "--add-opens",
        "java.base/java.util=ALL-UNNAMED",
        "--add-opens",
        "java.base/java.lang=ALL-UNNAMED",
        "-jar",
        HOME .. "/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_1.7.0.v20250331-1702.jar",
        "-configuration",
        HOME .. "/.local/share/nvim/mason/packages/jdtls/config_linux",
        "-data",
        HOME .. "/.cache/jdtls/workspace" .. vim.fn.fnamemodify(ROOT_DIR, ":p:h:t")

    },
    root_dir = ROOT_DIR,
    settings = {
        java = {
            eclipse = {
                downloadSources = true,
            },
            configuration = {
                updateBuildConfiguration = "interactive",
                runtimes = {
                    {
                        name = "JavaSE-21",
                        path = "/usr/local/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home",
                    }
                }
            },
            maven = {
                downloadSources = false,
            },
            implementationCodeLens = {
                enabled = false,
            },
            referenceCodeLens = {
                enabled = false,
            },
            references = {
                includeDecompiledSources = true,
            },
            format = {
                enabled = false
            },
        }
    },
    completion = {
        favoriteStaticMembers = {
            "org.hamcrest.MatcherAssert.assertThat",
            "org.hamcrest.Matchers.*",
            "org.hamcrest.CoreMatchers.*",
            "org.kunit.jupiter.api.Assertions.*",
            "java.util.Objects.requireNonNull",
            "java.util.Objects.requireNonNullElse",
            "org.mockito.Mockito.*",
        }
    },
    contentProvider = { preferred = "fernflower" },
    extendendClientCapabilities = extendedClientCapabilities,
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

    init_options = {
        bundles = retrieve_supplementary_dependecies(),
        extendedClientCapabilities = extendedClientCapabilities
    },
    capabilities = capabilities,
    on_attach = function(client, bufnr)
        if client.name == "jdtls" then
            require("jdtls").setup_dap({ hotcodereplace = "auto" })
            require("jdtls.dap").setup_dap_main_class_configs()
        end
    end

}
