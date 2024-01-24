help() {
    echo ""
    echo "Usage: $0 ~githubHash~"
    echo "\tgithubHash: number of GitHub PR/issue"
    exit 1
}

if [ -z "$1" ]
then
    echo "Invalid input."
    help
fi

open "https://github.com/Ginger-Labs/Notability/pull/$1"
