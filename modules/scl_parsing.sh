function scl_nawk() {
	[ ! -f "$2" -o "$1" = "" ] && echo "Not a file '$1'" 1>&2 && return 1
	local INDEX="1"
	local SED=""
	for n in $(head -n 1 "$2") ; do
		SED="$SED -e s*\_$n\_*\\\$$INDEX*g"
		INDEX=$((INDEX + 1))
	done
	tail -n +2 "$2" | awk "$(echo "$1" | sed $SED)"
}

function scl_ian () {
	[ "$1" -eq "$1" ] 2>/dev/null
}
