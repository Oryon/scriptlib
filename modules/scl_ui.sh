
function scl_askyn () {
	while [ "1" = "1" ]; do
		read -p "$1 [y/n]:" -r choice
		case "$choice" in 
		  y|Y ) return 0;;
		  n|N ) return 1;;
		  * ) echo "$1 [y/n]:";;
		esac
	done
}

function scl_ask () {
	local scl_ask=""
	if [ "$1" != "" ]; then
		scl_ask="$1:"
	fi
	read -p "$scl_ask" -r scl_ack_choice
	echo $scl_ack_choice
}
