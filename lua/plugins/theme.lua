return {
    "cpea2506/one_monokai.nvim",
    -- "folke/tokyonight.nvim",
    priority = 1000, -- Ensure it loads first
    lazy = false,
    opts = {},
    config = function()
        vim.cmd([[colorscheme one_monokai]])

        -- 일반 텍스트 요소들 투명하게 설정
        vim.cmd("hi Normal guibg=NONE ctermbg=NONE")     -- 일반 텍스트
        vim.cmd("hi NormalNC guibg=NONE ctermbg=NONE")   -- 비활성화된 창 텍스트
        vim.cmd("hi NonText guibg=NONE ctermbg=NONE")    -- 비가시 텍스트
        vim.cmd("hi SignColumn guibg=NONE ctermbg=NONE") -- 사이드바 텍스트
        vim.cmd("hi LineNr guibg=NONE ctermbg=NONE")     -- 줄 번호
        vim.cmd("hi CursorLine guibg=NONE ctermbg=NONE") -- 현재 커서 줄
        vim.cmd("hi StatusLine guibg=NONE ctermbg=NONE") -- 상태줄
        vim.cmd("hi TabLine guibg=NONE ctermbg=NONE")    -- 탭 줄

        -- NeoTree 관련 하이라이트 설정
        vim.cmd("hi NeoTreeNormal guibg=NONE ctermbg=NONE")           -- NeoTree 기본 배경
        vim.cmd("hi NeoTreeDirectoryName guibg=NONE ctermbg=NONE")    -- 디렉토리 이름 배경
        vim.cmd("hi NeoTreeFileName guibg=NONE ctermbg=NONE")         -- 파일 이름 배경
        vim.cmd("hi NeoTreeGitStatus guibg=NONE ctermbg=NONE")        -- Git 상태 배경
        vim.cmd("hi NeoTreeIndentMarker guibg=NONE ctermbg=NONE")     -- 들여쓰기 마커 배경
        vim.cmd("hi NeoTreeFileIcon guibg=NONE ctermbg=NONE")         -- 파일 아이콘 배경
        vim.cmd("hi NeoTreeCursorLine guibg=NONE ctermbg=NONE")       -- 커서가 위치한 줄 배경
        vim.cmd("hi NeoTreeExpander guibg=NONE ctermbg=NONE")         -- 확장자 배경
        vim.cmd("hi NeoTreeRootName guibg=NONE ctermbg=NONE")         -- 루트 이름 배경
        vim.cmd("hi NeoTreeEmptyFolderName guibg=NONE ctermbg=NONE")  -- 비어있는 폴더 이름 배경
        vim.cmd("hi NeoTreeOpenedFolderName guibg=NONE ctermbg=NONE") -- 열려 있는 폴더 이름 배경
        vim.cmd("hi NeoTreeSpecialKey guibg=NONE ctermbg=NONE")       -- 특별한 키 배경

        -- Telescope 관련 하이라이트 설정
        vim.cmd("hi TelescopeNormal guibg=NONE ctermbg=NONE")        -- Telescope 기본 배경
        vim.cmd("hi TelescopeBorder guibg=NONE ctermbg=NONE")        -- Telescope 테두리 배경
        vim.cmd("hi TelescopePromptNormal guibg=NONE ctermbg=NONE")  -- Prompt 배경
        vim.cmd("hi TelescopeResultsNormal guibg=NONE ctermbg=NONE") -- 결과 배경
        vim.cmd("hi TelescopePreviewNormal guibg=NONE ctermbg=NONE") -- 미리보기 배경

        -- Noice 관련 하이라이트 설정
        vim.cmd("hi NoiceNormal guibg=NONE ctermbg=NONE")  -- Noice 기본 배경
        vim.cmd("hi NoiceMessage guibg=NONE ctermbg=NONE") -- 메시지 배경
        vim.cmd("hi NoiceInfo guibg=NONE ctermbg=NONE")    -- 정보 배경
        vim.cmd("hi NoiceError guibg=NONE ctermbg=NONE")   -- 에러 배경

        -- WhichKey 관련 하이라이트 설정
        vim.cmd("hi WhichKey guibg=NONE ctermbg=NONE")          -- WhichKey 기본 배경
        vim.cmd("hi WhichKeyFloat guibg=NONE ctermbg=NONE")     -- WhichKey 플로팅 배경
        vim.cmd("hi WhichKeyGroup guibg=NONE ctermbg=NONE")     -- WhichKey 그룹 배경
        vim.cmd("hi WhichKeyDesc guibg=NONE ctermbg=NONE")      -- WhichKey 설명 배경
        vim.cmd("hi WhichKeySeparator guibg=NONE ctermbg=NONE") -- WhichKey 구분자 배경
    end,

}
