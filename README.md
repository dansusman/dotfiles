# dotfiles
A much more organized repo for all my configs

I've used Nano, Vi, Vim, nvim, Emacs, and tons of IDEs. nvim is the winner for
my uses, though I wish I were an Emacs guy.

## Current Favorite Tools
- [yabai](https://github.com/koekeishiya/yabai): Tiling window manager
- [skhd](https://github.com/koekeishiya/skhd): Configurable keyboard shortcuts (used to control yabai with the keyboard)
- [borders](https://github.com/FelixKratz/JankyBorders): Borders around windows, colored differently when resizing windows via yabai
- [Maccy](https://github.com/p0deje/Maccy): Clipboard manager
- [homerow](https://github.com/nchudleigh/homerow): Navigate anywhere with the keyboard
- [heynote](https://github.com/heyman/heynote): Dev scratchpad
- [grex](https://github.com/pemistahl/grex): Slightly easier regex generation

## Tour
- `nvim-old`: awful, old, vimscript-based dev setup using Plug package manager
- `init.el`: Emacs stuff, not great, somewhat out of date probably
- `nvim1`: slightly better, Lua-only dev setup using Packer package manager
- `nvim`: one-file, newest, Lua-only, simple dev setup via [`kickstart.nvim`](https://github.com/nvim-lua/kickstart.nvim)
- `arken`: Firefox Hardening via [arkenfox/user.js](https://github.com/arkenfox/user.js)
- `chrome`: Currently unused, but Firefox UI tweaking
- `sketchybar`: i3-inspired bottom bar for macOS via [sketchybar](https://github.com/FelixKratz/SketchyBar)
- `zsh`: Shell aliases, theming, utils, etc.
- `.config`: skhd, yabai, Karabiner Elements, etc. configurations

## Installation Steps
These steps only pertain to my newest dev setup, located in `nvim`, exclusively.

1. Clone this repo into home directory
2. Make symlinks from any directory in this repo to your home directory (see a couple examples below)
3. Run `mkdir ~/.config/nvim`
4. Run `ln -s ~/dotfiles/nvim ~/.config/nvim`
5. Open nvim and plugins will start installing
6. Close nvim once the plugins are installed
7. Reopen nvim and let LSPs install

## Bonus Tip for Futureself
If you want add symbolic links to nested folders at nested folder paths, like the following user story, follow this guide.

User X wants to add some `skhd` configuration in the directory `.dotfiles/skhd` and stow it in `~/.config/skhd`. X makes 
a new directory in their clone of this repo, `skhd`, adds their `.skhdrc` file in there, and creates the symlink using:
`stow -t ~/.config ~/.dotfiles/config`. This accounts for nesting so the file structure will match in `~/.config`.

## Accessing Susman Oh My Zsh Theme
`ln -s ~/.dotfiles/zsh/susman.zsh-theme ~/.oh-my-zsh/themes`

## Setting up Zsh in General
`stow ~/.dotfiles/zsh`

## Setting up Sketchybar config
`ln -s ~/.dotfiles/sketchybar ~/.config/sketchybar`

