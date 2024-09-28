local opt = vim.opt

-- tab/indent
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
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
opt.cmdheight = 1
opt.scrolloff = 10
opt.mouse:append("a")
