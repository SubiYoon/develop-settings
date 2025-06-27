return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.add({
        -- group start
        { "<leader>f", group = "Search File" },
        { "<leader>J", group = "Java", icon = "☕️" },
        { "<Leader>Jt", group = "Test", icon = "🧪" },
        { "<Leader>Jm", group = "Make", icon = "🏗️" },
        { "<Leader>Jf", group = "Find" },
        { "<leader>v", group = "View", icon = "🗾" },
        { "<leader>r", group = "Re", icon = "♻️" },
        { "<leader>c", group = "Change", icon = "🌀" },
        { "<leader>fq", group = "Find Query File" },
        { "<leader>o", group = "Open", icon = "📖" },
        { "<leader>p", group = "Preview", icon = "👁️" },
        { "<Leader>n", group = "New", icon = "📝" },
        { "<Leader>C", group = "C", icon = "💻" },
        { "<Leader>P", group = "PlatformIO", icon = "🔧" },
        { "<leader>t", group = "Tab", icon = "🪟" },
        { "<leader>tc", group = "Tab Close", icon = "🪟" },
        { "<Leader>L", group = "Leetcode", icon = "👨‍💻" },
        { "<Leader>g", group = "Git" },
        { "<Leader>d", group = "Debug" },
        { "<Leader>m", group = "Multi cusors", icon = "⌨️" },
        { "<Leader>a", group = "chatGPT", icon = "🤖" },
        { "<Leader>b", group = "Buffer", icon = "🗒️" },
        { "<Leader>s", group = "Smart", icon = "🧠" },
        { "<Leader>q", group = "Session", icon = "🎟️" },
        { "<Leader>u", group = "Settings", icon = "⚙️" },
        { "<Leader>j", group = "Just(NPM)", icon = "📦" },
        -- group end
      })
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
