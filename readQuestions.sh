#!/bin/bash
if [ -z "$1" ]; then
    echo 'no input given'
else
    # input=$1
    # "/home/gg/dev/scripts/jslibs"
    printf 'Getting lines one by one\n'
    # printf "==================================================\n"
    question=""
    answer=""
    while read -r line; do
        # for word in $line
        # do
        quest="^[0-9]."
        if [[ $line =~ $quest ]]; then
            if [[ $question == "" ]]; then
                echo 'start'
            else
                printf "\n$question ," >>test.csv
                printf "%q" "$answer" >>test.csv
                # printf "\n" >>test.csv
            fi
            question=${line}
            answer=""
            printf "NUM \n"
        else
            answer+="\n$line"
            # printf "$line"
        fi

        # break;
        # done
        # printf "==================================================\n"
        # echo "Getting ... ${line:(-50)}"
        # printf "==================================================\n"
        #  wget to download, nc = no-clobber (don't download if file exists)
        # wget -c --tries=0 "$line"
        # if  [[ "$line" =~ [0-9]+$ ]]; then

        #     echo "Q # ${line:(0)}"
        # else if [[ "$line" =~ [a-z]+$ ]]; then
        #         echo "Opt #${line:(0)}"
        #     fi
        # fi
    done <"$1"
fi
