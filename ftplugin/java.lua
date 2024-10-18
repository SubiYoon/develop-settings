local home = os.getenv 'HOME'
local workspace_path = home .. '/.local/share/nvim/jdtls-workspace/'
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local workspace_dir = workspace_path .. project_name

local status, jdtls = pcall(require, 'jdtls')
if not status then
    return
end

local bundles = {
    vim.fn.glob(vim.env.HOME .. '/.local/share/nvim/mason/share/java-debug-adapter/com.microsoft.java.debug.plugin.jar'),
}

vim.list_extend(bundles,
    vim.split(vim.fn.glob(vim.env.HOME .. "/.local/share/nvim/mason/share/java-test/*.jar", 1), "\n"))

local extendedClientCapabilities = jdtls.extendedClientCapabilities

local config = {
    cmd = {
        'java',
        '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        '-Dosgi.bundles.defaultStartLevel=4',
        '-Declipse.product=org.eclipse.jdt.ls.core.product',
        '-Dlog.protocol=true',
        '-Dlog.level=ALL',
        '-Xmx2g',
        '--add-modules=ALL-SYSTEM',
        '--add-opens',
        'java.base/java.util=ALL-UNNAMED',
        '--add-opens',
        'java.base/java.lang=ALL-UNNAMED',
        '-javaagent:' .. home .. '.local/share/nvim/mason/packages/jdtls/lombok.jar',
        '-jar',
        vim.fn.glob(home .. '/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar'),
        '-configuration',
        home .. '/.local/share/nvim/mason/packages/jdtls/config_mac',
        '-data',
        workspace_dir,
    },
    root_dir = require('jdtls.setup').find_root { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' },

    settings = {
        java = {
            -- you want main java version setting? setting this java-path
            -- home = 'java-path',
            eclipse = {
                downloadSources = true
            },
            configuration = {
                updateBuildConfiguration = 'interactive',
                runtimes = {
                    -- {
                    --   name = 'JavaSE-11',
                    --   path = 'java-path'
                    -- },
                }
            },
            signatureHelp = { enabled = true },
            extendedClientCapabilities = extendedClientCapabilities,
            maven = {
                downloadSources = true,
            },
            implementationsCodeLens = {
                enabled = true,
            },
            referencesCodeLens = {
                enabled = true,
            },
            references = {
                includeDecompiledSources = true,
            },
            format = {
                enabled = true,
                -- Formatting works by default, but you can refer to a specific file/URL if you choose
                -- settings = {
                --     url = "file:///" ..
                --         home .. "/.local/share/nvim/mason/packages/google-java-format/google-java-format*.jar",
                --     profile = "GoogleStyle",
                -- },
            },
            inlayHints = {
                parameterNames = {
                    enabled = 'all', -- literals, all, none
                },
            },
        },
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
            importOrder = {
                "java",
                "javax",
                "com",
                "org"
            },
        },
        extendedClientCapabilities = jdtls.extendedClientCapabilities,
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
    },
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
    flags = {
        allow_incremental_sync = true,
    },
    init_options = {
        -- References the bundles defined above to support Debugging and Unit Testing
        bundles = bundles
    },
}
-- Needed for debugging
config['on_attach'] = function(client, bufnr)
    jdtls.setup_dap({ hotcodereplace = 'auto' })
    require('jdtls.dap').setup_dap_main_class_configs()
end

require('jdtls').start_or_attach(config)
