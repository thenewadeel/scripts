#!/bin/bash

pandoc $1 -o $1.pdf

while true; do
    if [ -n "$(find $1 -newer $1.pdf)" ]; then
        pandoc $1 -o $1.pdf

    fi
    sleep 1
done

# --pdf-engine=lualatex
# pandoc -N --variable "geometry=margin=1.2in" --variable mainfont="Palatino" --variable sansfont="Helvetica" --variable monofont="Menlo" --variable fontsize=12pt --variable version=2.0 $1 --pdf-engine=lualatex --toc -o $1.pdf
