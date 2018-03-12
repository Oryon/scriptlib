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
