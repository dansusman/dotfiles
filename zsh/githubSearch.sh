help() {
    echo ""
    echo "Usage: $0 ~searchQuery~"
    echo "\tsearchQuery: text for which you'd like to hunt"
    exit 1
}

if [ -z "$1" ]
then
    echo "Invalid input."
    help
fi

str="'$*'"

open "https://github.com/Ginger-Labs/Notability/issues?q=is:issue+is:open+$str"
