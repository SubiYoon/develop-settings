local lspconfig = require("lspconfig")
lspconfig.clangd.setup({
    cmd = { "ccls" }, -- 시스템에 설치된 ccls 실행 파일 경로
    filetypes = { "c", "cpp", "objc", "objcpp" },
    root_dir = lspconfig.util.root_pattern(".ccls", "compile_commands.json", ".git"),
    init_options = {
        cache = {
            directory = ".ccls-cache",
        },
    },
})
