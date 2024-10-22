local home = os.getenv 'HOME'
local lspconfig = require("lspconfig")
lspconfig.arduino_language_server.setup({
    cmd = {
        "arduino-language-server",
        "-clangd", "/usr/bin/clangd",
        "-cli", "/opt/homebrew/bin/arduino-cli",
        "-cli-config", home .. "/Library/Arduino15/arduino-cli.yaml",
    },
    filetypes = { "arduino", "ino", "pde" },                                          -- 지원하는 파일 형식
    root_dir = lspconfig.util.root_pattern(".git", "platformio.ini", "arduino.json"), -- 프로젝트의 루트 디렉토리 설정
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
    settings = {
        arduino = {
            path = home .. "/Library/Arduino15/packages/arduino/hardware/avr/1.8.6/cores/arduino"
        }
    }
})
