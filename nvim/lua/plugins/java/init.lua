local home = os.getenv("HOME")
local sdkman_java_path = home .. "/.sdkman/candidates/java"

-- Extract major version number from sdkman java directory name
-- e.g., "17.0.13-tem" -> 17, "21.0.5-graalce" -> 21, "1.8.0_392-tem" -> 8
local function extract_major_version(dirname)
  -- Handle 1.x.x format (Java 5, 6, 7, 8)
  local legacy_major = dirname:match("^1%.(%d+)")
  if legacy_major then
    return tonumber(legacy_major)
  end

  -- Handle modern format (Java 9+)
  local major = dirname:match("^(%d+)%.")
  if major then
    return tonumber(major)
  end

  return nil
end

-- Scan sdkman java directory and build runtimes table
-- @param default_version: (optional) major version number to set as default
-- e.g., get_sdkman_runtimes(17) -> JavaSE-17 will have default = true
local function get_sdkman_runtimes(default_version)
  local runtimes = {}
  local seen_versions = {}

  if vim.fn.isdirectory(sdkman_java_path) == 0 then
    return runtimes
  end

  local java_dirs = vim.fn.glob(sdkman_java_path .. "/*", false, true)

  for _, dir in ipairs(java_dirs) do
    local dirname = vim.fn.fnamemodify(dir, ":t")

    if dirname ~= "current" then
      local major_version = extract_major_version(dirname)

      if major_version and not seen_versions[major_version] then
        seen_versions[major_version] = true

        local runtime = {
          name = "JavaSE-" .. major_version,
          path = dir,
        }

        -- Add default flag if this version matches
        if default_version and major_version == default_version then
          runtime.default = true
        end

        table.insert(runtimes, runtime)
      end
    end
  end

  table.sort(runtimes, function(a, b)
    local va = tonumber(a.name:match("JavaSE%-(%d+)"))
    local vb = tonumber(b.name:match("JavaSE%-(%d+)"))
    return va < vb
  end)

  return runtimes
end

return {
  "nvim-java/nvim-java",
  config = function()
    require("java").setup()

    local default_java_version = 21

    vim.lsp.config("jdtls", {
      settings = {
        java = {
          configuration = {
            runtimes = get_sdkman_runtimes(default_java_version),
          },
        },
      },
    })

    vim.lsp.enable("jdtls")
  end,
}
