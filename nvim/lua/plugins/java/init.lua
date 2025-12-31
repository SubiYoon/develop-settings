local home = os.getenv("HOME")
local sdkman_java_path = home .. "/.sdkman/candidates/java"

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

return {
  "nvim-java/nvim-java",
  config = function()
    require("java").setup()
    vim.lsp.enable("jdtls")
    vim.lsp.config("jdtls", {
      settings = {
        java = {
          configuration = {
            runtimes = {
              get_sdkman_runtimes(),
            },
          },
        },
      },
    })
  end,
}
