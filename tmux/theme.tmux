#!/usr/bin/env bash

# $1: option
# $2: default value
tmux_get() {
	local value
	value="$(tmux show -gqv "$1")"
	[ -n "$value" ] && echo "$value" || echo "$2"
}

# *********************************************************
# Options                                                 *
# *********************************************************
info="#[fg=green]S: #S #[fg=colour214]W: #I #[fg=cyan]P: #P"
git='#(gitmux -cfg $HOME/.gitmux.conf "#{pane_current_path}")'
claude_status='#($HOME/.dotfiles/config/bin/claude-status-summary)'

# Spawn the Claude status daemon if it isn't already running. It watches
# ~/.claude/projects/ and keeps /tmp/claude-status.cache fresh so the
# status-line and sesh-pick don't have to poll on the hot path.
( "$HOME/.dotfiles/tmux/claude-status-daemon" </dev/null >/dev/null 2>&1 & ) 2>/dev/null

color_main=$(tmux_get @tmux_bubbles_color_main '#6B4E00')
color_active=$(tmux_get @tmux_bubbles_color_active '#F5F1E8')
color_grey=$(tmux_get @tmux_bubbles_color_grey '#80766B')
color_light=$(tmux_get @tmux_bubbles_color_light '#181820')
color_dark=$(tmux_get @tmux_bubbles_color_dark '#404D8C')
color_bg=$(tmux_get @tmux_bubbles_color_bg '#F5F1E8')

# *********************************************************
# Status                                                  *
# *********************************************************
tmux set-option -gq status-justify left
tmux set-option -gq status-interval 1
tmux set-option -gq status on
tmux set-option -gq status-fg "$color_light"
tmux set-option -gq status-bg "$color_bg"
tmux set-option -gq status-attr none

# $1: modules
# $2: fg_color
# $3: bg_color
make_bubble() {
	echo "#[fg=$3]#[bg=$color_bg]#[fg=$2]#[bg=$3]$1#[fg=$3]#[bg=$color_bg]"
}

# $1: modules
make_activatable_bubble() {
	local normal_bubble
	local active_bubble
	normal_bubble="$(make_bubble "$1" "$color_active" "$color_grey")"
	active_bubble="$(make_bubble "$1" "$color_active" "$color_grey")"

	echo "#{?client_prefix,$active_bubble,$normal_bubble}"
}

tmux set-option -gq status-right "$(make_bubble " $claude_status " "$color_active" "$color_grey") $(make_activatable_bubble "$git")"
tmux set-option -gq status-left ""
tmux set-option -gq status-left-fg "$color_light"
tmux set-option -gq status-left-bg "$color_bg"
tmux set-option -gq status-left-length 150
tmux set-option -gq status-right-fg "$color_light"
tmux set-option -gq status-right-bg "$color_bg"
tmux set-option -gq status-right-length 150

# *********************************************************
# Window                                                  *
# *********************************************************
tmux set-option -gq window-status-format "#[fg=$color_light,bg=$color_bg,bold] #I:#W "
tmux set-option -gq window-status-current-format "$(make_bubble ' #I:#W ' "$color_active" "$color_grey")"
# *********************************************************
# Others                                                  *
# *********************************************************
tmux set-option -gq mode-style "bg=$color_main,fg=$color_bg,bold"
tmux set-option -gq pane-active-border-style "fg=$color_main,bg=$color_bg"
tmux set-option -gq clock-mode-colour "$color_main"
