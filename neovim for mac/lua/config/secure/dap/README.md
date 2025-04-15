### example
```lua
local dap = require("dap")

-- java sample
dap.adapters.java = {
	type = "server",
	host = "127.0.0.1",
	port = 5005,
}

dap.configurations.java = {
	{
		type = "java",
		request = "launch",
		name = "Launch Project 1",
		mainClass = "${file}",
		projectName = "Project1",
        args = {},
		vmArgs = "-Dfile.encoding=UTF-8",
	},
}
```
