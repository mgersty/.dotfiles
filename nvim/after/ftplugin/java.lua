local status, jdtls = pcall(require, "jdtls")
if not status then
    return
end

function get_os()
    local handle = io.popen("uname -s 2>/dev/null")
    if handle then
        local os_name = handle:read("*a"):lower():gsub("\n", "")
        handle:close()

        if os_name:find("linux") then
            return "linux"
        elseif os_name:find("darwin") then
            return "macos"
        end
    end
    return "unknown"
end

print("Operating System:", get_os())

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

local HOME = os.getenv("HOME")
local ROOT_DIR = require("jdtls.setup").find_root({ 'pom.xml' })
local CONFIG_DIR = get_os() == "linux" and "config_linux" or "config_mac"
local DEFAULT_JDK_PATH = get_os() == "linux" and  "/usr/lib/jvm/java-21-amazon-corretto" or "/usr/local/opt/openjdk@21"

local function retrieve_supplementary_dependecies()
    local dependency_bundle = {}
    local jdtls_dependencies_dir = HOME .. "/.dotfiles/nvim/jdtls_dependencies"
    local dep_jars = vim.fn.glob(jdtls_dependencies_dir .. "/test/*.jar", true)
    if dep_jars ~= "" then
        for _, jar in ipairs(vim.split(dep_jars, "\n")) do
            if jar ~= "" and vim.fn.filereadable(jar) == 1 then
                table.insert(dependency_bundle, jar)
            end
        end
    end
    return dependency_bundle
end

local completion_capabilities = require('blink.cmp').get_lsp_capabilities()
local extendedClientCapabilities = require("jdtls").extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true


local config = {
    cmd = {
        "java",
        -- "/usr/lib/jvm/java-17-openjdk-amd64/bin/java",
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
        HOME .. "/.local/share/language.servers/jdtls/plugins/jdtls.jar",
        "-configuration",
        HOME .. "/.local/share/language.servers/jdtls/" .. CONFIG_DIR,
        "-data",
        HOME .. "/.cache/jdtls/workspace/" .. vim.fn.fnamemodify(ROOT_DIR, ":p:h:t")

    },
    root_dir = ROOT_DIR,
    filetypes = { 'java' },
    settings = {
        java = {
            eclipse = {
                downloadSources = true,
            },
            configuration = {
                updateBuildConfiguration = "interactive",
                runtimes = {
                    -- {
                    --     name = "javaSE-1.8",
                    --     path = "/usr/lib/jvm/java-8-openjdk-amd64/jre",
                    -- },
                    {
                        name = "JavaSE-21",
                        path = DEFAULT_JDK_PATH,
                    }
                }
            },
            maven = {
                downloadSources = true,
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
    capabilities = completion_capabilities,
    on_attach = function(client, bufnr)
        if client.name == "jdtls" then
            require("jdtls").setup_dap({ hotcodereplace = "auto" })
            require("jdtls.dap").setup_dap_main_class_configs()
        end
    end
}
require('jdtls').start_or_attach(config)
