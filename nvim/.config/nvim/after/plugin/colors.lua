vim.g.susmand_colorscheme = "GruberDarker"

function LetThereBeColor()
    vim.g.gruvbox_contrast_dark = 'hard'
    vim.g.tokyonight_transparent_sidebar = true
    vim.g.tokyonight_transparent = true
    vim.g.gruvbox_invert_selection = '0'
    vim.opt.background = "dark"

    vim.cmd("colorscheme " .. vim.g.susmand_colorscheme)

    local hl = function(thing, opts)
        vim.api.nvim_set_hl(0, thing, opts)
    end

    hl("SignColumn", {
        bg = "none",
    })

    hl("ColorColumn", {
        ctermbg = 0,
        bg = "#555555",
    })

    hl("CursorLineNR", {
        bg = "None"
    })

    -- hl("Normal", {
    --     bg = "none"
    -- })

    hl("LineNr", {
        fg = "#5eacd3"
    })

    hl("netrwDir", {
        fg = "#5eacd3"
    })

    hl("DiffAdd", {
        fg = "#ffdd33",
        bg = "None"
    })

    hl("DiffChange", {
        fg = "#ffdd33",
        bg = "None"
    })

    hl("DiffDelete", {
        fg = "#ffdd33",
        bg = "None"
    })

end

LetThereBeColor()
