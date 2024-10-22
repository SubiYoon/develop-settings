local home = os.getenv 'HOME'
local lspconfig = require("lspconfig")
lspconfig.arduino_language_server.setup({
    cmd = {
        "arduino-language-server",
        "-clangd", "/usr/bin/clangd",
        "-cli", "/opt/homebrew/bin/arduino-cli",
        "-cli-config", home .. "/Library/Arduino15/arduino-cli.yaml",
    },
    filetypes = { "arduino" },                                                        -- 지원하는 파일 형식
    root_dir = lspconfig.util.root_pattern(".git", "platformio.ini", "arduino.json"), -- 프로젝트의 루트 디렉토리 설정
    capabilities = require('cmp_nvim_lsp').default_capabilities(),                    -- nvim-cmp와 연동 시 사용
    on_attach = function(client, bufnr)
        -- 키맵핑 설정
        require("lsp.keymaps").on_attach(client, bufnr)
    end,
    settings = {
        arduino = {
            path = os.getenv('HOME') .. "/Library/Arduino15/packages/arduino/hardware/avr/1.8.6/cores/arduino"
        }
    }
})
