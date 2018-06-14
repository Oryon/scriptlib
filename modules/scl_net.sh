function scl_local_ip () {
	local IP=$(ip -o -4 addr | grep "scope global" | head -n 1 | awk '{ print $4 }' | sed s:/.*::)
	if [ "$IP" = "" ]; then
		local IP=$(ip -o -6 addr | grep "scope global" | head -n 1 | awk '{ print $4 }' | sed s:/.*::)
	fi
	echo $IP
}

function scl_create_ns () {
	[ "$1" = "" ] && return 1
	sudo ip netns add $1
	sudo ip netns exec $1    ip link set lo up
}

function scl_wait_for_interface () {
	local CMD="ip link show dev $1"
	if [ "$2" != "" ]; then
		CMD="sudo ip netns exec $2 ip link show dev $1"
	fi
	until $CMD > /dev/null 2>&1
	do
		sleep 1
	done
}

scl_load_module parsing #scl_ian
function scl_find_available_ports () {
	[ "$1" = "" ] && return 1
	! scl_ian "$1" && return 2

	__SCL_NS=""
	[ "$2" != "" ] && __SCL_NS="sudo ip netns exec $2"

	__SCL_LOW=$($__SCL_NS cat /proc/sys/net/ipv4/ip_local_port_range | awk '{ print $1}')
	__SCL_HIGH=$($__SCL_NS cat /proc/sys/net/ipv4/ip_local_port_range | awk '{ print $2}')


	comm -23 <(seq "$__SCL_LOW" "$__SCL_HIGH" | sort) <($__SCL_NS ss -tan | awk '{print $4}' | cut -d':' -f2 | grep '[0-9]\{1,5\}' | sort -u) | shuf | head -n "$1"
}
