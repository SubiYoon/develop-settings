-- local keymaps = require("config.keymaps")
local builtin = require("telescope/builtin")
local searchUtils = require("utils.searchUtils")

return {
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            local wk = require('which-key')
            wk.add({
                    { "<leader>f",  group = "Search File" },
                    { "<leader>ff", searchUtils.search_by_filetype, desc = "Find File Type" },
                    -- { "<leader>ff", builtin.find_files,                         desc = "Find File" },
                    { "<leader>fr", builtin.oldfiles,               desc = "Recent File" },
                    { "<leader>fw", builtin.live_grep,              desc = "Find Word" },
                    { "<leader>fb", builtin.buffers,                desc = "Find Buffer" },
                    { "<leader>ft", "<Cmd>TodoTelescope<CR>",       desc = "Find TODO List" },
                    { "<leader>fh", builtin.help_tags,              desc = "Help Tags" },
                },
                {
                    -- Nested mappings are allowed and can be added in any order
                    -- Most attributes can be inherited or overridden on any level
                    -- There's no limit to the depth of nesting
                    mode = { "n", "v" },                          -- NORMAL and VISUAL mode
                    { "<leader>q", "<cmd>q<cr>", desc = "Quit" }, -- no need to specify mode since it's inherited
                    { "<leader>w", "<cmd>w<cr>", desc = "Write" },
                })
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
