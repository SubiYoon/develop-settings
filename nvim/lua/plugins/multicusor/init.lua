return {
  "brenton-leighton/multiple-cursors.nvim",
  version = "*", -- Use the latest tagged version
  opts = {}, -- This causes the plugin setup function to be called
  keys = {
    {
      "<M-k>",
      "<Cmd>MultipleCursorsAddUp<CR>",
      mode = { "n", "i", "x" },
      desc = "Add cursor and move up",
    },
    {
      "<M-j>",
      "<Cmd>MultipleCursorsAddDown<CR>",
      mode = { "n", "i", "x" },
      desc = "Add cursor and move down",
    },
    {
      "<M-LeftMouse>", -- 이유는 모르겠으나... command + LeftMouse로 동작
      "<Cmd>MultipleCursorsMouseAddDelete<CR>",
      mode = { "n", "i" },
      desc = "Add or remove cursor",
    },
    {
      "<Leader>ma",
      "<Cmd>MultipleCursorsAddMatches<CR>",
      mode = { "n", "x" },
      desc = "Add cursors to cword",
    },
    {
      "<Leader>mA",
      "<Cmd>MultipleCursorsAddMatchesV<CR>",
      mode = { "n", "x" },
      desc = "Add cursors to cword in previous area",
    },
    {
      "<Leader>mw",
      "<Cmd>MultipleCursorsAddJumpNextMatch<CR>",
      mode = { "n", "x" },
      desc = "Add cursor and jump to next cword",
    },
    {
      "<Leader>mj",
      "<Cmd>MultipleCursorsJumpNextMatch<CR>",
      mode = { "n", "x" },
      desc = "Jump to next cword",
    },
    {
      "<Leader>ml",
      "<Cmd>MultipleCursorsLock<CR>",
      mode = { "n", "x" },
      desc = "Lock virtual cursors",
    },
  },
}
