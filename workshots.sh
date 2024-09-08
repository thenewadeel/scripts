#!/bin/bash
while [[ $# > 0 ]]; do
    case "$1" in
    -d | --output-directory)
        outputDirectory="$2"
        shift
        ;;
    -i | --interval)
        interval="$2"
        shift
        ;;
    -p | --project-name)
        projectName="$2"
        shift
        ;;
    -v | --verbose)
        verbose=true
        shift
        ;;
    --help | *)
        echo "Usage:"
        echo "-i|--interval --- \"Goes to sleep command\""
        echo "-p|--project-name --- \"Name your folder to drop shots in\""
        echo "-d|--output-directory --- \"-d /home/myDir\""
        echo "-v|--verbose --- \"Verbose mode\""
        echo "--help"
        exit 1
        ;;
    esac
    shift
done
if [[ -z "$outputDirectory" ]]; then
    outputDirectory="/home/gg/dev/screenLogs"
fi
if [[ -z "$projectName" ]]; then
    projectName=$(screenshots)
fi
if [[ -z "$interval" ]]; then
    interval=30s
fi
cd $outputDirectory
mkdir $projectName 2>/dev/null
cd $projectName

while [ : ]; do
    filename=$(printf "%(%H%M%S)T.png")
    $(shotgun -f png $filename)
    if [[ ! -z "$verbose" ]]; then
        echo "outputDirectory: $outputDirectory"
        echo "output: $filename"
    fi

    sleep $interval
done
echo 'done'
