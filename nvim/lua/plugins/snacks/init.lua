-- lazyvim에서는 neotree 대신 snacks를 사용함
return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      hidden = true,
      ignored = true,
      -- exclude = {
      -- "**/.git/*",
      --},
    },
  },
}
