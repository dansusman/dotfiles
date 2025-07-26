-- Clear search highlights on escape
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostics
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

--  Use CTRL+<hjkl> to switch between windows
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
vim.keymap.set("n", "<C-y>", "mmyyp`mj", { desc = "Duplicate line and keep cursor position" })

vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Word swap remaps
local swap = require("custom.swap")
vim.keymap.set("n", "<leader>gw", function() swap.swap_words(1, "first") end,
	{ desc = "Swap current word with next, cursor on first" })
vim.keymap.set("n", "<leader>gW", function() swap.swap_words(-1, "second") end,
	{ desc = "Swap current word with previous, cursor on second" })
vim.keymap.set("n", "<leader>gs", function() swap.swap_words(1, "second") end,
	{ desc = "Swap current word with next, cursor on second" })
vim.keymap.set("n", "<leader>gS", function() swap.swap_words(-1, "first") end,
	{ desc = "Swap current word with previous, cursor on first" })

local open_xcode = require("custom.open").open_xcode
-- Set up the keybinding
vim.keymap.set('n', '<leader>ox', open_xcode, {
	desc = 'Open Xcode in current working directory',
	silent = true
})

-- Keybinding to insert current date in ISO 8601 format
vim.keymap.set('n', '<leader>d', function()
  local date = os.date('%Y-%m-%dT%H:%M:%S%z')
  date = date:gsub('(%d%d)$', ':%1')
  vim.api.nvim_put({date}, 'c', true, true)
end, { desc = 'Insert current date in ISO 8601 format' })
