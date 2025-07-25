local status, jdtls = pcall(require, "jdtls")
if not status then
    return
end

local home = os.getenv("HOME")
WORKSPACE_PATH = home .. "/.cache/jdtls/workspace/"

---- Find root of project
local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
local root_dir = require("jdtls.setup").find_root(root_markers)

local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")

local workspace_dir = WORKSPACE_PATH .. project_name

local jdtls_dependencies_dir = home .. "/.dotfiles/nvim/jdtls_dependencies"

------------------------------
---- Prepare JAR dependencies
local bundles = {}

-- Add debug jars
local debug_jars = vim.fn.glob(jdtls_dependencies_dir .. "/debug/*.jar", true)
if debug_jars ~= "" then
    for _, jar in ipairs(vim.split(debug_jars, "\n")) do
        if jar ~= "" and vim.fn.filereadable(jar) == 1 then
            table.insert(bundles, jar)
        end
    end
end

-- Add test jars (fixed the boolean parameter and added validation)
local test_jars = vim.fn.glob(jdtls_dependencies_dir .. "/test/*.jar", true)
if test_jars ~= "" then
    for _, bundle in ipairs(vim.split(test_jars, "\n")) do
        -- Skip empty strings and validate file exists
        if bundle ~= "" and vim.fn.filereadable(bundle) == 1 then
            -- These two jars are not bundles, therefore don't put them in the table
            if
                not vim.endswith(bundle, "com.microsoft.java.test.runner-jar-with-dependencies.jar")
                and not vim.endswith(bundle, "com.microsoft.java.test.runner.jar")
            then
                table.insert(bundles, bundle)
            end
        end
    end
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local extendedClientCapabilities = require("jdtls").extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

local on_attach = function(client, bufnr)
    if client.name == "jdtls" then
        require("jdtls").setup_dap({ hotcodereplace = "auto" })
        require("jdtls.dap").setup_dap_main_class_configs()
    end
end

local launcher_jar = home
    .. "/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_1.7.0.v20250331-1702.jar"

local config = {
    cmd = {
        "java",
        --        "/usr/lib/jvm/java-17-openjdk-amd64/bin/java",
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
        launcher_jar,
        "-configuration",
        home .. "/.local/share/nvim/mason/packages/jdtls/config_linux",
        "-data",
        workspace_dir,
    },

    root_dir = root_dir,

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
                        -- path = "/usr/lib/jvm/java-17-openjdk",
                    },
                },
            },
            maven = {
                downloadSources = false,
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

    init_options = {
        bundles = bundles,
        extendedClientCapabilities = extendedClientCapabilities,
    },
    on_attach = on_attach,
    capabilities = capabilities,
}
require("jdtls").start_or_attach(config)

local function format_code()
    local bufnr = vim.api.nvim_get_current_buf()
    local filename = vim.api.nvim_buf_get_name(bufnr)
    local filetype = vim.bo[bufnr].filetype

    -- Save cursor position
    local cursor_pos = vim.api.nvim_win_get_cursor(0)

    if filetype == "java" or filename:match("%.java$") then
        if filename == "" then
            print("Save the file first before formatting Python")
            return
        end
        local idea_cmd = "idea format -allowDefaults " .. vim.fn.shellescape(filename)
        local idea_result = vim.fn.system(idea_cmd)

        if vim.v.shell_error == 0 then
            vim.api.nvim_win_set_cursor(0, cursor_pos)
            print("Formatted with intellij")
            print(vim.inspect(idea_result))
            return
        else
            print(vim.inspect(idea_result))
            print("intellij formatter not installed")
            return
        end
    end
    print("No formatter available for " .. filetype)
end

vim.api.nvim_create_user_command("JdtFormat", format_code, {
    desc = "Format current file",
})

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

keymap("n", "<leader>tc", jdtls.test_class, opts)
keymap("n", "<leader>tm", jdtls.test_nearest_method, opts)
