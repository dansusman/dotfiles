local opt = vim.opt

opt.number = true
opt.relativenumber = true

opt.splitright = true
opt.splitbelow = true

opt.mouse = "a"

opt.breakindent = true

opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.undodir = os.getenv("HOME") .. "/.vim/undodir"

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
opt.ignorecase = true
opt.smartcase = true

-- Keep signcolumn on by default
opt.signcolumn = "yes"
opt.isfname:append("@-@")

-- Decrease update time
opt.updatetime = 250

--- Give more space for displaying messages.
opt.cmdheight = 1

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
opt.timeoutlen = 300

-- Display whitespace
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

opt.inccommand = "split" -- Preview substitutions live, as you type!
opt.cursorline = true    -- Show which line your cursor is on
opt.scrolloff = 10       -- Minimal number of screen lines to keep above and below the cursor.
opt.hlsearch = true      -- search highlights

-- Don't have `o` add a comment
opt.formatoptions:remove "o"
