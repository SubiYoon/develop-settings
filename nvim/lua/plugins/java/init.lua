local home = os.getenv("HOME")
local sdkman_java_path = home .. "/.sdkman/candidates/java"

local function get_bundles()
  local bundles = {
    vim.fn.glob(home .. "/.local/share/nvim/mason/share/java-debug-adapter/com.microsoft.java.debug.plugin.jar"),
  }
  vim.list_extend(bundles, vim.split(vim.fn.glob(home .. "/.local/share/nvim/mason/share/java-test/*.jar", 1), "\n"))
  return bundles
end

local function get_workspace_dir()
  local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
  return vim.fn.stdpath("data") .. "/java-workspace/" .. project_name
end

local function get_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  local ok_blink, blink = pcall(require, "blink.cmp")
  if ok_blink and blink.get_lsp_capabilities then
    return blink.get_lsp_capabilities(capabilities)
  end

  local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
  if ok_cmp then
    return cmp_lsp.default_capabilities(capabilities)
  end

  return capabilities
end

-- Extract major version number from sdkman java directory name
-- e.g., "17.0.13-tem" -> 17, "21.0.5-graalce" -> 21, "1.8.0_392-tem" -> 8
local function extract_major_version(dirname)
  -- Handle 1.8.x format (Java 8)
  if dirname:match("^1%.8") then
    return 8
  end
  -- Handle standard format: major.minor.patch-vendor
  local major = dirname:match("^(%d+)%.")
  if major then
    return tonumber(major)
  end
  return nil
end

-- Scan sdkman java directory and build runtimes table
local function get_sdkman_runtimes()
  local runtimes = {}
  local seen_versions = {}

  -- Check if sdkman java directory exists
  if vim.fn.isdirectory(sdkman_java_path) == 0 then
    return runtimes
  end

  -- Get all directories in sdkman java path
  local java_dirs = vim.fn.glob(sdkman_java_path .. "/*", false, true)

  for _, dir in ipairs(java_dirs) do
    local dirname = vim.fn.fnamemodify(dir, ":t")

    -- Skip 'current' symlink to avoid duplicates
    if dirname ~= "current" then
      local major_version = extract_major_version(dirname)

      if major_version then
        -- JavaSE naming convention
        local runtime_name = "JavaSE-" .. major_version

        -- If we haven't seen this major version, or this is a newer patch
        -- Keep track to avoid duplicate major versions (use latest patch)
        if not seen_versions[major_version] then
          seen_versions[major_version] = true
          table.insert(runtimes, {
            name = runtime_name,
            path = dir,
          })
        end
      end
    end
  end

  -- Sort by version number for cleaner output
  table.sort(runtimes, function(a, b)
    local va = tonumber(a.name:match("JavaSE%-(%d+)"))
    local vb = tonumber(b.name:match("JavaSE%-(%d+)"))
    return va < vb
  end)

  return runtimes
end

-- Find Java 21+ for running jdtls itself
local function get_jdtls_java_path()
  local runtimes = get_sdkman_runtimes()

  -- Find Java 21 or higher
  for _, runtime in ipairs(runtimes) do
    local version = tonumber(runtime.name:match("JavaSE%-(%d+)"))
    if version and version >= 21 then
      return runtime.path .. "/bin/java"
    end
  end

  -- Fallback to current java
  return "java"
end

return {
  "nvim-java/nvim-java",
  ft = { "java" },
  dependencies = {
    "neovim/nvim-lspconfig",
    "mfussenegger/nvim-dap",
    "mason-org/mason.nvim",
  },
  config = function()
    -- Debug: print detected runtimes (uncomment to verify)
    -- vim.print(get_sdkman_runtimes())

    require("java").setup({
      jdk = {
        auto_install = false,
      },
      root_markers = {
        ".git",
        "mvnw",
        "gradlew",
        "pom.xml",
        "build.gradle",
        "settings.gradle",
        "settings.gradle.kts",
        "build.gradle.kts",
      },
      jdtls = {
        jvm_args = {
          "-javaagent:" .. home .. "/.local/share/nvim/mason/packages/lombok-nightly/lombok.jar",
        },
      },
    })

    local jdtls_config = {
      cmd = {
        get_jdtls_java_path(),
        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
        "-Dosgi.bundles.defaultStartLevel=4",
        "-Declipse.product=org.eclipse.jdt.ls.core.product",
        "-Dlog.protocol=true",
        "-Dlog.level=ALL",
        "-Xmx2g",
        "--add-modules=ALL-SYSTEM",
        "--add-opens",
        "java.base/java.util=ALL-UNNAMED",
        "--add-opens",
        "java.base/java.lang=ALL-UNNAMED",
        "-javaagent:" .. home .. "/.local/share/nvim/mason/packages/lombok-nightly/lombok.jar",
        "-jar",
        vim.fn.glob(home .. "/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"),
        "-configuration",
        home .. "/.local/share/nvim/mason/packages/jdtls/config_mac_arm",
        "-data",
        get_workspace_dir(),
      },
      settings = {
        java = {
          eclipse = {
            downloadSources = true,
          },
          configuration = {
            updateBuildConfiguration = "interactive",
            -- Automatically detect all sdkman Java versions
            runtimes = get_sdkman_runtimes(),
          },
          signatureHelp = { enabled = true },
          implementationsCodeLens = { enabled = true },
          referencesCodeLens = { enabled = true },
          references = {
            includeDecompiledSources = true,
          },
          maven = {
            downloadSources = true,
          },
          format = {
            enabled = false,
          },
          inlayHints = {
            parameterNames = {
              enabled = "all",
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
            "org",
          },
        },
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
      capabilities = get_capabilities(),
      flags = {
        allow_incremental_sync = true,
      },
      init_options = {
        bundles = get_bundles(),
      },
      on_attach = function(client, bufnr)
        -- onload custom settings
      end,
    }

    require("lspconfig").jdtls.setup(jdtls_config)
  end,
}
