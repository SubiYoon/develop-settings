return {
  "NvChad/nvim-colorizer.lua",
  event = "BufReadPost", -- 파일 열 때 자동 적용
  opts = {
    filetypes = { "*" }, -- 모든 파일 타입에서 작동
    user_default_options = {
      RGB = true, -- #RGB 지원
      RRGGBB = true, -- #RRGGBB 지원
      names = true, -- red, blue 등 color name 지원
      css = true, -- CSS 함수도 하이라이팅 (rgb(), hsl())
      tailwind = true, -- tailwind 클래스 색상도 미리보기
      sass = { enable = true, parsers = { "css" } }, -- .sass 확장자에서도 적용
      mode = "background", -- 또는 "foreground" 가능
    },
  },
  config = function(_, opts)
    require("colorizer").setup(opts)
  end,
}
