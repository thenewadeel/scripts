for f in *_8k.png; do
	magick $f -resize 1024x1024 "${f:0:-4}"_1k.png ;
	magick $f -resize 2048x2048 "${f:0:-4}"_2k.png ;
	magick $f -resize 4096x4096 "${f:0:-4}"_4k.png ;
done;
