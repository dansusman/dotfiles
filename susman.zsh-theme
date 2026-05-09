PROMPT="%(?:%{$FG[106]%}%1{➜%} :%{$fg_bold[red]%}%1{➜%} ) %{$FG[094]%}%c%{$reset_color%}"
PROMPT+=' $(git_prompt_info)'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$FG[106]%}git:(%{$FG[068]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$FG[106]%}) %{$FG[094]%}%1{✗%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$FG[106]%})"
