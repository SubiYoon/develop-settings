local home = os.getenv 'HOME'
local lspconfig = require("lspconfig")
lspconfig.clangd.setup({
    cmd = { "clangd" },
    filetypes = { "c", "cpp", "objc", "objcpp", "ino", "arduino" },         -- 지원 파일 타입
    root_dir = require 'lspconfig'.util.root_pattern(".git", "compile_commands.json", "compile_flags.txt",
        "Makefile", "CMakeLists.txt"),
    capabilities = require('cmp_nvim_lsp').default_capabilities(),         -- nvim-cmp와 연동 시 사용
})
