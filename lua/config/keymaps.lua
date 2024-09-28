local mapKey = require("utils/keyMapper").mapKey

-- Neotree toggle
mapKey("<leader>e", ":Neotree toggle<cr>")

-- pane navigation
mapKey("<C-h>", "<C-w>h") -- left
mapKey("<C-j>", "<C-w>j") -- left
mapKey("<C-k>", "<C-w>k") -- left
mapKey("<C-l>", "<C-w>l") -- left

-- clear search highlight
mapKey("<leader>h", ":nohlsearch<CR>")

-- indent
mapKey("<", "<gv", "v")
mapKey(">", ">gv", "v")

-- split window
mapKey("ss", ":split<Return>", "n")
mapKey("vs", ":vsplit<Return>", "n")
