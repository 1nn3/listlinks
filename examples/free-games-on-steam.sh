#!/bin/sh
f='tolower($2) ~ /free/ {print $2}'
u='https://store.steampowered.com/news/?headlines=1'
listlinks-notify -f "$f" -u "$u" | nl

