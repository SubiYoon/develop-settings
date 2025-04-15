local dap = require("dap")

-- Java 디버거 설정
dap.adapters.java = {
	type = "executable",
	command = "java",
	args = {
		"-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005",
		"-jar",
		"/path/to/java-debug/com.microsoft.java.debug.plugin.jar",
	},
}

dap.configurations.java = {
	{
		type = "java",
		request = "launch",
		name = "Launch Java File",
		mainClass = "src/java/hello/hello_spring/HelloSpringApplication",
		projectName = "Spring-study-init",
		cwd = vim.fn.getcwd(),
	},
}
