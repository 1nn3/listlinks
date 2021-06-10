#!/usr/bin/env -S xvfb-run --auto-servernum sh

set -e

usage () {
	cat <<! >&2
Usage: $(basename $0) -f <AWK> -u <URI>

	-f <AWK>
		AWK-Skript
	
		Filtert URI und Text und zeigt beides an
			'/re/ {print}'
		Filtert URI und Text, zeigt aber nur den Text an
			'/re/ {print \$2}'
		Filtert nur den Text und zeigt aber Text und URI an
			'\$2 ~ /re/ {printf("%s\\t%s\\n", \$2, \$1)}'
		A case-insensitive match:
			tolower(\$2) ~ /re/  { … }

	-u <URI>
		URI

	-k <Integer>
		Keep

	-d <path/to/dir>

		Default: XDG_CACHE_HOME/listlinks-notify

Ausgabe sind alle neuen Zeilen des Filter.
!
}

TEMP=$(getopt -o 'hf:u:k:d:' --long 'help' -n "$0" -- "$@")

if [ $? -ne 0 ]; then
	usage
	echo 'Terminating...' >&2
	exit 1
fi

# Note the quotes around "$TEMP": they are essential!
eval set -- "$TEMP"
unset TEMP

while true; do
	case "$1" in

		'-h'|'--help')
			usage
			shift 1
			exit
		;;

		'-f')
			f="$2"
			shift 2
			continue
		;;

		'-u')
			u="$2"
			shift 2
			continue
		;;

		'-k')
			k="$2"
			shift 2
			continue
		;;

		'-d')
			d="$2"
			shift 2
			continue
		;;

		'--')
			shift
			break
		;;

		*)
			echo 'Internal error!' >&2
			exit 1
		;;
	esac
done

#echo 'Remaining arguments:'
#for arg; do
#	echo "--> '$arg'"
#done

listlinks="$(which listlinks)"

# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
export USER="${USER:-$LOGNAME}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/runtime-$USER}"
mkdir -m "0700" -p "$XDG_RUNTIME_DIR"

if [ ! "$f" ]; then
	echo "$(basename $0): Kein -f <AWK> angegeben!" >&2
	usage
	exit 1
fi

if [ ! "$u" ]; then
	echo "$(basename $0): Kein -u <URI> angegeben!" >&2
	usage
	exit 1
fi

seen="${XDG_CACHE_HOME:-$HOME/.cache}/listlinks-notify"
seen="${d:-$seen}"
mkdir -p "$seen"

seen="$seen/$(echo $u | md5sum - | cut -b -32).seen"
touch "$seen"

"$listlinks" -u "$u" | awk -F "\t" "$f" | while read REPLY; do
	if grep -q --line-regexp "$REPLY" "$seen"; then
		continue
	fi

	echo "$REPLY" | tee --append "$seen"
done

# Cache kürzen
keep="${k:-512}"
temp="$(/bin/mktemp --tmpdir=/dev/shm/)"
tail -n "$keep" "$seen" >"$temp"
mv "$temp" "$seen"

