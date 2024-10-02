local mapKey = require("utils/keyMapper").mapKey

-- Neotree toggle
mapKey("<leader>e", ":Neotree toggle<cr>")

-- pane navigation
mapKey("<C-h>", "<C-w>h") -- left
mapKey("<C-j>", "<C-w>j") -- down
mapKey("<C-k>", "<C-w>k") -- up
mapKey("<C-l>", "<C-w>l") -- right

-- clear search highlight
mapKey("<leader>h", ":nohlsearch<CR>")

-- indent
mapKey("<", "<gv", "v")
mapKey(">", ">gv", "v")

-- split window
mapKey("<leader>ss", ":split<Return>", "n")
mapKey("<leader>vs", ":vsplit<Return>", "n")

-- tab(bar) control
mapKey("gT", "<Cmd>BufferPrevious<CR>")
mapKey("gt", "<Cmd>BufferNext<CR>")
mapKey("t<", "<Cmd>BufferMovePrevious<CR>")
mapKey("t>", "<Cmd>BufferMoveNext<CR>")
mapKey("t1", "<Cmd>BufferGoto 1<CR>")
mapKey("t2", "<Cmd>BufferGoto 2<CR>")
mapKey("t3", "<Cmd>BufferGoto 3<CR>")
mapKey("t4", "<Cmd>BufferGoto 4<CR>")
mapKey("t5", "<Cmd>BufferGoto 5<CR>")
mapKey("t6", "<Cmd>BufferGoto 6<CR>")
mapKey("t7", "<Cmd>BufferGoto 7<CR>")
mapKey("t8", "<Cmd>BufferGoto 8<CR>")
mapKey("t9", "<Cmd>BufferGoto 9<CR>")
mapKey("t0", "<Cmd>BufferLast<CR>")
-- Pin/unpin buffer
-- mapKey("<A-p>", "<Cmd>BufferPin<CR>")
-- Goto pinned/unpinned buffer
--                 :BufferGotoPinned
--                 :BufferGotoUnpinned
-- Close buffer
mapKey("tc", "<Cmd>BufferClose<CR>")
-- Wipeout buffer
--                 :BufferWipeout
-- Close commands
--                 :BufferClosetllButCurrent
--                 :BufferClosetllButPinned
--                 :BufferClosetllButCurrentOrPinned
--                 :BufferCloseBuffersLeft
--                 :BufferCloseBuffersRight
-- Magic buffer-picking mode
-- mapKey("<C-p>", "<Cmd>BufferPick<CR>")
-- Sort automatically by...
mapKey("<Space>tb", "<Cmd>BufferOrderByBufferNumber<CR>")
mapKey("<Space>tn", "<Cmd>BufferOrderByName<CR>")
mapKey("<Space>td", "<Cmd>BufferOrderBytirectory<CR>")
mapKey("<Space>tl", "<Cmd>BufferOrderByLanguage<CR>")
mapKey("<Space>tw", "<Cmd>BufferOrderByWindowNumber<CR>")

-- lsp
mapKey("<leader>rs", ":LspRestart<CR>")
mapKey("K", vim.lsp.buf.hover)
mapKey("gr", "<cmd>Telescope lsp_references<CR>")      -- show lsp references
mapKey("gd", "<cmd>Telescope lsp_definitions<CR>")     -- show lsp definitions
mapKey("gi", "<cmd>Telescope lsp_implementations<CR>") -- show lsp implementations
mapKey("<leader>rn", vim.lsp.buf.rename)               -- smart rename
mapKey("<leader>ca", vim.lsp.buf.code_action)
