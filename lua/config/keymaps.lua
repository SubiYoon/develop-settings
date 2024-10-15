local mapKey = require("utils/keyMapper").mapKey

-- Custom mapping Start
mapKey("<leader>fq", '', "n", { desc = "Find Query File" })
mapKey("<leader>fqm", '<Cmd>lua require("utils.searchUtils").open_mapper_xml()<CR>', "n",
  { desc = "Move to the mapper with the cursor word(id)" })
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

-- Split window
mapKey("<leader>ss", ":split<Return>", "n", { desc = "Horizontal split" })
mapKey("<leader>vs", ":vsplit<Return>", "n", { desc = "Vertical split" })

-- Tab (bar) control
mapKey("gT", "<Cmd>BufferPrevious<CR>", "n", { desc = "Previous buffer" })
mapKey("gt", "<Cmd>BufferNext<CR>", "n", { desc = "Next buffer" })
mapKey("<leader>t", "", "n", { desc = "Tab" })
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
mapKey("<leader>tc", "<Cmd>BufferClose<CR>", "n", { desc = "Close current buffer" })
mapKey("<leader>tac", "<Cmd>BufferCloseAllButCurrent<CR>", "n", { desc = "Close all buffer" })
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
mapKey("<leader>rs", ":LspRestart<CR>", "n", { desc = "Restart LSP" })
mapKey("K", vim.lsp.buf.hover, "n", { desc = "LSP hover" })
mapKey("gr", "<cmd>Telescope lsp_references<CR>", "n", { desc = "Show LSP references" })
mapKey("gd", "<cmd>Telescope lsp_definitions<CR>", "n", { desc = "Show LSP definitions" })
mapKey("gi", "<cmd>Telescope lsp_implementations<CR>", "n", { desc = "Show LSP implementations" })
mapKey("<leader>rn", vim.lsp.buf.rename, "n", { desc = "Smart rename" })
mapKey("<leader>ca", vim.lsp.buf.code_action, "n", { desc = "LSP code action" })

-- Debug
mapKey('<F7>', function() require('dap').step_into() end, "n", { desc = "Debug: Step into" })
mapKey('<F8>', function() require('dap').step_over() end, "n", { desc = "Debug: Step over" })
mapKey('<F9>', function() require('dap').continue() end, "n", { desc = "Debug: Continue" })
mapKey('<F10>', function() require('dap').step_back() end, "n", { desc = "Debug: Step back" })
mapKey('<Leader>d', "", "n", { desc = "Debug" })
mapKey('<Leader>dt', function() require('dapui').toggle() end, "n", { desc = "Toggle debug UI" })
mapKey('<Leader>dd', function() require('dap').toggle_breakpoint() end, "n", { desc = "Debug: Toggle breakpoint" })
mapKey('<Leader>dq', function() require('dap').terminate() end, "n", { desc = "Debug: Terminate" })
mapKey('<Leader>dbm', function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end, "n",
  { desc = "Debug: Set log point" })
mapKey('<Leader>dro', function() require('dap').repl.open() end, "n", { desc = "Open debug REPL" })
mapKey('<Leader>drl', function() require('dap').run_last() end, "n", { desc = "Run last debug session" })
mapKey('<Leader>dh', function() require('dap.ui.widgets').hover() end, "v", { desc = "Debug: Hover" })
mapKey('<Leader>dp', function() require('dap.ui.widgets').preview() end, "v", { desc = "Debug: Preview" })
mapKey('<Leader>df', function()
  local widgets = require('dap.ui.widgets')
  widgets.centered_float(widgets.frames)
end, "n", { desc = "Debug: Show frames" })
mapKey('<Leader>ds', function()
  local widgets = require('dap.ui.widgets')
  widgets.centered_float(widgets.scopes)
end, "n", { desc = "Debug: Show scopes" })

-- Git
local git = require('utils.gitUtils')
mapKey('<Leader>gc', "", "n", { desc = "Git Command" })
mapKey('<Leader>gca', function() git.gitAdd() end, "n", { desc = "Git Add" })
mapKey('<Leader>gcc', function() git.gitCommit() end, "n", { desc = "Git Commit" })
mapKey('<Leader>gcp', function() git.gitPush() end, "n", { desc = "Git Push" })
mapKey('<Leader>gcr', function() git.gitReset() end, "n", { desc = "Git Reset" })
mapKey('<Leader>gcR', function() git.gitResetAdd() end, "n", { desc = "Git Restore staged" })
mapKey('<Leader>g', "", "n", { desc = "Git" })
mapKey('<Leader>gp', "<Cmd>Gitsigns preview_hunk<CR>", "n", { desc = "Preview This Hunk" })
mapKey('<Leader>gr', "", "n", { desc = "Reset" })
mapKey('<Leader>grh', "<Cmd>Gitsigns reset_hunk<CR>", "n", { desc = "Reset This Hunk" })
mapKey('<Leader>grb', "<Cmd>Gitsigns reset_buffer<CR>", "n", { desc = "Reset This Buffer" })
mapKey('<Leader>gd', "", "n", { desc = "Diff" })
mapKey('<Leader>gdv', "<Cmd>Gvdiffsplit<CR>", "n", { desc = "Vsplit" })
mapKey('<Leader>gdh', "<Cmd>Ghdiffsplit<CR>", "n", { desc = "Hsplit" })
