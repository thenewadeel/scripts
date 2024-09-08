fileName=$1
doCmd=$2

while IFS= read -r line; do
	$doCmd "$line"
done < $fileName
