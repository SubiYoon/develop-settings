-- return {
--   "gorbit99/codewindow.nvim",
--   config = function()
--     local codewindow = require("codewindow")
--     codewindow.setup({
--       active_in_terminals = false, -- Should the minimap activate for terminal buffers
--       auto_enable = true, -- Automatically open the minimap when entering a (non-excluded) buffer (accepts a table of filetypes)
--       exclude_filetypes = { "help" }, -- Choose certain filetypes to not show minimap on
--       max_minimap_height = nil, -- The maximum height the minimap can take (including borders)
--       max_lines = nil, -- If auto_enable is true, don't open the minimap for buffers which have more than this many lines.
--       minimap_width = 20, -- The width of the text part of the minimap
--       use_lsp = true, -- Use the builtin LSP to show errors and warnings
--       use_treesitter = true, -- Use nvim-treesitter to highlight the code
--       use_git = true, -- Show small dots to indicate git additions and deletions
--       width_multiplier = 4, -- How many characters one dot represents
--       z_index = 1, -- The z-index the floating window will be on
--       show_cursor = true, -- Show the cursor position in the minimap
--       screen_bounds = "lines", -- How the visible area is displayed, "lines": lines above and below, "background": background color
--       window_border = "single", -- The border style of the floating window (accepts all usual options)
--       relative = "editor", -- What will be the minimap be placed relative to, "win": the current window, "editor": the entire editor
--       events = { "TextChanged", "InsertLeave", "DiagnosticChanged", "FileWritePost" }, -- Events that update the code window
--     })
--   end,
-- }

---@module "neominimap.config.meta"
return {
  "Isrothy/neominimap.nvim",
  version = "v3.x.x",
  lazy = false, -- NOTE: NO NEED to Lazy load
  -- Optional. You can alse set your own keybindings
  keys = {
    -- -- Global Minimap Controls
    -- { "<leader>nm", "<cmd>Neominimap Toggle<cr>", desc = "Toggle global minimap" },
    -- { "<leader>no", "<cmd>Neominimap Enable<cr>", desc = "Enable global minimap" },
    -- { "<leader>nc", "<cmd>Neominimap Disable<cr>", desc = "Disable global minimap" },
    -- { "<leader>nr", "<cmd>Neominimap Refresh<cr>", desc = "Refresh global minimap" },
    --
    -- -- Window-Specific Minimap Controls
    -- { "<leader>nwt", "<cmd>Neominimap WinToggle<cr>", desc = "Toggle minimap for current window" },
    -- { "<leader>nwr", "<cmd>Neominimap WinRefresh<cr>", desc = "Refresh minimap for current window" },
    -- { "<leader>nwo", "<cmd>Neominimap WinEnable<cr>", desc = "Enable minimap for current window" },
    -- { "<leader>nwc", "<cmd>Neominimap WinDisable<cr>", desc = "Disable minimap for current window" },
    --
    -- -- Tab-Specific Minimap Controls
    -- { "<leader>ntt", "<cmd>Neominimap TabToggle<cr>", desc = "Toggle minimap for current tab" },
    -- { "<leader>ntr", "<cmd>Neominimap TabRefresh<cr>", desc = "Refresh minimap for current tab" },
    -- { "<leader>nto", "<cmd>Neominimap TabEnable<cr>", desc = "Enable minimap for current tab" },
    -- { "<leader>ntc", "<cmd>Neominimap TabDisable<cr>", desc = "Disable minimap for current tab" },
    --
    -- -- Buffer-Specific Minimap Controls
    -- { "<leader>nbt", "<cmd>Neominimap BufToggle<cr>", desc = "Toggle minimap for current buffer" },
    -- { "<leader>nbr", "<cmd>Neominimap BufRefresh<cr>", desc = "Refresh minimap for current buffer" },
    -- { "<leader>nbo", "<cmd>Neominimap BufEnable<cr>", desc = "Enable minimap for current buffer" },
    -- { "<leader>nbc", "<cmd>Neominimap BufDisable<cr>", desc = "Disable minimap for current buffer" },
    --
    -- ---Focus Controls
    -- { "<leader>nf", "<cmd>Neominimap Focus<cr>", desc = "Focus on minimap" },
    -- { "<leader>nu", "<cmd>Neominimap Unfocus<cr>", desc = "Unfocus minimap" },
    -- { "<leader>ns", "<cmd>Neominimap ToggleFocus<cr>", desc = "Switch focus on minimap" },
  },
  init = function()
    -- The following options are recommended when layout == "float"
    vim.opt.wrap = false
    vim.opt.sidescrolloff = 36 -- Set a large value

    --- Put your configuration here
    ---@type Neominimap.UserConfig
    vim.g.neominimap = {
      auto_enable = true,
    }
  end,
}
