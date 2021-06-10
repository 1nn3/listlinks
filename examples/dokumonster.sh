#!/bin/sh
f='$1 ~ /^http:\/\/dokumonster\.de\/sehen\// {printf("%s\t%s\n", $2, $1)}'
u='http://dokumonster.de'
listlinks-notify -f "$f" -u "$u" | nl

