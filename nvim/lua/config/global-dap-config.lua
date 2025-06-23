local dap = require('dap')

-- C/C++ Start
dap.adapters.codelldb = {
    type = 'server',
    port = "${port}",
    executable = {
        command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
        args = { "--port", "${port}" },
    },
}

dap.configurations.cpp = {
    {
        name = "Launch file",
        type = "codelldb",
        request = "launch",
        program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
        args = {},
    },
    {
        name = "Attach to process",
        type = "codelldb",
        request = "attach",
        pid = require('dap.utils').pick_process,
        cwd = '${workspaceFolder}',
    },
}

-- C 언어에도 동일한 설정 적용
dap.configurations.c = dap.configurations.cpp
-- C/C++ End
