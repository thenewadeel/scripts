#!/bin/bash
if [ -z "$1" ]; then
    echo 'no input given'
else
    # input=$1
    # "/home/ad/dev/scripts/jslibs"
    printf 'Getting lines one by one\n'
    # printf "==================================================\n"
    heading=""
    question=""
    answer=""
    quest="^[0-9]."
    ans="^[(?a-z+)?]"
    dataCache=""
    newQuestion=false
    sectionType=""
    difficultyLevel="None"
    options=""
    let totalQuestions=0
    let totalAnswers=0
    let loopCounter=1
    while read -r line
    do
        # printf "\nParsing Section --- : $sectionType"
        if [[ $line =~  $quest ]];then
            # echo "its Q"
            question=${line}
            if [[ $sectionType =~ "True False" ]];then
                # echo 'in'
                question=`printf "${line::-2}"`
                answer=${line: -2:1}
            fi
            
            newQuestion=true
            let totalQuestions=$totalQuestions+1
            # printf "NUM \n"
        else
            echo "its X :$line"
            # dataCache=`printf "$dataCache;$line"`
            
            # difficultyLevel=`printf "$line"`
            # echo "Level to $difficultyLevel"
            # echo "line: $line"
            # ||  $line == "Medium" || $line == "Difficult"
            if [[ $line =~  "Easy" ]] || [[  $line =~ "Medium" ]] || [[ $line =~ "Difficult" ]];then
                difficultyLevel=`printf "${line::-1}"`
                echo "Level to $difficultyLevel"
            else if [[ $line =~ "True False" ]];then
                    sectionType=`printf "${line::-1}"`
                    echo "section changed to $sectionType"
                    
                fi
            fi
            dataCache=`printf "$dataCache\n#:$loopCounter:$line\n"`
            
        fi
        if [[ $newQuestion == true ]];then
            # else
            # answer=`printf \"%q\" $answer`
            # echo $answer/
            # echo $answer
            # printf "\n\"$answer\"," >>answers.csv
            # printf "\n\"$question\",,,,,,,,,,$difficultyLevel"  >>questions.csv
            printf "\n\"$question\",\"$sectionType\",\"$answer\",$difficultyLevel"  >> session.csv
            newQuestion=false
            answer=""
            options=""
            # printf "\n" >>test.csv
        fi
        let loopCounter=$loopCounter+1
    done < "$1"
    printf "Data Wasted--- \n $dataCache \n"
    printf "Total Questions: $totalQuestions \n"
    printf "Total Answers: $totalAnswers \n"
    printf "Total Lines: $loopCounter \n"
    let missingLines=$loopCounter-$totalAnswers-$totalQuestions
    printf "Missing Lines: $missingLines \n"
fi