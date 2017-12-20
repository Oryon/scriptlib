function scl_qcow2_mount () { # path/to/qcow path/to/mount/dir
	[ "$1" != "" ] || { echo "Missing disk argunent" && return 1; }
	[ "$2" != "" ] || { echo "Missing mount directory argument" && return 1; }
	[ -f "$1" ] || { echo "No such file: $1" && return 1; }
	[ "$(mount | grep -F "$2" )" = "" ] || { echo "Already mounted ($2)" && return 1; }
	[ "$(mount | grep -F "$1" )" = "" ] || { echo "Already mounted ($1)" && return 1; }
	[ -d "$2" ] || mkdir -p "$2" || { echo "Cannot create mount directory: $2" && return 1; }
	
	MOUNT_SEARCH_FILE="etc"
	sudo modprobe nbd max_part=24
	sudo qemu-nbd --connect=/dev/nbd0 $(realpath "$1")

	# Mount all partitions until etc is found
	for PARTITION in 1 2 3 4 5 6 7
	do
		DEVICE="/dev/nbd0p${PARTITION}"
		sudo mount $DEVICE "$2" >/dev/null 2>&1 || continue
		if [ -e "$2/$MOUNT_SEARCH_FILE" ]; then
			return 0
		else
			sudo umount "$2"
		fi
	done
	echo "'$MOUNT_SEARCH_FILE' not found in $1 partitions"
	return 1
}

function scl_qcow2_umount () {
	[ "$1" != "" ] || { echo "Missing mount directory" && return 1; }
	sudo umount "$1" || true
	rmdir "$1" || true
	sudo qemu-nbd --disconnect /dev/nbd0 || true
}
