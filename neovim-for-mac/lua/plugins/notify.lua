return {
	"rcarriga/nvim-notify",
	config = function()
		local notify = require("notify")
		notify.setup({
			background_colour = "#FFFFFF",
			fps = 30,
			icons = {
				DEBUG = "",
				ERROR = "",
				INFO = "",
				TRACE = "✎",
				WARN = "",
			},
			level = 2,
			minimum_width = 50,
			render = "wrapped-compact",
			stages = "fade_in_slide_out",
			time_formats = {
				notification = "%T",
				notification_history = "%FT%T",
			},
			timeout = 5000,
			top_down = true,
		})
	end,
}
