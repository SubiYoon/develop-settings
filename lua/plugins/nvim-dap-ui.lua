-- Debugging Support
return {
    -- https://github.com/rcarriga/nvim-dap-ui
    'rcarriga/nvim-dap-ui',
    event = 'VeryLazy',
    dependencies = {
        -- https://github.com/mfussenegger/nvim-dap
        'mfussenegger/nvim-dap',
        -- https://github.com/nvim-neotest/nvim-nio
        'nvim-neotest/nvim-nio',
        -- https://github.com/theHamsta/nvim-dap-virtual-text
        'theHamsta/nvim-dap-virtual-text',   -- inline variable text while debugging
        -- https://github.com/nvim-telescope/telescope-dap.nvim
        'nvim-telescope/telescope-dap.nvim', -- telescope integration with dap
    },
    opts = {
        controls = {
            element = "repl",
            enabled = true,
            icons = {
                disconnect = "",
                pause = "",
                play = "",
                run_last = "",
                step_back = "",
                step_into = "",
                step_out = "",
                step_over = "",
                terminate = ""
            }
        },
        element_mappings = {},
        expand_lines = true,
        floating = {
            border = "single",
            mappings = {
                close = { "q", "<Esc>" }
            }
        },
        force_buffers = true,
        icons = {
            collapsed = "",
            current_frame = "",
            expanded = ""
        },
        layouts = {
            {
                elements = {
                    {
                        id = "stacks",
                        size = 0.30
                    },
                    {
                        id = "scopes",
                        size = 0.50
                    },
                    {
                        id = "watches",
                        size = 0.10
                    },
                    {
                        id = "breakpoints",
                        size = 0.10
                    },
                },
                size = 50,
                position = "left", -- Can be "left" or "right"
            },
            {
                elements = {
                    "repl",
                    "console",
                },
                size = 15,
                position = "bottom", -- Can be "bottom" or "top"
            }
        },
        mappings = {
            edit = "e",
            expand = { "<CR>", "<2-LeftMouse>" },
            open = "o",
            remove = "d",
            repl = "r",
            toggle = "t"
        },
        render = {
            indent = 1,
            max_value_lines = 100
        }
    },
    config = function(_, opts)
        local dap = require('dap')

        -- 브레이크포인트 아이콘 설정
        vim.fn.sign_define('DapBreakpoint', { text = '🔴', texthl = '', linehl = '', numhl = '' })
        vim.fn.sign_define('DapBreakpointCondition', { text = '🟠', texthl = '', linehl = '', numhl = '' })
        vim.fn.sign_define('DapBreakpointRejected', { text = '⚪', texthl = '', linehl = '', numhl = '' })
        vim.fn.sign_define('DapStopped', { text = '🔸', texthl = 'LspDiagnosticsSignHint', linehl = 'Visual', numhl = '' })


        require('dapui').setup(opts)

        dap.listeners.after.event_initialized["dapui_config"] = function()
            require('dapui').open()
        end

        dap.listeners.before.event_terminated["dapui_config"] = function()
            -- Commented to prevent DAP UI from closing when unit tests finish
            -- require('dapui').close()
        end

        dap.listeners.before.event_exited["dapui_config"] = function()
            -- Commented to prevent DAP UI from closing when unit tests finish
            -- require('dapui').close()
        end

        -- Add dap configurations based on your language/adapter settings
        -- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation
        dap.configurations.java = {
            {
                name = "Debug launch (8000)",
                type = 'java',
                request = 'launch',
                port = 8000,
                -- `nvim-jdtls` would automatically add the `classPaths` property if it is missing
                -- classPaths = {},
                mainClass = '${mainClass location}', -- com.example.project.~Application(.java)
                -- If using the JDK9+ module system, this needs to be extended
                -- `nvim-jdtls` would automatically populate this property
                -- modulePaths = {},
                cwd = vim.fn.getcwd(), -- setting root dir current location
                vmArgs = "" ..
                    "-Xmx2g ",
                args = { "spring.profiles.active=local" },
                env = {
                    SPRING_PROFILES_ACTIVE = "local",
                }
            },
        }

        require("nvim-dap-virtual-text").setup {
            enabled = true,                     -- enable this plugin (the default)
            enabled_commands = true,            -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
            highlight_changed_variables = true, -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
            highlight_new_as_changed = false,   -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
            show_stop_reason = true,            -- show stop reason when stopped for exceptions
            commented = false,                  -- prefix virtual text with comment string
            only_first_definition = true,       -- only show virtual text at first definition (if there are multiple)
            all_references = false,             -- show virtual text on all all references of the variable (not only definitions)
            clear_on_continue = false,          -- clear virtual text on "continue" (might cause flickering when stepping)
            --- A callback that determines how a variable is displayed or whether it should be omitted
            --- @param variable Variable https://microsoft.github.io/debug-adapter-protocol/specification#Types_Variable
            --- @param buf number
            --- @param stackframe dap.StackFrame https://microsoft.github.io/debug-adapter-protocol/specification#Types_StackFrame
            --- @param node userdata tree-sitter node identified as variable definition of reference (see `:h tsnode`)
            --- @param options nvim_dap_virtual_text_options Current options for nvim-dap-virtual-text
            --- @return string|nil A text how the virtual text should be displayed or nil, if this variable shouldn't be displayed
            display_callback = function(variable, buf, stackframe, node, options)
                -- by default, strip out new line characters
                if options.virt_text_pos == 'inline' then
                    return ' = ' .. variable.value:gsub("%s+", " ")
                else
                    return variable.name .. ' = ' .. variable.value:gsub("%s+", " ")
                end
            end,
            -- position of virtual text, see `:h nvim_buf_set_extmark()`, default tries to inline the virtual text. Use 'eol' to set to end of line
            virt_text_pos = vim.fn.has 'nvim-0.10' == 1 and 'inline' or 'eol',

            -- experimental features:
            all_frames = false,     -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
            virt_lines = false,     -- show virtual lines instead of virtual text (will flicker!)
            virt_text_win_col = nil -- position the virtual text at a fixed window column (starting from the first text column) ,
            -- e.g. 80 to position at column 80, see `:h nvim_buf_set_extmark()`
        }
    end
}
