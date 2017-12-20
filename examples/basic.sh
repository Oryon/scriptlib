#/bin/bash -e

CD="$( cd "$( dirname $0 )" && pwd )"
cd $CD

. ../scriptlib.sh

scl_load_module net

scl_cmd_add show my ip show_ip
function show_ip () {
	echo $(scl_local_ip)
}

scl_cmd_add say hello say_hello
function say_hello () {
	echo Good day sir!
}

scl_main $@
