### example
```lua
local dap = require("dap")

-- 첫 번째 Java 프로젝트 설정
dap.adapters.java = {
	type = "server",
	host = "127.0.0.1",
	port = 5005, -- 첫 번째 프로젝트용 포트
}

dap.configurations.java = {
	{
		type = "java",
		request = "launch",
		name = "Launch Project 1",
		mainClass = "${file}",
		projectName = "Project1", -- 첫 번째 프로젝트 이름
		vmArgs = "-Dfile.encoding=UTF-8 -Dspring.profiles.active=local -Djasypt.encryptor.password=MATHWHTIE!@1857$^*711",
	},
}

-- 두 번째 Java 프로젝트 설정
dap.adapters.java_2 = {
	type = "server",
	host = "127.0.0.1",
	port = 5006, -- 두 번째 프로젝트용 포트
}

dap.configurations.java_2 = {
	{
		type = "java",
		request = "launch",
		name = "Launch Project 2",
		mainClass = "${file}",
		projectName = "Project2", -- 두 번째 프로젝트 이름
		vmArgs = "-Dfile.encoding=UTF-8",
	},
}

--  번째 Java 프로젝트 설정
dap.adapters.java_3 = {
	type = "server",
	host = "127.0.0.1",
	port = 5007, -- 두 번째 프로젝트용 포트
}

dap.configurations.java_3 = {
	{
		type = "java",
		request = "launch",
		name = "Launch Project 3",
		mainClass = "${file}",
		projectName = "Project3", -- 두 번째 프로젝트 이름
		vmArgs = "-Dfile.encoding=UTF-8",
	},
}
```
