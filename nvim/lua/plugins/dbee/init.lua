return {
  {
    "kndndrj/nvim-dbee",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    build = function()
      -- Go가 필요합니다. go가 없으면 "curl" 또는 "wget" 사용
      require("dbee").install("go")
    end,
    config = function()
      require("dbee").setup({
        -- 연결 소스 설정
        sources = {
          -- 파일 소스 (nvim config 디렉토리에 저장)
          require("dbee.sources").FileSource:new(vim.fn.stdpath("config") .. "/lua/config/secure/db/dbee/connections.json"),
          -- 환경 변수 소스
          require("dbee.sources").EnvSource:new("DBEE_CONNECTIONS"),
        },
      })
    end,
  },
  -- DBee 자동완성 플러그인
  {
    "MattiasMTS/cmp-dbee",
    dependencies = {
      "kndndrj/nvim-dbee",
    },
    ft = "sql",
    opts = {},
  },
  -- nvim-cmp에 dbee 소스 추가
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "MattiasMTS/cmp-dbee",
    },
    opts = function(_, opts)
      table.insert(opts.sources, { name = "cmp-dbee" })
    end,
  },
}
