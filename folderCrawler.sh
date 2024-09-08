#!/bin/bash
firstFolder=`pwd`
echo "Script called from $firstFolder"
subFolders=`ls -dc */`
# findFolders=*/
# findFolders=`find . -maxdepth 1 -mindepth 1 -type d -printf '%f\n'`
echo "Total sub-folders are \n $subFolders of len ${#subFolders}"
# echo "Found sub-folders are $findFolders of len ${#findFolders}"
# for f in $subFolders; do
#   echo "sub-folder: $f"
# done
