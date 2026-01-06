local mapKey = require("utils.commonUtils").mapKey
local builtin = require("telescope/builtin")
local common = require("utils.commonUtils")
local search = require("utils.searchUtils")
local has_internet = common.has_internet()
local neominimap = require("neominimap.api")
local dap = require("dap")
local dap_ui_widgets = require("dap.ui.widgets")
local dapui = require("dapui")
local spring = require("utils.springUtils")
local refactor = require("refactor.refactor")

-- Custom mapping Start
mapKey("<leader>fqm", search.open_mapper_xml, "n", { desc = "Move to the mapper with the cursor word(id)" }) -- java mapper.xml찾는 함수
mapKey("<leader>ww", common.widthResize, "n", { desc = "Change Width" }) -- 현재 buffer 너비 조정
mapKey("<leader>wh", common.heightResize, "n", { desc = "Change Height" }) -- 현재 buffer 높이 조정
mapKey("<Leader>oD", function()
  require("dbee").toggle()
end, "n", { desc = "Open Selector" })
mapKey("<leader>ot", common.toggle_terminal, "n", { desc = "Terminal" }) -- 터미널 Open
if has_internet then
  mapKey("<leader>ol", "<Cmd>Leet<CR>", "n", { desc = "Leet" }) -- LeetCode Open (인터넷 필요)
end
mapKey("<leader>om", neominimap.toggle, "n", { desc = "Mini Map" }) -- minimap Open
mapKey("<leader>os", "<cmd>SymbolsOutline<CR>", "n", { desc = "SymbolsOutline" }) -- SymbolsOutline Open
mapKey("<C-n>", [[<C-\><C-n>]], { "t", "i", "v" }, { desc = "Terminal Escape" }) -- 터미널에서 normal모드 변경
mapKey("<leader>M", "<cmd>Maximize<CR>", "n", { desc = "Buffer Maximizer" }) -- buffer maximizer
-- Custom mapping End

-- Pane navigation
mapKey("<C-h>", "<C-w>h", "n", { desc = "Move to left pane" }) -- left
mapKey("<C-j>", "<C-w>j", "n", { desc = "Move to bottom pane" }) -- down
mapKey("<C-k>", "<C-w>k", "n", { desc = "Move to upper pane" }) -- up
mapKey("<C-l>", "<C-w>l", "n", { desc = "Move to right pane" }) -- right

-- Clear search highlight
mapKey("<leader>h", ":nohlsearch<CR>", "n", { desc = "Clear search highlight" })

-- Indent
mapKey("<", "<gv", "v", { desc = "Decrease indent for selected text" })
mapKey(">", ">gv", "v", { desc = "Increase indent for selected text" })

-- Tab (bar) control Start
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
-- Close buffer
mapKey("<leader>tcc", "<Cmd>BufferClose<CR>", "n", { desc = "Close current buffer" })
mapKey("<leader>tca", "<Cmd>BufferCloseAllButCurrent<CR>", "n", { desc = "Close all buffer" })
-- Magic buffer-picking mode
mapKey("<Leader>tp", "<Cmd>BufferPick<CR>", "n", { desc = "Pick a buffer" })
-- Sort automatically by...
mapKey("<Leader>tn", "<Cmd>BufferOrderByName<CR>", "n", { desc = "Sort by name" })
mapKey("<Leader>td", "<Cmd>BufferOrderByDirectory<CR>", "n", { desc = "Sort by directory" })
mapKey("<Leader>tl", "<Cmd>BufferOrderByLanguage<CR>", "n", { desc = "Sort by language" })
-- Tab (bar) control End

-- LSP
mapKey("K", vim.lsp.buf.hover, "n", { desc = "LSP hover" })
mapKey("gr", "<cmd>Telescope lsp_references<CR>", "n", { desc = "Show LSP references" })
mapKey("gd", "<cmd>Telescope lsp_definitions<CR>", "n", { desc = "Show LSP definitions" })
mapKey("gi", "<cmd>Telescope lsp_implementations<CR>", "n", { desc = "Show LSP implementations" })
mapKey("<leader>ca", vim.lsp.buf.code_action, "n", { desc = "LSP code action" })

-- Debug
mapKey("<F7>", dap.step_into, "n", { desc = "Step into" })
mapKey("<F8>", dap.step_over, "n", { desc = "Step over" })
mapKey("<F9>", dap.continue, "n", { desc = "Continue" })
mapKey("<F10>", dap.step_back, "n", { desc = "Step back" })
mapKey("<Leader>od", dapui.toggle, "n", { desc = "Debug" })
mapKey("<Leader>dt", "<Cmd>DapVirtualTextToggle<CR>", "n", { desc = "Toggle VirtualText" })
mapKey("<Leader>dd", dap.toggle_breakpoint, "n", { desc = "Toggle breakpoint" })
mapKey("<Leader>dq", dap.terminate, "n", { desc = "Terminate" })
mapKey("<Leader>dbm", function()
  dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
end, "n", { desc = "Debug: Set log point" })
mapKey("<Leader>dro", dap.repl.open, "n", { desc = "Open debug REPL" })
mapKey("<Leader>drl", dap.run_last, "n", { desc = "Run last debug session" })
mapKey("<Leader>dh", dap_ui_widgets.hover, { "n", "v" }, { desc = "Hover" })
mapKey("<Leader>dp", dap_ui_widgets.preview, { "n", "v" }, { desc = "Preview" })
mapKey("<Leader>df", function()
  dap_ui_widgets.centered_float(dap_ui_widgets.frames)
end, "n", { desc = "Show frames" })
mapKey("<Leader>ds", function()
  dap_ui_widgets.centered_float(dap_ui_widgets.scopes)
end, "n", { desc = "Show scopes" })

-- Git
mapKey("<Leader>gb", "<Cmd>Git blame<CR>", "n", { desc = "Git Blame" })
mapKey("<Leader>gp", "<Cmd>Gitsigns preview_hunk<CR>", "n", { desc = "Preview This Hunk" })
mapKey("<Leader>grh", "<Cmd>Gitsigns reset_hunk<CR>", "n", { desc = "Reset This Hunk" })
mapKey("<Leader>grb", "<Cmd>Gitsigns reset_buffer<CR>", "n", { desc = "Reset This Buffer" })
mapKey("<Leader>gdv", "<Cmd>Gvdiffsplit<CR>", "n", { desc = "Vsplit" })
mapKey("<Leader>gdh", "<Cmd>Ghdiffsplit<CR>", "n", { desc = "Hsplit" })
mapKey("<leader>gg", "<cmd>LazyGit<cr>", "n", { desc = "LazyGit" })

-- Custom IntelliJ-style Extract Refactoring
mapKey("<Leader>rv", refactor.extract_variable, "n", { desc = "Extract Variable" })
mapKey("<Leader>rm", refactor.extract_method, "v", { desc = "Extract Method" })
mapKey("<Leader>rf", refactor.extract_field, "n", { desc = "Extract Field" })
mapKey("<Leader>rC", refactor.extract_constant, "n", { desc = "Extract Constant" })
mapKey("<Leader>rp", refactor.extract_parameter, "n", { desc = "Extract Parameter" })
mapKey("<Leader>rH", refactor.debug_hover, "n", { desc = "Debug JDTLS Hover (Dev)" })
mapKey("<Leader>rD", refactor.debug_chain, "n", { desc = "Debug Chain Parsing (Dev)" })

-- Generate (생성)
mapKey("<Leader>rc", refactor.generate_constructor, "n", { desc = "Generate Constructor" })
mapKey("<Leader>rg", refactor.generate_getter, "n", { desc = "Generate Getter" })
mapKey("<Leader>rs", refactor.generate_setter, "n", { desc = "Generate Setter" })
mapKey("<Leader>rb", refactor.generate_getter_and_setter, "n", { desc = "Generate Getter & Setter" })
mapKey("<Leader>re", refactor.generate_equals, "n", { desc = "Generate equals/hashCode" })
mapKey("<Leader>ro", refactor.generate_tostring, "n", { desc = "Generate toString" })

-- Java test파일 생성 (이동)
mapKey("<Leader>rt", refactor.goto_test, "n", { desc = "Go to Test" })

-- Test (테스트 실행)
mapKey("<Leader>T", "<Cmd>JavaTestRunCurrentClass<CR>", "n", { desc = "Test Current Class" })
mapKey("<Leader>jtc", "<Cmd>JavaTestRunCurrentClass<CR>", "n", { desc = "Run Current Class" })
mapKey("<Leader>jtm", "<Cmd>JavaTestRunCurrentMethod<CR>", "n", { desc = "Run Current Method" })
mapKey("<Leader>jtC", "<Cmd>JavaTestDebugCurrentClass<CR>", "n", { desc = "Debug Current Class" })
mapKey("<Leader>jtM", "<Cmd>JavaTestDebugCurrentMethod<CR>", "n", { desc = "Debug Current Method" })
mapKey("<Leader>jtv", "<Cmd>JavaTestViewLastReport<CR>", "n", { desc = "View Test Result" })

-- Build Tools (빌드 도구)
mapKey("<Leader>jGr", spring.run_gradle_task, "n", { desc = "Run Gradle Task" })
mapKey("<Leader>jMr", spring.run_maven_task, "n", { desc = "Run Maven Task" })

-- version control
mapKey("<Leader>jv", "<Cmd>JavaSettingsChangeRuntime<CR>", "n", { desc = "Version Select" })
-- Java End

-- C++
mapKey("<Leader>Cc", common.c_complie, "n", { desc = "Compile" })
mapKey("<Leader>Cr", common.c_run, "n", { desc = "Run" })
mapKey("<Leader>Cd", common.c_debug, "n", { desc = "Debug" })

-- platformIO
mapKey("<Leader>Pr", "<Cmd>Piorun<CR>", "n", { desc = "PIO build & upload" })
mapKey("<Leader>Pm", "<Cmd>Piomon<CR>", "n", { desc = "PIO monitor" })
mapKey("<leader>Pi", "<Cmd>Pioinit<CR>", "n", { desc = "PIO init" }) -- 터미널 Open

-- neogen
mapKey("<Leader>nd", common.new_doc, "n", { desc = "Documentation" })

-- search File
mapKey("<leader>ff", search.search_by_filetype, { "n", "v" }, { desc = "Find File Type" })
mapKey("<leader>fr", builtin.oldfiles, "n", { desc = "Recent File" })
mapKey("<leader>fw", builtin.live_grep, { "n", "v" }, { desc = "Find Word" })
mapKey("<leader>fb", builtin.buffers, "n", { desc = "Find Buffer" })
mapKey("<leader>ft", "<Cmd>TodoTelescope<CR>", "n", { desc = "Find TODO List" })
mapKey("<leader>fh", builtin.help_tags, "n", { desc = "Help Tags" })

-- LeetCode (인터넷 필요)
if has_internet then
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
end

-- Windsurf (인터넷 필요)
if has_internet then
  mapKey("<F7>", function()
    return vim.fn["codeium#Complete"]()
  end, "i", { desc = "Windsurf" }) -- 제안

  mapKey("<F8>", function()
    return vim.fn["codeium#CycleCompletions"](-1)
  end, "i", { desc = "Previous" }) -- 이전 제안

  mapKey("<F9>", function()
    return vim.fn["codeium#CycleCompletions"](1)
  end, "i", { desc = "Next" }) -- 다음 제안

  mapKey("<F10>", function()
    return vim.fn["codeium#Clear"]()
  end, "i", { desc = "Clear" }) -- 제안 삭제
end

-- Just
mapKey("<leader>Js", "<Cmd>JustSelect<CR>", "n", { desc = "JustSelect" })
mapKey("<leader>JS", "<Cmd>JustStop<CR>", "n", { desc = "JustStop" })

-- http
mapKey("<leader>hr", "<Cmd>Rest run<CR>", "n", { desc = "Rest Run" })
mapKey("<leader>hl", "<Cmd>Rest logs<CR>", "n", { desc = "Rest Logs" })
mapKey("<leader>hc", "<Cmd>Rest cookies<CR>", "n", { desc = "Rest Cookies" })
mapKey("<leader>he", "<Cmd>Telescope rest select_env<CR>", "n", { desc = "Rest Env Select" })

mapKey("<leader>mp", "<Cmd>MarkdownPreviewToggle<CR>", "n", { desc = "Preview Browser" }) -- markdown 미리보기
-- Molten-nvim (Jupyter in Neovim) Start
-- 1. 초기화 및 커널 관리
mapKey("<leader>mi", ":MoltenInit<CR>", "n", { desc = "Initialize Kernel" }) -- 현재 버퍼용 커널 초기화
mapKey("<leader>ms", ":MoltenInit shared<CR>", "n", { desc = "Initialize Shared Kernel" }) -- 이미 실행 중인 커널 공유
mapKey("<leader>mI", ":MoltenInfo<CR>", "n", { desc = "Molten Info" }) -- 커널 상태 및 정보 확인
mapKey("<leader>mr", ":MoltenRestart<CR>", "n", { desc = "Restart Kernel" }) -- 커널 재시작
mapKey("<leader>mq", ":MoltenDeinit<CR>", "n", { desc = "De-initialize Molten" }) -- 커널 및 인스턴스 종료

-- 2. 코드 실행 (Evaluate)
mapKey("<leader>ml", ":MoltenEvaluateLine<CR>", "n", { desc = "Evaluate Line" }) -- 현재 줄 실행
mapKey("<leader>mv", ":<C-u>MoltenEvaluateVisual<CR>gv", "v", { desc = "Evaluate Visual" }) -- 선택 영역 실행 (gv로 영역 유지)
mapKey("<leader>mO", ":MoltenEvaluateOperator<CR>", "n", { desc = "Evaluate Operator" }) -- 연산자 대기 실행
mapKey("<leader>mC", ":MoltenReevaluateCell<CR>", "n", { desc = "Re-evaluate Cell" }) -- 현재 셀 재실행
mapKey("<leader>mS", ":MoltenInterrupt<CR>", "n", { desc = "Stop Kernel" }) -- 실행 중인 코드 강제 중단

-- 3. 결과창 제어 및 포커싱 (Output)
mapKey("<leader>mo", ":MoltenShowOutput<CR>", "n", { desc = "Show Output" }) -- 결과창 열기
mapKey("<leader>mc", ":MoltenHideOutput<CR>", "n", { desc = "Hide Output" }) -- 결과창 숨기기
-- 공식 문서 권장 사항에 따라 noautocmd를 사용하여 결과창으로 포커스 이동
mapKey("<leader>mf", ":noautocmd MoltenEnterOutput<CR>", "n", { desc = "Focus Output Window" })
mapKey("<leader>md", ":MoltenDelete<CR>", "n", { desc = "Delete Cell Output" }) -- 활성화된 셀의 결과 삭제
-- 4. 네비게이션 및 기타
mapKey("<leader>mn", ":MoltenNext<CR>", "n", { desc = "Next Cell" }) -- 다음 셀로 이동
mapKey("<leader>mb", ":MoltenPrev<CR>", "n", { desc = "Previous Cell" }) -- 이전 셀로 이동
mapKey("<leader>mB", ":MoltenOpenInBrowser<CR>", "n", { desc = "Open in Browser" }) -- HTML 결과를 브라우저에서 열기
-- Molten-nvim End

--Python
mapKey("<leader>pv", "<CMD>VenvSelect<CR>", "n", { desc = "Version Select" }) -- 파이썬 버전 선택
