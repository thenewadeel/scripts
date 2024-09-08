#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <subtitle file>"
    exit 1
fi

ser=""
time=""
text=""
while IFS= read -r line; do
    echo "Processing line: $line" >>subMovieShot.log
    if [[ "$line" =~ ^[0-9]+[[:space:]]*$ ]]; then
        if [[ -n $ser && -n $time && -n $text ]]; then
            # tr -d '\n\r ' removes the newline and carriage return characters,
            # leaving only spaces. This is because the text lines can contain
            # newlines, and tr -d only removes the exact characters specified.
            # The first tr -d removes the newlines and carriage returns, and the
            # second tr -d removes any remaining spaces.
            sanitized=$(echo -e "$ser|$time|$text" | tr -d '\n\r')
            echo -e "$sanitized" >>"${1%.srt}.csv"
            echo "Wrote to CSV: $sanitized" >>subMovieShot.log
            ser=""
            time=""
            text=""
        fi
        ser="$line"
        echo "Found serial number: $ser" >>subMovieShot.log
        # echo "Found Ser"
    elif [[ $line =~ ^([0-9]{2}):([0-9]{2}):([0-9]{2}):? ]]; then
        if [[ -n $ser ]]; then
            time=$(date -d "1970-01-01 ${line:0:8}" +%H:%M:%S)
            echo "Found timestamp: $time" >>subMovieShot.log
        fi
    else
        if [[ -n $ser && -n $time ]]; then
            text+="$line"
            echo "Found text: $text" >>subMovieShot.log
        fi
    fi
done <"$1"
