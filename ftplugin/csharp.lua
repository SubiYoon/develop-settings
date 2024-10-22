local lspconfig = require("lspconfig")
lspconfig.omnisharp.setup({
    cmd = { "omnisharp" },
    filetypes = { "cs", "vb" },
    init_options = { formatting = true },
    root_dir = require('lspconfig').util.root_pattern(".git", ".csproj"),
})
