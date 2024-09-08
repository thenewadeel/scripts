#!/bin/bash

usage() {
    echo "Usage: $0 [-h] [-s search_string] [-f file_list]"
    echo "Searches for a string in a list of files."
    echo ""
    echo "  -h  show this help text"
    echo "  -s  search string"
    echo "  -f  file(s) to search in (default: all files in current directory)"
    exit 1
}

while getopts "hs:f:" opt; do
    case $opt in
    h) usage ;;
    s) search_string="$OPTARG" ;;
    f) file_list="$OPTARG" ;;
    \?) usage ;;
    esac
done

if [ -z "$search_string" ]; then
    echo "Error: -s option is required"
    usage
fi

if [ -z "$file_list" ]; then
    file_list=$(find . -type f)
fi

for file in $file_list; do
    echo "Found in $file"
    grep -ni $search_string $file
done
