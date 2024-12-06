local opt = vim.opt

-- tab/indent
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.smartindent = true
opt.wrap = false

-- search
opt.incsearch = true -- search시 바로 반응
opt.ignorecase = true -- 대소문자 구분 안함
opt.smartcase = true -- 대소문자가 섞여있으면 구분함

-- visual
opt.number = true
opt.relativenumber = true -- 상대적인 줄 number가 표시
opt.termguicolors = true
opt.signcolumn = "yes"

-- etc
opt.encoding = "UTF-8"
opt.fileencoding = "UTF-8"
opt.fileencodings = { "UTF-8", "EUC-KR", "CP949" }
opt.cmdheight = 1
opt.scrolloff = 10
opt.mouse:append("a")
