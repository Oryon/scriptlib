function pci_for_driver {
	[ "$1" = "" -o "$2" = "" ] && return 1
	local pci="$1"
	local driver="$2"
	[ ! -e "/sys/bus/pci/drivers/$driver" ] && echo "No such PCI driver $driver" && return 1
	! sudo modprobe $driver && echo "Could not load $driver driver" 1>&2 && return 1
	local vendor=$(lspci -n | awk "\$1 == \"${pci}\" { print \$3 }")
	device=$(echo $vendor | sed 's/:/ /' | awk '{print $2}')
	vendor=$(echo $vendor | sed 's/:/ /' | awk '{print $1}')
	[ "$device" = "" -o "$vendor" = "" ] && echo "Device $pci not found" 1>&2 && return 1
	echo "$vendor $device" | sudo tee "/sys/bus/pci/drivers/$driver/new_id" > /dev/null
	if [ -e "/sys/bus/pci/devices/0000:${pci}/driver/unbind" ]; then
		echo "0000:${pci}"     | sudo tee "/sys/bus/pci/devices/0000:${pci}/driver/unbind" > /dev/null
	fi
	echo "0000:${pci}"     | sudo tee "/sys/bus/pci/drivers/$driver/bind" > /dev/null
}
