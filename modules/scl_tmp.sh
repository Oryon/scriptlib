SCL_TMP_DIR=""

# Sets the root directory for temporary files
function scl_tmp_set_dir () {
	[ "$1" = "" ] && return 1
	scl_dir="$(realpath "$1")"
	if ! mkdir -p "$scl_dir" ; then
		echo "Cannot create directory $scl_dir" 2>&1 && return 1
	fi
	SCL_TMP_DIR="$scl_dir"
	return 0
}

# Creates directories containing requested file in the temporary directory set
# with scl_tmp_set_dir, and prints the file path.
function scl_tmp_file () {
	[ "$1" = "" -o "$SCL_TMP_DIR" = "" ] && return 1
	scl_dir="$(dirname $SCL_TMP_DIR/$1)"
	mkdir -p $scl_dir || return 1
	echo $(realpath $SCL_TMP_DIR/$1)
}
