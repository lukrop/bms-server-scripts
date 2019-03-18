#!/bin/sh
# Resize DDS and GIF textures to 1x1
# See README.md for usage information.  
# Author(s): Lukas Kropatschek <lukas@kropatschek.net>
# License: See LICENSE
DATADIR=${DATADIR:-"$1"}

TEXDIRS="korea/texture/texture_Polak
korea/weather
misctex
objects/KoreaObj
objects/KoreaObj_HiRes"

cd "$DATADIR"

for d in $TEXDIRS; do
	cd "$d"
	for f in *.dds *.DDS *.gif *.GIF; do
		echo "Resizing $f"
		mogrify -resize 1x1 "$f"
	done
	cd "$DATADIR"
done
