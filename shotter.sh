#!/bin/bash
while [[ $#>0 ]]
do
    case "$1" in
        -d|--output-directory)
            outputDirectory="$2"
            
            shift
        ;;
        -v|--verbose)
            verbose=true
            shift
        ;;
        --help|*)
            echo "Usage:"
            echo "-d|--output-directory \"-d /home/myDir\""
            echo "-v|--verbose \"Verbose mode\""
            echo "--help"
            exit 1
        ;;
    esac
    shift
done
if [[ -z "$outputDirectory" ]];then
    outputDirectory='/home/dpc/Pictures/Screenshots'
fi
snaptime=`printf "%(%H%M%S)T.png"`
filename="$outputDirectory/$snaptime"
`xfce4-screenshooter -f -s $filename`
if [[ ! -z "$verbose" ]]; then
    echo "outputDirectory: $outputDirectory"
    echo "output: $filename"
fi
# echo "B: $valB"




