return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      local has_internet = require("utils.commonUtils").has_internet()

      -- 기본 그룹 (항상 표시)
      local groups = {
        { "<leader>f", group = "Search File" },
        { "<leader>j", group = "Java", icon = "☕️" },
        { "<leader>jG", group = "Gradle", icon = "🐘" },
        { "<leader>jM", group = "Maven", icon = "✔︎" },
        { "<Leader>jt", group = "Test", icon = "🧪" },
        { "<Leader>jr", group = "Refactor", icon = "🔧" },
        { "<Leader>jn", group = "Generate", icon = "✨" },
        { "<leader>c", group = "Code", icon = "📝" },
        { "<leader>fq", group = "Find Query File" },
        { "<leader>o", group = "Open", icon = "📖" },
        { "<leader>m", group = "Markdown", icon = "Ⓜ️↓" },
        { "<Leader>n", group = "New", icon = "🆕" },
        { "<Leader>C", group = "C", icon = "💻" },
        { "<Leader>P", group = "PlatformIO", icon = "🔧" },
        { "<leader>t", group = "Tab", icon = "🗒️" },
        { "<leader>tc", group = "Tab Close", icon = "🗒️" },
        { "<Leader>g", group = "Git" },
        { "<Leader>r", group = "Refactor", icon = "🔧" },
        { "<Leader>d", group = "Debug" },
        { "<Leader>M", group = "Buffer Maximizer", icon = "👁️" },
        { "<Leader>p", group = "Python", icon = "🐍" },
        { "<Leader>s", group = "Smart", icon = "🧠" },
        { "<Leader>q", group = "Session", icon = "🎟️" },
        { "<Leader>u", group = "Settings", icon = "⚙️" },
        { "<Leader>J", group = "Just(NPM)", icon = "📦" },
        { "<Leader>h", group = "Http", icon = "🌐" },
        { "<Leader>w", group = "Window", icon = "🪟" },
      }

      -- 인터넷 필요 그룹 추가
      if has_internet then
        table.insert(groups, { "<Leader>L", group = "Leetcode", icon = "👨‍💻" })
        table.insert(groups, { "<Leader>a", group = "AI/Claude Code", icon = "🤖" })
      end

      wk.add(groups)
    end,
    opts = {},
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },
}
