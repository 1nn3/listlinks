#!/bin/sh
f='$1 ~ /\.torrent$/ {print $1}'
u='https://cdimage.debian.org/debian-cd/current/multi-arch/bt-cd/'
listlinks-notify -f "$f" -u "$u"

