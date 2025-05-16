return {
	-- lazy.nvim
	"folke/noice.nvim",
	event = "VeryLazy",
	opts = {
		-- add any options here
	},
	dependencies = {
		-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
		"MunifTanjim/nui.nvim",
		-- OPTIONAL:
		--   `nvim-notify` is only needed, if you want to use the notification view.
		--   If not available, we use `mini` as the fallback
		"rcarriga/nvim-notify",
	},
	config = function()
		require("noice").setup({
			cmdline = {
				view = "cmdline_popup", -- 명령줄 입력 디자인
				opts = {
					position = {
						row = "50%", -- 화면 세로 중앙
						col = "50%", -- 화면 가로 중앙
					},
					size = {
						width = 50, -- 창 너비
						height = "auto", -- 창 높이 자동 조절
					},
					border = {
						style = "rounded", -- 테두리 스타일
					},
					win_options = {
						winblend = 15, -- 창 투명도
						winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
					},
				},
			},
			messages = {
				view = "mini", -- 메시지 출력 뷰
				view_error = "notify", -- view for errors
				view_warn = "notify", -- view for warnings
				view_history = "messages", -- view for :messages
				view_search = "virtualtext", -- view for search count messages. Set to `false` to disable
			},
			popupmenu = {
				backend = "nui", -- 팝업 메뉴의 NUI 백엔드 사용
			},
			presets = {
				bottom_search = true, -- 검색 UI를 화면 하단에 표시
				command_palette = false, -- 명령 팔레트 스타일 활성화
				long_message_to_split = true, -- 긴 메시지를 스플릿으로 이동
			},
			views = {
				mini = {
					position = {
						row = "98%", -- 화면 세로 중앙
						col = "100%", -- 화면 가로 중앙
					},
					size = {
						width = "auto", -- 창 너비
						height = "auto", -- 창 높이 자동 조절
					},
					border = {
						style = "rounded", -- 테두리 스타일 변경 (가능 옵션: "single", "double", "rounded", "solid")
						text = {
							top = "Message", -- 상단 텍스트
							top_align = "center", -- 텍스트 정렬 (left, center, right)
						},
					},
					win_options = {
						winblend = 20, -- 투명도 (0: 불투명, 100: 완전 투명)
						winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
					},
				},
			},
		})
	end,
}
