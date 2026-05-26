#!/bin/bash

# Claude Code statusline — 3-line layout (Nerd Font icons)
#   L1: <wide ctx dot-bar>  NN% ctx (NNk tok)
#   L2:  dir   branch   model    effort    thinking    cost    +A -R
#   L3: session <dots> NN%  reset  ·  weekly <dots> NN%  reset

input=$(cat)

# ── colors ──────────────────────────────────────────────────────────────────
G=$'\033[92m'   # green
Y=$'\033[93m'   # yellow
D=$'\033[90m'   # dim
R=$'\033[91m'   # red
B=$'\033[94m'   # blue
C=$'\033[96m'   # cyan
M=$'\033[95m'   # magenta
W=$'\033[97m'   # white
Z=$'\033[0m'    # reset

# ── nerd-font icons ─────────────────────────────────────────────────────────
I_FOLDER=$''      #
I_BRANCH=$''      #
I_ROBOT=$'󰚩'       #
I_BOLT=$''        #
I_THINK=$''       #  (lightbulb)
I_AGENT=$''       #
I_COST=$''        #  (dollar)
I_RESET=$''       #

# ── jq helpers ──────────────────────────────────────────────────────────────
j() { echo "$input" | jq -r "$1 // empty"; }

# ── fields ──────────────────────────────────────────────────────────────────
model=$(j '.model.display_name // .model.id // "Claude"')
cwd=$(j '.workspace.current_dir')
agent=$(j '.agent.name')
effort=$(j '.effort.level')
thinking=$(j '.thinking.enabled')

cost=$(j '.cost.total_cost_usd')
cost_fmt=$(printf '$%.2f' "${cost:-0}")
lines_added=$(j '.cost.total_lines_added')
lines_removed=$(j '.cost.total_lines_removed')

ctx_pct=$(j '.context_window.used_percentage')
ctx_input_tokens=$(j '.context_window.total_input_tokens')

five_pct=$(j '.rate_limits.five_hour.used_percentage')
five_reset=$(j '.rate_limits.five_hour.resets_at')
week_pct=$(j '.rate_limits.seven_day.used_percentage')
week_reset=$(j '.rate_limits.seven_day.resets_at')

# ── home-relative path ──────────────────────────────────────────────────────
short_path() {
    local p="$1"
    [ -z "$p" ] && { echo "?"; return; }
    case "$p" in
        "$HOME") echo "~" ;;
        "$HOME"/*) echo "~/${p#$HOME/}" ;;
        *) echo "$p" ;;
    esac
}

# ── git branch (with dirty marker) ──────────────────────────────────────────
git_branch=""
if [ -n "$cwd" ] && [ -d "$cwd" ]; then
    git_branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
    if [ -n "$git_branch" ]; then
        if [ -n "$(git -C "$cwd" status --porcelain 2>/dev/null | head -1)" ]; then
            git_branch="${git_branch}*"
        fi
    fi
fi

# ── dot bar ─────────────────────────────────────────────────────────────────
make_dots() {
    local pct_int="$1" color="$2" slots="$3"
    local filled=$(( (pct_int * slots + 50) / 100 ))
    [ "$filled" -gt "$slots" ] && filled=$slots
    [ "$filled" -lt 0 ] && filled=0
    local dots="" i
    for ((i=0; i<filled; i++)); do dots+="●"; done
    for ((i=filled; i<slots; i++)); do dots+="○"; done
    printf "%s%s%s" "$color" "$dots" "$Z"
}

pct_color() {
    local pct_int="$1"
    if [ "$pct_int" -ge 80 ]; then echo "$R"
    elif [ "$pct_int" -ge 50 ]; then echo "$Y"
    else echo "$G"
    fi
}

# ── reset-time formatter ────────────────────────────────────────────────────
format_reset() {
    local resets_at="$1"
    [ -z "$resets_at" ] || [ "$resets_at" = "null" ] && return
    local now_epoch
    now_epoch=$(date +%s)
    if [ "$resets_at" -le "$now_epoch" ]; then
        echo "now"
        return
    fi
    local today_ord reset_ord day_delta
    today_ord=$(date '+%Y%j')
    reset_ord=$(date -r "$resets_at" '+%Y%j')
    day_delta=$(( 10#${reset_ord} - 10#${today_ord} ))
    local time_part
    time_part=$(date -r "$resets_at" '+%-I:%M%p' | tr '[:upper:]' '[:lower:]')
    case "$day_delta" in
        0) echo "today $time_part" ;;
        1) echo "tomorrow $time_part" ;;
        [2-6]) echo "$(date -r "$resets_at" '+%a' | tr '[:upper:]' '[:lower:]') $time_part" ;;
        *) echo "$(date -r "$resets_at" '+%b %-d' | tr '[:upper:]' '[:lower:]') $time_part" ;;
    esac
}

# ── token formatter ─────────────────────────────────────────────────────────
fmt_tok() {
    awk -v t="$1" 'BEGIN{
        if (t >= 1000000) printf "%.1fM", t/1000000;
        else if (t >= 1000) printf "%.0fk", t/1000;
        else printf "%d", t;
    }'
}

# ── LINE 1: wide context bar ────────────────────────────────────────────────
line1=""
if [ -n "$ctx_pct" ]; then
    ctx_int=$(printf "%.0f" "$ctx_pct")
    if [ -n "$ctx_input_tokens" ] && [ "$ctx_input_tokens" -gt 140000 ] 2>/dev/null; then
        ctx_color="$R"
    else
        ctx_color=$(pct_color "$ctx_int")
    fi
    dots=$(make_dots "$ctx_int" "$ctx_color" 30)
    tok_label=""
    if [ -n "$ctx_input_tokens" ] && [ "$ctx_input_tokens" -gt 0 ] 2>/dev/null; then
        tok_label=" ${D}($(fmt_tok "$ctx_input_tokens") tok)${Z}"
    fi
    line1="${dots} ${ctx_color}${ctx_int}%${Z} ${D}ctx${Z}${tok_label}"
fi

# ── LINE 2: identity + cost + lines ─────────────────────────────────────────
parts=()
parts+=("${B}${I_FOLDER} $(short_path "$cwd")${Z}")

if [ -n "$git_branch" ]; then
    case "$git_branch" in
        *\*) br_color="$Y" ;;
        *)   br_color="$M" ;;
    esac
    parts+=("${br_color}${I_BRANCH} ${git_branch}${Z}")
fi

parts+=("${C}${I_ROBOT} ${model}${Z}")

if [ -n "$effort" ]; then
    case "$effort" in
        low)    e_color="$D" ;;
        medium) e_color="$G" ;;
        high)   e_color="$Y" ;;
        xhigh|max) e_color="$R" ;;
        *)      e_color="$W" ;;
    esac
    parts+=("${e_color}${I_BOLT} ${effort}${Z}")
fi

if [ "$thinking" = "true" ]; then
    parts+=("${M}${I_THINK} thinking${Z}")
fi

if [ -n "$agent" ]; then
    parts+=("${C}${I_AGENT} ${agent}${Z}")
fi

parts+=("${Y}${I_COST} ${cost_fmt}${Z}")

if [ -n "$lines_added" ] || [ -n "$lines_removed" ]; then
    la=${lines_added:-0}
    lr=${lines_removed:-0}
    if [ "$la" != "0" ] || [ "$lr" != "0" ]; then
        parts+=("${G}+${la}${Z} ${R}-${lr}${Z}")
    fi
fi

line2=""
for p in "${parts[@]}"; do
    [ -n "$line2" ] && line2+="  "
    line2+="$p"
done

# ── LINE 3: session + weekly rate limits ────────────────────────────────────
render_limit() {
    local label="$1" pct="$2" resets_at="$3"
    [ -z "$pct" ] && return
    local pct_int color dots reset_fmt
    pct_int=$(printf "%.0f" "$pct")
    color=$(pct_color "$pct_int")
    dots=$(make_dots "$pct_int" "$color" 10)
    reset_fmt=$(format_reset "$resets_at")
    local out="${D}${label}${Z} ${dots} ${color}${pct_int}%${Z}"
    [ -n "$reset_fmt" ] && out+=" ${D}${I_RESET} ${reset_fmt}${Z}"
    printf "%s" "$out"
}

line3=""
if [ -n "$five_pct" ]; then
    line3+=$(render_limit "session" "$five_pct" "$five_reset")
fi
if [ -n "$five_pct" ] && [ -n "$week_pct" ]; then
    line3+="  ${D}·${Z}  "
fi
if [ -n "$week_pct" ]; then
    line3+=$(render_limit " weekly" "$week_pct" "$week_reset")
fi

# ── output ──────────────────────────────────────────────────────────────────
out=""
[ -n "$line1" ] && out+="$line1"
[ -n "$line2" ] && { [ -n "$out" ] && out+=$'\n'; out+="$line2"; }
[ -n "$line3" ] && { [ -n "$out" ] && out+=$'\n'; out+="$line3"; }
printf "%b" "$out"
