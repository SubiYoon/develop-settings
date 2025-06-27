return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = { "java" },
    highlight = {
      enable = true,
      disable = function(lang, buf)
        local ignored = { "snacks_dashboard", "Avante" } -- 원하는 filetype 추가
        return vim.tbl_contains(ignored, lang)
      end,
    },
  },
}
