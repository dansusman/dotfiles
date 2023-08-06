require("susmand.set")
require("susmand.packer")
require("susmand.statusline")

local augroup = vim.api.nvim_create_augroup
SusmanGroup = augroup('Susman', {})
local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup('HighlightYank', {})

autocmd('TextYankPost', {
    group = yank_group,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 40,
        })
    end,
})

autocmd({"BufEnter", "BufWinEnter", "WinEnter"}, {
    group = SusmanGroup,
    pattern = '*',
    command = "setlocal statusline=%!v:lua.Statusline.active()",
})

autocmd({"WinLeave", "BufLeave"}, {
    group = SusmanGroup,
    pattern = '*',
    command = "setlocal statusline=%!v:lua.Statusline.inactive()",
})

autocmd({"BufWritePre"}, {
    group = SusmanGroup,
    pattern = "*",
    command = "%s/\\s\\+$//e",
})

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
