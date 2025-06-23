local mapKey = require("utils.commonUtils").mapKey
local builtin = require("telescope/builtin")
local common = require("utils.commonUtils")
local search = require("utils.searchUtils")
local codewindow = require("codewindow")

-- Custom mapping Start
mapKey("<leader>cw", common.widthResize, "n", { desc = "Change Width" }) -- 현재 buffer 너비 조정
mapKey("<leader>ch", common.heightResize, "n", { desc = "Change Height" }) -- 현재 buffer 높이 조정
mapKey("<Leader>oD", "<Cmd>DBUIToggle<CR>", "n", { desc = "Database" })
mapKey("<leader>ot", common.toggle_terminal, "n", { desc = "Terminal" }) -- 터미널 Open
mapKey("<leader>ol", "<Cmd>Leet<CR>", "n", { desc = "Leet" }) -- LeetCode Open
mapKey("<leader>om", codewindow.toggle_minimap, "n", { desc = "Mini Map" }) -- minimap Open
mapKey("<leader>os", "<cmd>SymbolsOutline<CR>", "n", { desc = "SymbolsOutline" }) -- SymbolsOutline Open
mapKey("gm", codewindow.toggle_focus, "n", { desc = "Mini Map" }) -- minimap focus
mapKey("<C-Space>", [[<C-\><C-n>]], "t", { desc = "Terminal Escape" }) -- 터미널에서 normal모드 변경
mapKey("<leader>pm", "<Cmd>MarkdownPreviewToggle<CR>", "n", { desc = "Markdown" }) -- markdown 미리보기
mapKey("<leader>vm", "<cmd>MaximizerToggle<CR>", "n", { desc = "Buffer Maximizer" }) -- buffer maximizer
-- Custom mapping End

-- Neotree toggle
mapKey("<leader>e", ":Neotree toggle<cr>", "n", { desc = "Toggle Neotree" })

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
mapKey("<leader>rn", vim.lsp.buf.rename, "n", { desc = "Smart rename" })
mapKey("<leader>ca", vim.lsp.buf.code_action, "n", { desc = "LSP code action" })

-- Git
mapKey("<Leader>gb", "<Cmd>Git blame<CR>", "n", { desc = "Git Blame" })
mapKey("<Leader>gp", "<Cmd>Gitsigns preview_hunk<CR>", "n", { desc = "Preview This Hunk" })
mapKey("<Leader>grh", "<Cmd>Gitsigns reset_hunk<CR>", "n", { desc = "Reset This Hunk" })
mapKey("<Leader>grb", "<Cmd>Gitsigns reset_buffer<CR>", "n", { desc = "Reset This Buffer" })
mapKey("<Leader>gdv", "<Cmd>Gvdiffsplit<CR>", "n", { desc = "Vsplit" })
mapKey("<Leader>gdh", "<Cmd>Ghdiffsplit<CR>", "n", { desc = "Hsplit" })
mapKey("<leader>gg", "<cmd>LazyGit<cr>", "n", { desc = "LazyGit" })

-- neogen
mapKey("<Leader>nd", common.new_doc, "n", { desc = "Documentation" })

-- search File
mapKey("<leader>ff", search.search_by_filetype, "n", { desc = "Find File Type" })
mapKey("<Leader>fe", search.open_buffer_in_neotree, "n", { desc = "Find File Explorer" })
mapKey("<leader>fr", builtin.oldfiles, "n", { desc = "Recent File" })
mapKey("<leader>fw", builtin.live_grep, "n", { desc = "Find Word" })
mapKey("<leader>fb", builtin.buffers, "n", { desc = "Find Buffer" })
mapKey("<leader>ft", "<Cmd>TodoTelescope<CR>", "n", { desc = "Find TODO List" })
mapKey("<leader>fh", builtin.help_tags, "n", { desc = "Help Tags" })
