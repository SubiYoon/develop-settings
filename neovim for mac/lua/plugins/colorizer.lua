return {
    'norcalli/nvim-colorizer.lua',
    config = function()
        -- mode : background(배경), foreground(글자)
        -- name : yellow, red, green ... active Y/N
        -- rgb_Fn : rgb(...) active Y/N
        require 'colorizer'.setup({
                'css',
                'javascript',
                'html',
                'lua',
                'java',
                -- html = { mode = 'background',  names = false,  rgb_fn = true,  },
            },
            { mode = 'background' })
    end
}
