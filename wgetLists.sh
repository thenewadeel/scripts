#!/bin/bash
if [ -z "$1" ]; then
    echo 'no input given'
else
    # input=$1
    # "/home/gg/dev/scripts/jslibs"
    printf 'Getting all one by one\n'
    # printf "==================================================\n"
    while IFS= read -r line; do
        printf "==================================================\n"
        echo "Getting ... ${line:(-50)}"
        printf "==================================================\n"
        #  wget to download, nc = no-clobber (don't download if file exists)
        wget -c --tries=0 "$line"
    done <"$1"
fi
