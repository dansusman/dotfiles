# Delete Local Branches No Longer in Remote
git config --global alias.bld '!f() { git fetch -p && git branch -vv | awk "/: gone]/{print \$1}" | xargs git branch -D; }; f'
