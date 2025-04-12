#!/bin/sh

magick -size 1200x800 xc:#0000ff \
-font VT323.ttf -gravity Center -pointsize 72 \
-fill \#000000 -draw 'rectangle 160, 100 1120, 740' \
-fill \#b2b2b2 -draw 'rectangle 120, 60 1080, 700' \
-fill \#000000 -annotate +0+180 'Top field' \
-fill \#000000 -annotate +0+250 'bottom field' \
-fill \#000000 -draw 'rectangle 280, 80 920, 540' \
-fill \#b2b2b2 -draw 'rectangle 284, 84 916, 536' \
-fill \#b2b2b2 -draw 'rectangle 500, 78 700, 86' \
-pointsize 40 \
-fill \#000000 -annotate +0-320 '10-04-2025' \
-fill \#ffffff -draw 'rectangle 300, 100 900, 520' \
-gravity NorthWest \
-draw 'image SrcOver 300, 100 600, 420 favicon.ico' \
output.png &

