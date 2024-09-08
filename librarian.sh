#!/bin/bash
read_dom () {
    local IFS=\>
    read -d \< ENTITY CONTENT
}
firstFolder=`pwd`
echo "Script called from $firstFolder"
# OUTFILE="BookName,AuthName,PicFileName,DataFileName\n"
printf "BookName,BookDataFilename,PicName,BookTitle,AuthName,AdditionalName,Contributors\n" > testCSV.csv

printf "\n-------------------\n"
printf "\n=== Replacing Commas with Underscores ===\n"
find -name "* *" -print0 | sort -rz | \
while read -d $'\0' f; do mv -v "$f" "$(dirname "$f")/$(basename "${f// /_}")"; done
printf "\n=== Done ===\n"
authors=(*/)
totalAuthors=${#authors[*]}
printf "Authors are :${authors[*]}"
printf "\nTotal Authors: $totalAuthors"
printf "\n-------------------\n"
for ((authNo=0; authNo<$totalAuthors;authNo++))
do
    # printf "Index:$authNo Val:${authors[$authNo]} \n"
    thisAuthor=${authors[$authNo]}
    # printf "thisAuthor: $thisAuthor"
    cd "$thisAuthor"
    books=(*/)
    totalBooks=${#books[*]}
    printf "\nBook titles :${books[*]}"
    printf "\nTotal Books :${#books[*]}"
    printf "\n-------------------\n"
    for ((bookNo=0; bookNo<$totalBooks; bookNo++))
    do
        thisBook=${books[$bookNo]}
        # trimmedName=${thisBook%[(]*[0-9]*[)]*/}
        # qTrimmedName=`printf '%q' "$trimmedName"`
        # printf "\n Trimmed $thisBook \n as $trimmedName"
        # printf "\nEXEC:mv ${thisBook%/} $trimmedName\n"
        # printf "\nQUOTED:mv ${thisBook@Q} ${trimmedName@Q}\n"
        # printf "=== $trimmedName === $qTrimmedName ==="
        # `mv $thisBook $trimmedName`
        cd "$thisBook"
        # `cd $trimmedName`
        printf "\n Now in `pwd` dir \n"
        # printf "\n Tgt Name : $trimmedName  \n"
        # `cp cover.jpg cpver2.jpg`
        `mv cover.jpg ${thisBook%/}.jpg`
        dataFileName=`ls |egrep *."pdf|epub|mobi"`
        # echo "[[[[[[[[[[[[[[ $dataFileName"
        printf "${thisBook%/},${dataFileName},${thisBook%/}.jpg," >> "../../testCSV.csv"
        printf "\n-------------------\n"
        printf "\nFolder Contents: \n`ls`"
        printf "\n-------------------\n"
        while read_dom; do
            if [[ $ENTITY = "dc:title" ]] || [[ $ENTITY == dc:creator* ]] ;
            then
                printf "$CONTENT,"
                printf "$CONTENT," >> "../../testCSV.csv"
                # exit
                # continue
            fi
            # if [[ $ENTITY = "dc:creator" ]]; then
            #     echo "$CONTENT,"
            # fi
        done < metadata.opf  
        # >> "../../testCSV.csv"
        # printf "$OUTFILE"
        printf '\n' >> "../../testCSV.csv"
        cd ..
    done
    # printf "\nNow in `pwd`"
    cd ..
    # printf "\nNow in `pwd`"
done
