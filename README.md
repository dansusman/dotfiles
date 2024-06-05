# dotfiles
A much more organized repo for all my configs

I've used Nano, Vi, Vim, nvim, Emacs, and tons of IDEs. nvim is the winner for
my uses, though I wish I were an Emacs guy.

## Tour
- `nvim-old`: awful, old, vimscript-based dev setup using Plug package manager
- `init.el`: Emacs stuff, not great, somewhat out of date probably
- `nvim1`: slightly better, Lua-only dev setup using Packer package manager
- `nvim`: one-file, newest, Lua-only, simple dev setup via [`kickstart.nvim`](https://github.com/nvim-lua/kickstart.nvim)

## Installation Steps
These steps only pertain to my newest dev setup, located in `nvim`, exclusively.

1. Clone this repo into home directory
2. Run `mkdir ~/.config/nvim`
3. Run `ln -s ~/dotfiles/nvim ~/.config/nvim`
4. Open nvim and plugins will start installing
5. Close nvim once the plugins are installed
6. Reopen nvim and let LSPs install

## Bonus Tip for Futureself
If you want add symbolic links to nested folders at nested folder paths, like the following user story, follow this guide.

User X wants to add some `skhd` configuration in the directory `.dotfiles/skhd` and stow it in `~/.config/skhd`. X makes 
a new directory in their clone of this repo, `skhd`, adds their `.skhdrc` file in there, and creates the symlink using:
`stow -t ~/.config ~/.dotfiles/config`. This accounts for nesting so the file structure will match in `~/.config`.
