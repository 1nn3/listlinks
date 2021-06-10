#!/bin/sh
f='$2 ~ /View Source/ {print $1}'
u='https://www.gunviolencearchive.org/last-72-hours'
listlinks-notify -f "$f" -u "$u" | nl

