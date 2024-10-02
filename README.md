---
tags:
  - Tools
  - NeoVim
  - Install
---
# 기본 환경
* homebrew
* mac OS

# NeoVim 설치
```bash
brew install neovim ripgrep
```

# 폴더 구조
```bash
├─── ftplugin
│   │ 
│   └─── java.lua # lsp java설정 관련
│    
├─── lua
│   │ 
│   ├─── config
│   │   │
│   │   ├─── globals.lua # 전체 환경 설정
│   │   │
│   │   ├─── init.lua # 초기화 설정
│   │   │
│   │   ├─── keymaps.lua # 키맵핑 설정
│   │   │
│   │   └─── options.lua # 옵션 설정
│   │ 
│   ├─── plugins
│   │   │
│   │   ├─── lsp
│   │   │   │
│   │   │   ├─── jdtls.lua # java lsp
│   │   │   │
│   │   │   └─── lsp.lua # language 문법 검사
│   │   │
│   │   │
│   │   ├─── alpha.lua # nvim 실행시 dashboard
│   │   │
│   │   ├─── theme.lua # 에디터 테마
│   │   │
│   │   ├─── indent-blankline.lua # 들여쓰기 가이드 표시
│   │   │
│   │   ├─── lualine.lua # 하단 표시 테마(INSERT mode, NOMAL mode 표시)
│   │   │
│   │   ├─── dressing.lua # select,insert 꾸미기
│   │   │
│   │   ├─── notify.lua # 알림창
│   │   │
│   │   ├─── noice.lua # message, cmdline, popupmenu UI
│   │   │
│   │   ├─── neo-tree.lua # filefolder 탐색기
│   │   │
│   │   ├─── nvim-cmp.lua # 문법 자동완성
│   │   │
│   │   ├─── git-signs.lua # git 변경사항 실시간 반영
│   │   │
│   │   ├─── fugitive.lua # git 명령어 싱행가능하게 설정
│   │   │
│   │   ├─── barbar.lua # tab관련 플러그인
│   │   │
│   │   ├─── vnim-conform.lua # 코드 포멧팅 제공(prettier 등)
│   │   │
│   │   ├─── nvim-treesitter.lua # syntax highlight 등 등
│   │   │
│   │   ├─── nnvim-ufo.lua # code를 펼치고/접는 기능(command -/+와 같은 기능)
│   │   │
│   │   ├─── surround.lua # text를 특정 basket으로 감싸는 플러그인
│   │   │
│   │   ├─── telescope.lua # 파일 검색
│   │   │
│   │   ├─── vim-maximizer.lua # 분할한 화면 최대 크기로 키우는 플러그인(<leader>sm)
│   │   │
│   │   └─── vim-autopairs.lua # auto basket close
│   │ 
│   └──── utils
│        │
│        └─── keyMapper.lua # 키맵할 수 있는 함수
│ 
├─── init.lua
│
└─── lazy-lock.json
```
