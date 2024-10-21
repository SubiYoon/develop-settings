---
tags:
  - Tools
  - NeoVim Install
---
# 기본 환경
* homebrew
* mac OS

# 최초설치시 주의 사항
* lsp.lua파일에 들어가서 jdlts를 주석처리하고 플러그인 설치
* 전부 설치 후 다시 jdlts의 주석을 다시 해제

# NeoVim 설치(현재는 자동감지해서 설치하게 만듬)
|pagkage|desc|
|---|---|
|neovim|에디터|
|ripgrep|검색|
|lazygit|git UI|
|platformio|project init setting|

```bash
brew install neovim ripgrep lazygit platformio
```

# 폴더 구조
```bash
├─── ftplugin
│   │ 
│   └─── java.lua # lsp java설정 관련(project별 환경설정 방법 ':JavaProfile'로 설정)
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
│   │   ├─── platformio.lua # 개발환경 세팅해주는 플러그인
│   │   │
│   │   ├─── dressing.lua # select,insert 꾸미기
│   │   │
│   │   ├─── notify.lua # 알림창
│   │   │
│   │   ├─── lazygit.lua # git GUI 플러그인
│   │   │
│   │   ├─── noice.lua # message, cmdline, popupmenu UI
│   │   │
│   │   ├─── neoconf.lua # 편리한 환경설정(?)
│   │   │
│   │   ├─── multicusor.lua # multicusor 플러그인 <leader>m
│   │   │
│   │   ├─── neogen.lua # 주석관련 플러그인
│   │   │
│   │   ├─── which-key.lua # keyMapping 사용시 목록 보여주는 플러그인
│   │   │
│   │   ├─── neo-tree.lua # filefolder 탐색기
│   │   │
│   │   ├─── nvim-cmp.lua # 문법 자동완성
│   │   │
│   │   ├─── nvim-dap-iu.lua # 디버깅
│   │   │
│   │   ├─── nvim-dap-virtual-text.lua # 디버깅
│   │   │
│   │   ├─── git-signs.lua # git 변경사항 실시간 반영
│   │   │
│   │   ├─── fugitive.lua # git 명령어 실행가능하게 설정
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
│   │   ├─── todo-comments.lua # todo, fixme, hack, ... 등 하이라이트
│   │   │
│   │   ├─── vim-maximizer.lua # 분할한 화면 최대 크기로 키우는 플러그인(<leader>sm)
│   │   │
│   │   └─── vim-autopairs.lua # auto basket close
│   │ 
│   └──── utils
│        │
│        ├─── searchUtils.lua # 검색관련 utils 함수 모음
│        │
│        ├─── gitUtils.lua # git관련 utils 함수 모음
│        │
│        ├─── commonUtils.lua # 공통 utils 함수 모음
│        │
│        └─── keyMapper.lua # 키맵할 수 있는 함수
│ 
├─── init.lua
│
└─── lazy-lock.json
```
