return {
    {
        "hrsh7th/nvim-cmp",
        event = { "BufReadPost", "BufNewFile" },
        dependencies = {
            {
                "L3MON4D3/LuaSnip",
                version = "v2.*",
                build = "make install_jsregexp",
            },
            "saadparwaiz1/cmp_luasnip",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "rafamadriz/friendly-snippets",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")

            -- load snippets
            require("luasnip.loaders.from_vscode").lazy_load()

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-u>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.abort(),
                    -- ["<CR>"] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
                    ['<CR>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            local entry = cmp.get_selected_entry()
                            if entry then
                                -- 선택된 항목의 종류가 함수나 생성자인 경우 후처리
                                local completion_item = entry:get_completion_item()
                                local is_function_like = completion_item.kind == cmp.lsp.CompletionItemKind.Function
                                    or completion_item.kind == cmp.lsp.CompletionItemKind.Method
                                    or completion_item.kind == cmp.lsp.CompletionItemKind.Constructor

                                cmp.confirm({ select = false })

                                -- 함수 또는 생성자일 경우 괄호 추가
                                if is_function_like then
                                    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("()<Left>", true, true, true),
                                        'n', true)
                                end
                            else
                                fallback()
                            end
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<Tab>"] = cmp.mapping.select_next_item(),
                    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "buffer",               max_item_count = 10 },
                    { name = "path",                 max_item_count = 10 },
                    { name = "luasnip",              max_item_count = 10 },
                    { name = "cmdline",              max_item_count = 10 },
                    { name = "vim-dadbod-completion" },
                }),
            })

            -- `/` cmdline setup.
            cmp.setup.cmdline({ '/' }, {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = 'buffer' }
                }
            })
            -- `?` cmdline setup.
            cmp.setup.cmdline({ '?' }, {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = 'buffer' }
                }
            })
            -- ':' 명령어 모드에서의 자동 완성 설정 (cmdline)
            cmp.setup.cmdline(":", {
                sources = cmp.config.sources({
                    { name = "path" },   -- 파일 경로 자동 완성
                }, {
                    { name = "cmdline" } -- 명령어 기반 완성
                })
            })
        end,
    },
}
