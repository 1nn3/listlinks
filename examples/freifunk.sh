#!/bin/sh
f='{print $1}'
u='https://util.berlin.freifunk.net/hardware?name=tl-wdr3600-v1,tplink_tl-wdr3600'
listlinks-notify -f "$f" -u "$u"

