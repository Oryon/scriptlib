function scl_pci_for_driver {
	[ "$1" = "" -o "$2" = "" ] && return 1
	local pci="$1"
	local driver="$2"
	[ ! -e "/sys/bus/pci/drivers/$driver" ] && echo "No such PCI driver $driver" && return 1
	! sudo modprobe $driver && echo "Could not load $driver driver" 1>&2 && return 1
	local vendor=$(lspci -n | awk "\$1 == \"${pci}\" { print \$3 }")
	device=$(echo $vendor | sed 's/:/ /' | awk '{print $2}')
	vendor=$(echo $vendor | sed 's/:/ /' | awk '{print $1}')
	[ "$device" = "" -o "$vendor" = "" ] && echo "Device $pci not found" 1>&2 && return 1
	echo "$vendor $device" | sudo tee "/sys/bus/pci/drivers/$driver/new_id" > /dev/null 2>&1 || true
	if [ -e "/sys/bus/pci/devices/0000:${pci}/driver/unbind" ]; then
		echo "0000:${pci}"     | sudo tee "/sys/bus/pci/devices/0000:${pci}/driver/unbind" > /dev/null
	fi
	echo "0000:${pci}"     | sudo tee "/sys/bus/pci/drivers/$driver/bind" > /dev/null
}

function scl_pci_alloc_huge_page () {
	[ "$1" != "" ] || error "Missing number of pages"
	CONTINUE="1"

	while [ "$CONTINUE" = "1" ]; do
		CONTINUE="0"
		HUGE_FREE=$(cat /proc/meminfo | grep HugePages_Free | awk '{ print $2}')
		HUGE_TOTAL=$(cat /proc/meminfo | grep HugePages_Total | awk '{ print $2}')
		HUGE_RESVD=$(cat /proc/meminfo | grep HugePages_Rsvd | awk '{ print $2}')
		HUGE_AVAIL=$(($HUGE_FREE - $HUGE_RESVD))
		HUGE_REQ=$(($1))
		if [ "$HUGE_AVAIL" -lt "$HUGE_REQ" -o \
			"$HUGE_AVAIL" != "$HUGE_REQ" -a "$2" = "exact" ]; then
			HUGE_NEW=$(($HUGE_TOTAL + $HUGE_REQ - $HUGE_AVAIL))
			echo "Changing number of huge-pages from $HUGE_TOTAL to $HUGE_NEW"
			sudo sysctl -w vm.nr_hugepages=$HUGE_NEW
			sudo sysctl vm.nr_hugepages
			CONTINUE="1"
		fi
	done
}