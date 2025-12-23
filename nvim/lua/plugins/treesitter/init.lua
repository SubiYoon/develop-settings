return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = { "java", "python", "lua", "javascript", "typescript", "tsx", "c", "cpp", "markdown", "markdown_inline", "sql" },
    highlight = {
      enable = true,
      -- disable = function(lang, buf)
      --   local ignored = { "snacks_dashboard" } -- 원하는 filetype 추가
      --   return vim.tbl_contains(ignored, lang)
      -- end,
    },
  },
}
