syntax on

"SETTINGS
set path+=**
" Nice menu when typing :find
set wildmode=longest,list,full
set wildmenu
" Ignore files
set wildignore+=*.pyc
set wildignore+=*_build/*
set wildignore+=**/coverage/*
set wildignore+=**/node_modules/*
set wildignore+=**/android/*
set wildignore+=**/ios/*
set wildignore+=**/.git/*

set mouse=a
set exrc
set nohlsearch
set hidden
set noerrorbells
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set nu
set relativenumber
set nowrap
set noswapfile
set nobackup
set ignorecase
set smartcase
set undodir=~/.vim/undodir
set undofile
set incsearch
set backspace=indent,eol,start
set termguicolors
set scrolloff=8
set noshowmode
set completeopt=menuone,noinsert,noselect
set signcolumn=yes
set list
set listchars=tab:▸\ ,trail:·

"Give more space for displaying messages.
set cmdheight=2

set colorcolumn=80

"PLUGINS

call plug#begin('~/.vim/plugged')

Plug 'gruvbox-community/gruvbox'
Plug 'tpope/vim-fugitive'
Plug 'darrikonn/vim-gofmt'
Plug 'vim-utils/vim-man'
Plug 'mbbill/undotree'
Plug 'tpope/vim-commentary'
Plug 'ms-jpq/coq_nvim'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'ThePrimeagen/git-worktree.nvim'

" Telescope stuff
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'
Plug 'sharkdp/fd'
Plug 'BurntSushi/ripgrep'

call plug#end()

lua require("susmand")

"COLORS AND THINGS

colorscheme gruvbox
set background=dark
hi Normal guibg=NONE


let loaded_matchparen = 1
let mapleader = " "

"REMAPS

map gf :edit <cfile><CR>

nnoremap <Leader><CR> :so ~/.config/nvim/init.vim<CR>
nnoremap <Leader>+ :vertical resize +5<CR>
nnoremap <Leader>- :vertical resize -5<CR>
nnoremap <Leader>u :UndotreeToggle<CR>
nnoremap <Leader>pv :Vex<CR>

" delete without yanking
nnoremap <leader>d "_d
vnoremap <leader>d "_d

" replace currently selected text with default register
" without yanking it
nnoremap <leader>p "_diwP

" other godly remaps
nnoremap <leader>y "+y
vnoremap <leader>y "+y
nnoremap <leader>Y gg"+yG

nnoremap <leader>d "_d
vnoremap <leader>d "_d

nnoremap <leader>x :silent !chmod +x %<CR>

" Moving text
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv
inoremap <C-j> <esc>:m .+1<CR>==
inoremap <C-k> <esc>:m .-2<CR>==
nnoremap <leader>j :m .+1<CR>==
nnoremap <leader>k :m .-2<CR>==

nnoremap Y yg$
nnoremap n nzzzv
nnoremap N Nzzzv
nnoremap J mzJ`z

" undo break points
inoremap , ,<c-g>u
inoremap . .<c-g>u
inoremap ! !<c-g>u
inoremap ? ?<c-g>u

" Reselect visual selection after indenting
vnoremap < <gv
vnoremap > >gv

nmap <leader>x :!open %<CR><CR>

"FUNCTIONS
