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
|luarocks|필수 설치|
|ripgrep|검색|
|lazygit|git UI|
|platformio|project init setting|
|arduino-cli|arduino-cli|
|ccls|C, C++ lsp|

```bash
# brew package
brew install neovim ripgrep lazygit platformio arduino-cli ccls
```

# 직접 설치
```bash
# platformIO Core(CLI) install
curl -fsSL -o get-platformio.py https://raw.githubusercontent.com/platformio/platformio-core-installer/master/get-platformio.py
python3 get-platformio.py
```

# option키를 Meta 키로 설정
### iTerm2
* iTerm2를 열고, Preferences > Profiles > Keys 탭으로 이동합니다.
* Left Option Key와 Right Option Key를 Esc+로 설정합니다.

### macOS 기본 터미널
* 터미널을 열고, Preferences > Profiles > Keyboard 탭으로 이동합니다.
* Use Option as Meta Key를 활성화합니다.

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
│   │   ├─── secure
│   │   │   │
│   │   │   └─── db # DB정보 폴더
│   │   │       │
│   │   │       └─── README.md # DB관련 세팅방법
│   │   │
│   │   ├─── snippets # snippet 설정 파일
│   │   │   │
│   │   │   └─── java.lua # java관련 스니핏 파일
│   │   │
│   │   ├─── autocmd.lua # 자동 동작 설정
│   │   │
│   │   ├─── globals.lua # 전체 환경 설정
│   │   │
│   │   ├─── init.lua # 초기화 설정
│   │   │
│   │   ├─── keymaps.lua # 키맵핑 설정
│   │   │
│   │   ├─── dap-config.lua # 디버깅 설정(언어별)
│   │   │
│   │   └─── options.lua # 옵션 설정
│   │ 
│   ├─── plugins
│   │   │
│   │   ├─── language
│   │   │   │
│   │   │   └─── java.lua # java 전용 플러그인 세팅
│   │   │
│   │   │
│   │   ├─── alpha.lua # nvim 실행시 dashboard
│   │   │
│   │   ├─── colorizer.lua # color syntax highlight plugin
│   │   │
│   │   ├─── codeWindow.lua # mini code preview plugin
│   │   │
│   │   ├─── theme.lua # 에디터 테마
│   │   │
│   │   ├─── lsp.lua # language 문법 검사
│   │   │
│   │   ├─── indent-blankline.lua # 들여쓰기 가이드 표시
│   │   │
│   │   ├─── lualine.lua # 하단 표시 테마(INSERT mode, NOMAL mode 표시)
│   │   │
│   │   ├─── platformio.lua # 개발환경 세팅해주는 플러그인
│   │   │
│   │   ├─── dressing.lua # select, insert 꾸미기
│   │   │
│   │   ├─── notify.lua # 알림창
│   │   │
│   │   ├─── lazy-reload.lua # 플러그인 reload without neovim restart
│   │   │
│   │   ├─── lazygit.lua # git GUI 플러그인
│   │   │
│   │   ├─── leetcode.lua # leetcode 플러그인
│   │   │
│   │   ├─── illuminate.lua # 같은 변수 및 심볼 하이라이트 플러그인
│   │   │
│   │   ├─── markdown.lua # markdown 작성 bowswer로 미리보기
│   │   │
│   │   ├─── noice.lua # message, cmdline, popupmenu UI
│   │   │
│   │   ├─── neoconf.lua # 편리한 환경설정(?)
│   │   │
│   │   ├─── multicusor.lua # multicusor 플러그인 <leader>m
│   │   │
│   │   ├─── neogen.lua # 주석관련 플러그인
│   │   │
│   │   ├─── which-key.lua # keyMapping 사용시 목록 보여주는 플러그인(그룹핑 아이콘용으로만 사용)
│   │   │
│   │   ├─── neo-tree.lua # filefolder 탐색기
│   │   │
│   │   ├─── nvim-cmp.lua # 문법 자동완성
│   │   │
│   │   ├─── nvim-dap-iu.lua # 디버깅 UI
│   │   │
│   │   ├─── nvim-dap-virtual-text.lua # 디버깅 data preview
│   │   │
│   │   ├─── git-signs.lua # git 변경사항 preview
│   │   │
│   │   ├─── fugitive.lua # git 명령어 실행가능하게 설정
│   │   │
│   │   ├─── barbar.lua # tab관련 플러그인
│   │   │
│   │   ├─── vnim-conform.lua # 코드 포멧팅 제공(prettier 등)
│   │   │
│   │   ├─── nvim-treesitter.lua # syntax highlight 등 등
│   │   │
│   │   ├─── ts-autotag.lua # markup 태그 autoclose
│   │   │
│   │   ├─── nnvim-ufo.lua # code를 펼치고/접는 기능(command -/+와 같은 기능)
│   │   │
│   │   ├─── session-manager.lua # 현재 상태 저장하는 플러그인
│   │   │
│   │   ├─── surround.lua # text를 특정 basket으로 감싸는 플러그인
│   │   │
│   │   ├─── symbols-outline.lua # 함수, 변수 등 한번에 볼 수 있는 플러그인(<leader>os : 커스텀함)
│   │   │
│   │   ├─── telescope-spring.lua # spring Request Mapping 검색
│   │   │
│   │   ├─── telescope.lua # 파일 검색
│   │   │
│   │   ├─── todo-comments.lua # todo, fixme, hack, ... 등 하이라이트
│   │   │
│   │   ├─── vim-dadbod.lua # DB관련 플러그인 (사용하려는 DB 설치 필요 mysql, postgresql, oracleDB 등)
│   │   │
│   │   ├─── vim-maximizer.lua # 분할한 화면 최대 크기로 키우는 플러그인
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
