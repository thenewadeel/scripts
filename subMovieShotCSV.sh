#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <input csv file> <input movie file> <output directory>"
    exit 1
fi

inputCSV="$1"
inputMovie="$2"
outputDir="$3"

while IFS=\| read -r serial startTime dialog; do
    # startTime=$(echo "$timeRange" | cut -d'-' -f1)
    # endTime=$(echo "$timeRange" | cut -d'-' -f2)
    outputFilename="$outputDir/${serial}.jpg"
    ffmpeg -hide_banner -loglevel warning -ss "$startTime" -i "$inputMovie" -vf "drawtext=text='$dialog':x=10:y=10:fontsize=36:fontcolor=white" -frames:v 1 "$outputFilename"
    echo '-hide_banner -loglevel warning -ss "$startTime" -i "$inputMovie" -vf "drawtext=text='$dialog':x=10:y=10:fontsize=36:fontcolor=white" -frames:v 1 "$outputFilename"' >>subMovieShotCSV.log

done <"$inputCSV"

# ffmpeg -i inputvideo.mp4 -ss 00:00:03 -frames:v 1 foobar.jpeg
