return {
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            local wk = require('which-key')
            wk.add(
                {
                    -- group start
                    { "<leader>f", group = "Search File" },
                    { "<leader>J", group = "Java", icon = "☕️" },
                    { '<Leader>Jt', group = "Test", icon = "🧪" },
                    { '<Leader>Jm', group = "Make", icon = "🏗️" },
                    { '<Leader>Jf', group = "Find" },
                    { "<leader>v", group = "View", icon = "🗾" },
                    { "<leader>N", group = "Npm", icon = "📦" },
                    { "<leader>Nk", group = "Npm Kill", icon = "☠️" },
                    { "<leader>r", group = "Re", icon = "♻️" },
                    { "<leader>c", group = "Change", icon = "🌀" },
                    { "<leader>fq", group = "Find Query File" },
                    { "<leader>o", group = "Open", icon = "📖" },
                    { "<leader>p", group = "Preview", icon = "👁️" },
                    { '<Leader>n', group = "New", icon = "📝" },
                    { '<Leader>C', group = "C", icon = "⚙️" },
                    { '<Leader>P', group = "PlatformIO", icon = "🔧" },
                    { "<leader>t", group = "Tab", icon = "🪟" },
                    { "<leader>tc", group = "Tab Close", icon = "🪟" },
                    { '<Leader>L', group = "Leetcode", icon = "🧠" },
                    { '<Leader>g', group = "Git" },
                    { '<Leader>d', group = "Debug" },
                    -- group end

                    -- no setting group start
                    { "<leader>m", "<cmd>MCstart<cr>", mode = 'n', icon = "🔍", desc = "Multicusor" }
                    -- no setting group end
                }
            )
        end,
        opts = {
        },
        keys = {
            {
                "<leader>?",
                function()
                    require("which-key").show({ global = false })
                end,
                desc = "Buffer Local Keymaps (which-key)",
            },
        },
    }
}
