declare -A SCL_COMMANDS

SCRIPTLIB_DIR=$(dirname ${BASH_SOURCE[0]})

function scl_cmd_add () {
	[ "$1" = "" ] && { echo "cmd_add: Missing argument" && return 1; }
	if [ "$#" = "1" ]; then
		SCL_COMMANDS[$1]=$1
		return 0
	fi
	local _scl_str=""
	local _scl_last=$(( "$#" - 1 ))
	for i in $(seq 1 $_scl_last); do
		if [ "$_scl_str" = "" ]; then
			_scl_str="${!i}"
		else
			_scl_str="$_scl_str ${!i}"
		fi
	done
	SCL_COMMANDS[$_scl_str]=${!#}
}

scl_cmd_add usage scl_usage
function scl_usage () {
	echo "available commands:"
	declare -n _scl_cmd
	for _scl_cmd in SCL_COMMANDS; do
		for key in "${!_scl_cmd[@]}"; do
			echo "  $key"
		done
	done
}

function scl_load_module () {
	[ "$1" = "" ] && echo "Missing argument" && return 1
	[ ! -f "$SCRIPTLIB_DIR/modules/scl_$1.sh" ] && echo "'$1' module not found." && return 1
	. $SCRIPTLIB_DIR/modules/scl_$1.sh
}

function scl_error () {
	if [ "$1" != "" ]; then
		echo "$1" 1>&2
	else
		echo "Error" 1>&2
	fi
	return 1
}

function scl_main () {
	[ "$1" = "" ] && eval "${SCL_COMMANDS[usage]} $@" && exit 1
	local _scl_key=""
	local _found_index=""
	local _found_command=""
	for i in $(seq 1 $#); do
		if [ "$_scl_key" = "" ]; then
			_scl_key="${!i}"
		else
			_scl_key="$_scl_key ${!i}"
		fi
		if [ "${SCL_COMMANDS[${_scl_key}]}" != "" ]; then
			_found_index="$i"
			_found_command="${_scl_key}"
		fi
	done
	
	if [ "$_found_index" = "" ]; then
		echo "Command not found..."
		eval "${SCL_COMMANDS[usage]}"
	else
		shift $_found_index
		eval "${SCL_COMMANDS[$_found_command]} $@"
	fi
}
