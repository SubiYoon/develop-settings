local mapKey = require("utils/keyMapper").mapKey
local builtin = require("telescope/builtin")
local common = require("utils.commonUtils")
local search = require("utils.searchUtils")
local npm = require("utils.npmUtils")
local codewindow = require("codewindow")


-- Custom mapping Start
mapKey("<leader>fqm", search.open_mapper_xml, "n", { desc = "Move to the mapper with the cursor word(id)" }) -- java mapper.xml찾는 함수
mapKey("<leader>cw", common.widthResize, "n", { desc = "Change Width" })                                     -- 현재 buffer 너비 조정
mapKey("<leader>ch", common.heightResize, "n", { desc = "Change Height" })                                   -- 현재 buffer 높이 조정
mapKey('<Leader>oD', "<Cmd>DBUIToggle<CR>", "n", { desc = "Database" })
mapKey("<leader>ot", common.toggle_terminal, "n", { desc = "Terminal" })                                     -- 터미널 Open
mapKey("<leader>ol", "<Cmd>Leet<CR>", "n", { desc = "Leet" })                                                -- LeetCode Open
mapKey("<leader>om", codewindow.toggle_minimap, "n", { desc = "Mini Map" })                                  -- minimap Open
mapKey("<leader>os", "<cmd>SymbolsOutline<CR>", "n", { desc = "SymbolsOutline" })                            -- SymbolsOutline Open
mapKey("gm", codewindow.toggle_focus, "n", { desc = "Mini Map" })                                            -- minimap focus
mapKey("<C-Space>", [[<C-\><C-n>]], "t", { desc = "Terminal Escape" })                                       -- 터미널에서 normal모드 변경
mapKey("<leader>pm", "<Cmd>MarkdownPreviewToggle<CR>", "n", { desc = "Markdown" })                           -- markdown 미리보기
mapKey("<leader>Nr", npm.start_npm_script, "n", { desc = "Run" })                                            -- npm run
mapKey("<leader>Nko", npm.kill_npm_script, "n", { desc = "Kill One" })                                       -- npm kill one
mapKey("<leader>Nka", npm.kill_all_npm_scripts, "n", { desc = "Kill All" })                                  -- npm kill all
mapKey("<leader>Ni", npm.npm_install, "n", { desc = "Install" })                                             -- npm install
mapKey("<leader>vm", "<cmd>MaximizerToggle<CR>", "n", { desc = "Buffer Maximizer" })                         -- buffer maximizer
-- Custom mapping End

-- Neotree toggle
mapKey("<leader>e", ":Neotree toggle<cr>", "n", { desc = "Toggle Neotree" })

-- Pane navigation
mapKey("<C-h>", "<C-w>h", "n", { desc = "Move to left pane" })   -- left
mapKey("<C-j>", "<C-w>j", "n", { desc = "Move to bottom pane" }) -- down
mapKey("<C-k>", "<C-w>k", "n", { desc = "Move to upper pane" })  -- up
mapKey("<C-l>", "<C-w>l", "n", { desc = "Move to right pane" })  -- right

-- Clear search highlight
mapKey("<leader>h", ":nohlsearch<CR>", "n", { desc = "Clear search highlight" })

-- Indent
mapKey("<", "<gv", "v", { desc = "Decrease indent for selected text" })
mapKey(">", ">gv", "v", { desc = "Increase indent for selected text" })

-- Tab (bar) control
mapKey("gT", "<Cmd>BufferPrevious<CR>", "n", { desc = "Previous buffer" })
mapKey("gt", "<Cmd>BufferNext<CR>", "n", { desc = "Next buffer" })
mapKey("<leader>t<", "<Cmd>BufferMovePrevious<CR>", "n", { desc = "Move to previous buffer" })
mapKey("<leader>t>", "<Cmd>BufferMoveNext<CR>", "n", { desc = "Move to next buffer" })
mapKey("<leader>t1", "<Cmd>BufferGoto 1<CR>", "n", { desc = "Go to buffer 1" })
mapKey("<leader>t2", "<Cmd>BufferGoto 2<CR>", "n", { desc = "Go to buffer 2" })
mapKey("<leader>t3", "<Cmd>BufferGoto 3<CR>", "n", { desc = "Go to buffer 3" })
mapKey("<leader>t4", "<Cmd>BufferGoto 4<CR>", "n", { desc = "Go to buffer 4" })
mapKey("<leader>t5", "<Cmd>BufferGoto 5<CR>", "n", { desc = "Go to buffer 5" })
mapKey("<leader>t6", "<Cmd>BufferGoto 6<CR>", "n", { desc = "Go to buffer 6" })
mapKey("<leader>t7", "<Cmd>BufferGoto 7<CR>", "n", { desc = "Go to buffer 7" })
mapKey("<leader>t8", "<Cmd>BufferGoto 8<CR>", "n", { desc = "Go to buffer 8" })
mapKey("<leader>t9", "<Cmd>BufferGoto 9<CR>", "n", { desc = "Go to buffer 9" })
mapKey("<leader>t0", "<Cmd>BufferLast<CR>", "n", { desc = "Go to last buffer" })

-- Pin/unpin buffer
-- mapKey("<A-p>", "<Cmd>BufferPin<CR>", "n", { desc = "Pin current buffer" })
-- Goto pinned/unpinned buffer
-- mapKey("<C-p>", "<Cmd>BufferGotoPinned<CR>", "n", { desc = "Go to pinned buffer" })
-- mapKey("<C-u>", "<Cmd>BufferGotoUnpinned<CR>", "n", { desc = "Go to unpinned buffer" })

-- Close buffer
mapKey("<leader>tcc", "<Cmd>BufferClose<CR>", "n", { desc = "Close current buffer" })
mapKey("<leader>tca", "<Cmd>BufferCloseAllButCurrent<CR>", "n", { desc = "Close all buffer" })
-- Wipeout buffer
-- mapKey("<leader>w", "<Cmd>BufferWipeout<CR>", "n", { desc = "Wipeout current buffer" })
-- Close commands
-- mapKey("<leader>cl", "<Cmd>BufferClosetllButCurrent<CR>", "n", { desc = "Close all but current" })
-- mapKey("<leader>cp", "<Cmd>BufferClosetllButPinned<CR>", "n", { desc = "Close all but pinned" })
-- mapKey("<leader>cu", "<Cmd>BufferClosetllButCurrentOrPinned<CR>", "n", { desc = "Close all but current or pinned" })
-- mapKey("<leader>cll", "<Cmd>BufferCloseBuffersLeft<CR>", "n", { desc = "Close buffers to the left" })
-- mapKey("<leader>clr", "<Cmd>BufferCloseBuffersRight<CR>", "n", { desc = "Close buffers to the right" })

-- Magic buffer-picking mode
-- mapKey("<C-p>", "<Cmd>BufferPick<CR>", "n", { desc = "Pick a buffer" })

-- Sort automatically by...
mapKey("<Space>tb", "<Cmd>BufferOrderByBufferNumber<CR>", "n", { desc = "Sort by buffer number" })
mapKey("<Space>tn", "<Cmd>BufferOrderByName<CR>", "n", { desc = "Sort by name" })
mapKey("<Space>td", "<Cmd>BufferOrderByDirectory<CR>", "n", { desc = "Sort by directory" })
mapKey("<Space>tl", "<Cmd>BufferOrderByLanguage<CR>", "n", { desc = "Sort by language" })
mapKey("<Space>tw", "<Cmd>BufferOrderByWindowNumber<CR>", "n", { desc = "Sort by window number" })

-- LSP
mapKey("K", vim.lsp.buf.hover, "n", { desc = "LSP hover" })
mapKey("gr", "<cmd>Telescope lsp_references<CR>", "n", { desc = "Show LSP references" })
mapKey("gd", "<cmd>Telescope lsp_definitions<CR>", "n", { desc = "Show LSP definitions" })
mapKey("gi", "<cmd>Telescope lsp_implementations<CR>", "n", { desc = "Show LSP implementations" })
mapKey("<leader>rn", vim.lsp.buf.rename, "n", { desc = "Smart rename" })
mapKey("<leader>ca", vim.lsp.buf.code_action, "n", { desc = "LSP code action" })

-- Debug
mapKey('<F7>', function() require('dap').step_into() end, "n", { desc = "Step into" })
mapKey('<F8>', function() require('dap').step_over() end, "n", { desc = "Step over" })
mapKey('<F9>', function() require('dap').continue() end, "n", { desc = "Continue" })
mapKey('<F10>', function() require('dap').step_back() end, "n", { desc = "Step back" })
mapKey('<Leader>od', function() require('dapui').toggle() end, "n", { desc = "Debug" })
mapKey('<Leader>dt', "<Cmd>DapVirtualTextToggle<CR>", "n", { desc = "Toggle VirtualText" })
mapKey('<Leader>dd', function() require('dap').toggle_breakpoint() end, "n", { desc = "Toggle breakpoint" })
mapKey('<Leader>dq', function() require('dap').terminate() end, "n", { desc = "Terminate" })
mapKey('<Leader>dbm', function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end, "n",
    { desc = "Debug: Set log point" })
mapKey('<Leader>dro', function() require('dap').repl.open() end, "n", { desc = "Open debug REPL" })
mapKey('<Leader>drl', function() require('dap').run_last() end, "n", { desc = "Run last debug session" })
mapKey('<Leader>dh', function() require('dap.ui.widgets').hover() end, { "n", "v" }, { desc = "Hover" })
mapKey('<Leader>dp', function() require('dap.ui.widgets').preview() end, { "n", "v" }, { desc = "Preview" })
mapKey('<Leader>df', function()
    local widgets = require('dap.ui.widgets')
    widgets.centered_float(widgets.frames)
end, "n", { desc = "Show frames" })
mapKey('<Leader>ds', function()
    local widgets = require('dap.ui.widgets')
    widgets.centered_float(widgets.scopes)
end, "n", { desc = "Show scopes" })

-- Git
mapKey('<Leader>gb', "<Cmd>Git blame<CR>", "n", { desc = "Git Blame" })
mapKey('<Leader>gp', "<Cmd>Gitsigns preview_hunk<CR>", "n", { desc = "Preview This Hunk" })
mapKey('<Leader>grh', "<Cmd>Gitsigns reset_hunk<CR>", "n", { desc = "Reset This Hunk" })
mapKey('<Leader>grb', "<Cmd>Gitsigns reset_buffer<CR>", "n", { desc = "Reset This Buffer" })
mapKey('<Leader>gdv', "<Cmd>Gvdiffsplit<CR>", "n", { desc = "Vsplit" })
mapKey('<Leader>gdh', "<Cmd>Ghdiffsplit<CR>", "n", { desc = "Hsplit" })
mapKey("<leader>gg", "<cmd>LazyGit<cr>", "n", { desc = "LazyGit" })

-- Java Start
--make
mapKey('<Leader>Jmv', "<Cmd>JavaRefactorExtractVariable<CR>", "n", { desc = "Variable" })
mapKey('<Leader>Jmm', "<Cmd>JavaRefactorExtractMethod<CR>", "n", { desc = "Method" })
mapKey('<Leader>Jmf', "<Cmd>JavaRefactorExtractField<CR>", "n", { desc = "Method" })
mapKey('<Leader>Jmc', "<Cmd>JavaRefactorExtractConstant<CR>", "n", { desc = "Constant" })
--test
mapKey('<Leader>Jtc', "<Cmd>JavaTestRunCurrentClass<CR>", "n", { desc = "Run Current Class" })
mapKey('<Leader>Jtm', "<Cmd>JavaTestRunCurrentMethod<CR>", "n", { desc = "Run Current Method" })
mapKey('<Leader>JtC', "<Cmd>JavaTestDebugCurrentClass<CR>", "n", { desc = "Debug Current Class" })
mapKey('<Leader>JtM', "<Cmd>JavaTestDebugCurrentMethod<CR>", "n", { desc = "Debug Current Method" })
--find
mapKey('<Leader>Jfg', "<Cmd>SpringGetMapping<CR>", "n", { desc = "Get Request" })
mapKey('<Leader>Jfp', "<Cmd>SpringPostMapping<CR>", "n", { desc = "Post Request" })
mapKey('<Leader>JfP', "<Cmd>SpringPutMapping<CR>", "n", { desc = "Put Request" })
mapKey('<Leader>Jfd', "<Cmd>SpringDeleteMapping<CR>", "n", { desc = "Delete Request" })
-- Java End

-- C++
mapKey('<Leader>Cc', common.c_complie, "n", { desc = "Compile" })
mapKey('<Leader>Cr', common.c_run, "n", { desc = "Run" })
mapKey('<Leader>Cd', common.c_debug, "n", { desc = "Debug" })

-- platformIO
mapKey('<Leader>Pr', "<Cmd>Piorun<CR>", "n", { desc = "PIO build & upload" })
mapKey('<Leader>Pm', "<Cmd>Piomon<CR>", "n", { desc = "PIO monitor" })
mapKey("<leader>Pi", "<Cmd>Pioinit<CR>", "n", { desc = "PIO init" }) -- 터미널 Open

-- neogen
mapKey('<Leader>nd', common.new_doc, "n", { desc = "Documentation" })

-- search File
mapKey("<leader>ff", search.search_by_filetype, "n", { desc = "Find File Type" })
mapKey('<Leader>fe', search.open_buffer_in_neotree, "n", { desc = "Find File Explorer" })
mapKey("<leader>fr", builtin.oldfiles, "n", { desc = "Recent File" })
mapKey("<leader>fw", builtin.live_grep, "n", { desc = "Find Word" })
mapKey("<leader>fb", builtin.buffers, "n", { desc = "Find Buffer" })
mapKey("<leader>ft", "<Cmd>TodoTelescope<CR>", "n", { desc = "Find TODO List" })
mapKey("<leader>fh", builtin.help_tags, "n", { desc = "Help Tags" })

-- LeetCode
mapKey("<leader>Lr", "<Cmd>Leet run<CR>", "n", { desc = "Run" })
mapKey("<leader>Lt", "<Cmd>Leet test<CR>", "n", { desc = "Test" })
mapKey("<leader>LL", "<Cmd>Leet lang<CR>", "n", { desc = "Language" })
mapKey("<leader>Ll", "<Cmd>Leet list<CR>", "n", { desc = "List" })
mapKey("<leader>Lq", "<Cmd>Leet exit<CR>", "n", { desc = "Exit" })
mapKey("<leader>LR", "<Cmd>Leet reset<CR>", "n", { desc = "Reset" })
mapKey("<leader>Li", "<Cmd>Leet info<CR>", "n", { desc = "Info" })
mapKey("<leader>LS", "<Cmd>Leet Submit<CR>", "n", { desc = "Submit" })
mapKey("<leader>Lc", "<Cmd>Leet console<CR>", "n", { desc = "Console" })
mapKey("<leader>Lt", "<Cmd>Leet tabs<CR>", "n", { desc = "Tabs" })
mapKey("<leader>Lm", "<Cmd>Leet menu<CR>", "n", { desc = "Menu" })
