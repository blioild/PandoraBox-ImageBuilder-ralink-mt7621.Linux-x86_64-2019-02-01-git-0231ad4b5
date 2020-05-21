#!/bin/sh
#
# Copyright (C) 2014 OpenWrt.org
#

X86_BOARD_NAME=
X86_MODEL=

x86_board_detect() {
	local machine
	local name

	machine=$(cat /sys/class/dmi/id/product_name)
	
	[ -z "$machine" ] &&  machine=$(cat /sys/class/dmi/id/board_name)

	case "$machine" in
	"VMware Virtual Platform")
		name="vmware"
		;;

	*)
		name="generic"
		;;
	esac

	[ -z "$X86_BOARD_NAME" ] && X86_BOARD_NAME="$name"
	[ -z "$X86_MODEL" ] && X86_MODEL="$machine"

	[ -e "/tmp/sysinfo/" ] || mkdir -p "/tmp/sysinfo/"

	echo "$X86_BOARD_NAME" > /tmp/sysinfo/board_name
	echo "$X86_MODEL" > /tmp/sysinfo/model
}

x86_board_name() {
	local name

	[ -f /tmp/sysinfo/board_name ] || x86_board_detect
	[ -f /tmp/sysinfo/board_name ] && name=$(cat /tmp/sysinfo/board_name)
	[ -z "$name" ] && name="unknown"

	echo "$name"
}
