# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

prepend_path() {
  [[ ! -d "$1" ]] && return

  path=(
      $1
      $path
  )
}

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
prepend_path $HOME/bin

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="susman"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# Caution: this setting can cause issues with multiline prompts (zsh 5.7.1 and newer seem to work)
# See https://github.com/ohmyzsh/ohmyzsh/issues/5765
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(xcode)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
source ~/.zsh_profile

######### ALIASES ####################
alias vim=nvim
alias am="open -a 'Activity Monitor'"
alias slack="open -a Slack"
alias pb="open -a Paintbrush"
alias c="clear"
alias xcode="open -a Xcode"
function jump {
    location=$1
    file=$2
    str="/Users/danielsusman/School/three_one/"
    str+="${location}/"
    str+="${file}"
    echo $str
    code $str
}

alias gs="git status"
alias gd="git diff"
alias ga="git add -A"
alias gcm="git commit -m"
alias gp="git pull"
alias gco="git checkout"
alias rg="rg --hidden"
alias fj=mkcdir
alias zig=/Users/danielsusman/util/zig/zig/build/stage3/bin/zig
alias ll="eza -la"
# alias uuidgen='uuidgen | tr "[:upper:]" "[:lower:]"'
alias ppp="~/githubOpen.sh $1"
alias qqq="~/githubSearch.sh $*"
alias bt="swap"
alias bk="git checkout -"
alias qu="~/quick.sh $1"
alias q="qu Notability.xcworkspace"
alias ghp="gh pr checkout"
alias g="gitu"
alias checkout="gh pr ls -L 100 | fzf | sed -E 's/^([0-9]+).*/\1/' | xargs gh pr checkout"
alias re="gh dash"
alias cdr='cd "$(git rev-parse --show-toplevel)"'
alias gsm="generate-slack-msg"
setopt completealiases

function sesh-sessions() {
  {
    exec </dev/tty
    exec <&1
    local session
    session=$(sesh list -i | gum filter --limit 1 --no-sort --fuzzy --placeholder "Pick a sesh" --height 50 --prompt='⚡')
    zle reset-prompt > /dev/null 2>&1 || true
    [[ -z "$session" ]] && return
    sesh connect $session
  }
}

zle     -N             sesh-sessions
bindkey -M emacs '\es' sesh-sessions
bindkey -M vicmd '\es' sesh-sessions
bindkey -M viins '\es' sesh-sessions

function shortcut {
    default="/Users/danielsusman/work/Notability"
    \cd ${2:-$default}
    pkill -x Xcode
    git checkout $1
    git pull
    open Notability.xcworkspace
}

function swap {
    pkill -x Xcode
    \cd "/Users/danielsusman/work/butler/Notability"
    sleep 1
    open Notability.xcworkspace
}

mkcdir ()
{
    if [ "$1" != "" ]
    then
        mkdir -p -- "$1" &&
        cd -P -- "$1"
    else
        cd
    fi
}

# opam configuration
[[ ! -r /Users/danielsusman/.opam/opam-init/init.zsh ]] || source /Users/danielsusman/.opam/opam-init/init.zsh  > /dev/null 2> /dev/null
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"

# ruby config
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export GEM_HOME=$HOME/.gem
export PATH=$GEM_HOME/bin:$PATH
eval "$(zoxide init --cmd z zsh)"
source $(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

export PATH=$PATH:~/Developer/notability/staging/Tools/SwiftLint

# Load environment variables from .env file
if [[ -f ~/.dotfiles/zsh/.env ]]; then
  source ~/.dotfiles/zsh/.env
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Created by `pipx` on 2025-05-17 15:11:37
export PATH="$PATH:/Users/danielsusman/.local/bin"
export PATH="$PATH:/Users/danielsusman/.cargo/bin"
export XDG_CONFIG_HOME="$HOME/.config"
