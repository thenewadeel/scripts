#!/bin/bash
if [ -z "$1" ]; then
    echo 'no input given'
else
    # input=$1
    # "/home/gg/dev/scripts/jslibs"
    printf 'Getting lines one by one\n'
    # printf "==================================================\n"
    heading=""
    question=""
    answer=""
    quest="^[0-9]."
    ans="^[(?a-z+)?]"
    dataCache=""
    newQuestion=false
    sectionType="Subjective"
    difficultyLevel="None"
    options=""
    let totalQuestions=0
    let totalAnswers=0
    let loopCounter=1
    while read -r line; do
        # printf "\nParsing Section --- : $sectionType"
        if [[ $line =~ $quest ]]; then
            echo "its Q"
            question=${line}
            case $sectionType in
            True\ False)
                question=$(printf "${line::-1}")
                answer=${line: -1:1}
                ;;
            esac

            newQuestion=true
            let totalQuestions=$totalQuestions+1
            # printf "NUM \n"
        else
            if [[ $line =~ $ans ]]; then
                echo "its A"
                answer+="$line\n"
                # case $sectionType in
                # Subjective)
                # MCQs) options+="$line,";;
                # sectionType=`printf "$line"`;;
                # esac

                let totalAnswers=$totalAnswers+1
                # printf "$line"
            else
                echo "its X"
                # dataCache=`printf "$dataCache;$line"`

                difficultyLevel=$(printf "$line")
                echo "Level to $difficultyLevel"
                echo "line: $line"
                # case $line in
                #     "Subjective")
                #         sectionType=`printf "$line"`
                #         echo "section changed to $sectionType"
                #     ;;
                #     "Easy"|"Medium"|"Difficult")
                #         difficultyLevel=`printf "$line"`
                #         echo "Level to $difficultyLevel"
                #     ;;
                # esac

                dataCache=$(printf "$dataCache\n#:$loopCounter:$line\n")
            fi
        fi
        if [[ $newQuestion == true ]]; then
            # else
            # answer=`printf \"%q\" $answer`
            # echo $answer/
            # echo $answer
            printf "\n\"$answer\"," >>answers.csv
            printf "\n\"$question\",,,,,,,,,,$difficultyLevel" >>questions.csv
            printf "\n\"$question\",\"$sectionType\",\"$answer\",$difficultyLevel" >>session.csv
            newQuestion=false
            answer=""
            options=""
            # printf "\n" >>test.csv
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
        let loopCounter=$loopCounter+1
    done <"$1"
    printf "Data Wasted--- \n $dataCache \n"
    printf "Total Questions: $totalQuestions \n"
    printf "Total Answers: $totalAnswers \n"
    printf "Total Lines: $loopCounter \n"
    let missingLines=$loopCounter-$totalAnswers-$totalQuestions
    printf "Missing Lines: $missingLines \n"
fi
