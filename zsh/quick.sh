#!/usr/bin/env bash
help() {
    echo ""
    echo "Usage: $0 ~filePath~"
    exit 1
}

if [ -z "$1" ]
then
    echo "Invalid input."
    help
fi

osascript ~/xcode.applescript
open $1

