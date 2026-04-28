#!/bin/bash

# Claude Code statusline script
# Single line: +NN -MM  [bar]  XX%   Xs   $X.XX   Model Name

input=$(cat)

# ANSI color codes
G=$'\033[92m'  # green
Y=$'\033[93m'  # yellow
D=$'\033[90m'  # gray
R=$'\033[91m'  # red
B=$'\033[94m'  # blue
Z=$'\033[0m'   # reset

# Model display name (right side, gray)
model=$(echo "$input" | jq -r '.model.display_name // .model.id // "Claude"')

# Cost in USD
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
cost_fmt=$(printf '$%.2f' "$cost")

# API duration in seconds
api_ms=$(echo "$input" | jq -r '.cost.total_api_duration_ms // 0')
api_sec=$(printf "%.2f" "$(echo "scale=2; $api_ms / 1000" | bc)")

# Lines added/removed
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

# Context usage percentage
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Terminal width — try sources in priority order; first positive integer wins
cols=$(tmux display-message -p '#{client_width}' 2>/dev/null)
if ! [[ "$cols" =~ ^[1-9][0-9]*$ ]]; then
    cols="$COLUMNS"
fi
if ! [[ "$cols" =~ ^[1-9][0-9]*$ ]]; then
    cols=$(tput cols 2>/dev/null)
fi
if ! [[ "$cols" =~ ^[1-9][0-9]*$ ]]; then
    cols=80
fi

# Apply safety margin (39) to stay well inside Claude Code's render area
cols=$(( cols - 39 ))
[ "$cols" -lt 40 ] && cols=40

# ── SINGLE LINE: +added -removed  [bar]  XX%   Xs  $X.XX  Model ─────────────

# Right-side fixed portion (no bar): "  Xs  $X.XX  Model"
right_plain="  ${api_sec}s  ${cost_fmt}  ${model}"
right_len=${#right_plain}
right_colored="  ${B}${api_sec}s${Z}  ${B}${cost_fmt}${Z}  ${D}${model}${Z}"

# Left-side fixed portion: "+NN -MM  "
left_plain="+${lines_added} -${lines_removed}  "
left_len=${#left_plain}
left_colored="${G}+${lines_added}${Z} ${R}-${lines_removed}${Z}  "

if [ -n "$used" ]; then
    used_int=$(printf "%.0f" "$used")

    if [ "$used_int" -ge 80 ]; then
        c="$R"
    elif [ "$used_int" -ge 50 ]; then
        c="$Y"
    else
        c="$G"
    fi

    # Bar section: [<bar>]  XX%
    # Visible overhead for bar section: 1([) + 1(]) + 2(spaces) + len(pct_label)
    pct_label="${used_int}%"
    bar_section_overhead=$(( 1 + 1 + 2 + ${#pct_label} ))

    bar_width=$(( cols - left_len - bar_section_overhead - right_len ))
    [ "$bar_width" -lt 4 ] && bar_width=4

    partials=(' ' '▏' '▎' '▍' '▌' '▋' '▊' '▉')

    full_blocks=$(( used_int * bar_width / 100 ))
    remainder=$(( (used_int * bar_width) % 100 ))
    partial_idx=$(( remainder * 8 / 100 ))

    bar=""
    for ((i=0; i<full_blocks && i<bar_width; i++)); do
        bar+="█"
    done

    if [ "$full_blocks" -lt "$bar_width" ]; then
        bar+="${partials[$partial_idx]}"
        empty_count=$(( bar_width - full_blocks - 1 ))
        for ((i=0; i<empty_count; i++)); do
            bar+=" "
        done
    fi

    bar_section="${D}[${Z}${c}${bar}${Z}${D}]${Z}  ${c}${pct_label}${Z}"
else
    bar_section=""
fi

printf "%b" "${left_colored}${bar_section}${right_colored}"
