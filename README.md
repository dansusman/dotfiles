# dotfiles
A much more organized repo for all my configs

I've used Nano, Vi, Vim, nvim, Emacs, and tons of IDEs. nvim is the winner for
my uses, though I wish I were an Emacs guy.

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

## Current Favorite Tools

Here's a running list of things I enjoy using right now. A lot of them are macOS specific, but some are platform agnostic. I should probably make an install script to `brew install` as many of these as possible at some point. Maybe next time I get a new laptop lol.

### Open Source ✅
- [yabai](https://github.com/koekeishiya/yabai): Tiling window manager
- [skhd](https://github.com/koekeishiya/skhd): Configurable keyboard shortcuts (used to control yabai with the keyboard)
- [borders](https://github.com/FelixKratz/JankyBorders): Borders around windows, colored differently when resizing windows via yabai
- [Maccy](https://github.com/p0deje/Maccy): Clipboard manager
- [homerow](https://github.com/nchudleigh/homerow): Navigate anywhere with the keyboard
- [heynote](https://github.com/heyman/heynote): Dev scratchpad
- [grex](https://github.com/pemistahl/grex): Slightly easier regex generation
- [MacMediaKeyForwarder](https://github.com/milgra/macmediakeyforwarder): Prioritize Spotify over Apple Music
- [Gifski](https://github.com/sindresorhus/Gifski): Video to Gif converter
- [Lunar](https://github.com/alin23/Lunar): Display brightness controller
- [noTunes](https://github.com/tombonez/noTunes): Prevent Apple Music from launching
- [BreakTimer](https://github.com/tom-james-watson/breaktimer-app): Reminder to take an eye break every hour
- [Karabiner Elements](https://github.com/pqrs-org/Karabiner-Elements): Remap Fn to Hyper, Ctrl+P/Ctrl+n to Arrow Up/Down
- [zoxide](https://github.com/ajeetdsouza/zoxide): Smarter `cd`
- [ripgrep](https://github.com/BurntSushi/ripgrep): More powerful `grep`
- [exa](https://github.com/ogham/exa): Replacement for `ls`
- [Firefox Dev Edition](https://www.mozilla.org/en-US/firefox/developer/): Hopefully self explanatory at this point, source code [here](https://hg.mozilla.org/mozilla-central/)

### Proprietary ❌
- [Cleanshot X](https://cleanshot.com/): Better screenshotting
- [Choosy Browser](https://choosy.app/): Send certain links to certain browsers
- [1Password](https://1password.com/): Password manager
