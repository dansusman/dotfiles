## Karabiner Settings

This directory holds my settings for Karabiner Elements. The general workflow is as follows:

1. Clone https://github.com/dansusman/karabiner into `.dotfiles/config/karabiner` (the directory holding this README)
2. cd into the new karabiner directory 
3. Define rules in `rules.ts`
4. Run `yarn run watch` to generate new `karabiner.json`
5. Copy the new `karabiner.json` into `.dotfiles/config/karabiner` (the directory holding this README)
6. Observe changes
7. Navigate to https://ke-complex-modifications.pqrs.org/#om_fn_to_hyper
8. Import that rule into Karabiner Elements and click "Enable All"


## Overview

My keyboard remaps are set up in logic sublayers.

- `Fn + {key}`: Use `aerospace` settings to control windows
    - See `../aerospace/aerospace.toml` for more information
- `Caps + {key}`: Use `karabiner` settings to control various things:
    - `b`: *B*rowse (open links in browser)
    - `o`: *O*pen applications
    - `s`: *S*ystem controls (volume, brightness, etc.)
    - `v`: mo*V*e: Remap hjkl to arrows, page down/up, etc.
    - `c`: musi*C*: Play/pause, forward, rewind
- `d`: Mouse key mode sublayer
    - `f`: Fast mode
    - `hjkl`: Move mouse left, down, up, left
    - `v`: Left click
    - `b`: Middle click
    - `n`: Right click
    - `s`: Scroll mode
    - `g`: Slow mode
    - See more at https://ke-complex-modifications.pqrs.org/#mouse_keys_mode_v4

