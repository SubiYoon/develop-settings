local dap = require("dap")

dap.adapters["pwa-node"] = {
  type = "server",
  host = "localhost",
  port = "${port}",
  executable = {
    command = "node",
    args = {
      vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
      "${port}",
    },
  },
}

local js_config = {
  {
    type = "pwa-node",
    request = "launch",
    name = "just dev(include npm install)",
    runtimeExecutable = "just",
    runtimeArgs = { "dev" },
    cwd = vim.fn.getcwd(),
    console = "integratedTerminal", -- 콘솔 출력 위치
    internalConsoleOptions = "neverOpen",
  },
  {
    type = "pwa-node",
    request = "attach",
    name = "Attach to Process",
    processId = require("dap.utils").pick_process,
    cwd = "${workspaceFolder}",
  },
}

for _, lang in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact", "vue" }) do
  dap.configurations[lang] = js_config
end
