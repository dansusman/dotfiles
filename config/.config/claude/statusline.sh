#!/bin/bash

# Claude Code statusline script
# Displays: [progress] XX%  +added -removed          Xs  $X.XX

input=$(cat)

# Debug: log input to see available fields (remove when done)
echo "$input" >> /tmp/statusline-debug.json

# ANSI color codes
G=$'\033[92m'  # green
Y=$'\033[93m'  # yellow
D=$'\033[90m'  # gray
R=$'\033[91m'  # red
Z=$'\033[0m'   # reset

# Cost in USD
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
cost_fmt=$(printf "%.2f" "$cost")

# API duration in seconds
api_ms=$(echo "$input" | jq -r '.cost.total_api_duration_ms // 0')
api_sec=$(printf "%.2f" "$(echo "scale=2; $api_ms / 1000" | bc)")

# Lines added/removed
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

# Context usage with progress bar
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
context_bar=""
left_len=0

if [ -n "$used" ]; then
    used_int=$(printf "%.0f" "$used")

    # Color based on usage: 0-50% green, 50-80% yellow, 80-100% red
    if [ "$used_int" -ge 80 ]; then
        c="$R"
    elif [ "$used_int" -ge 50 ]; then
        c="$Y"
    else
        c="$G"
    fi

    # Build progress bar (10 chars inner)
    partials=(' ' '▏' '▎' '▍' '▌' '▋' '▊' '▉')

    full_blocks=$((used_int / 10))
    remainder=$((used_int % 10))
    partial_idx=$((remainder * 8 / 10))

    bar=""
    for ((i=0; i<full_blocks && i<10; i++)); do
        bar+="█"
    done

    if [ $full_blocks -lt 10 ]; then
        bar+="${partials[$partial_idx]}"
        empty_count=$((9 - full_blocks))
        for ((i=0; i<empty_count; i++)); do
            bar+=" "
        done
    fi

    context_bar="${D}[${Z}${c}${bar}${Z}${D}]${Z} ${c}${used_int}%${Z}"
    # Length: [ + 10 + ] + space + percentage + %
    left_len=$((14 + ${#used_int}))
fi

# Build left side: context + lines
left="${context_bar}  ${G}+${lines_added}${Z} ${R}-${lines_removed}${Z}"
left_len=$((left_len + 3 + ${#lines_added} + 2 + ${#lines_removed}))

# Build right side: duration + cost
right="${D}${api_sec}s${Z}  ${D}\$${Z}${cost_fmt}"
right_len=$((${#api_sec} + 1 + 2 + 1 + ${#cost_fmt}))

# Calculate padding for right alignment
cols=$(tput cols 2>/dev/null || echo 80)
pad=$((cols - left_len - right_len))
[ "$pad" -lt 1 ] && pad=1

printf "%b%*s%b" "$left" "$pad" "" "$right"
