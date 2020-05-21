#!/bin/sh
#
# Copyright (C) 2014 OpenWrt.org
#

AVANTA_BOARD_NAME=
AVANTA_MODEL=

avanta_board_detect() {
	local machine
	local name

	machine=$(cat /proc/device-tree/model)

	case "$machine" in
	"Actiontec MI424WR-I")
		name="mi424-wr"
		;;

	*)
		name="generic"
		;;
	esac

	[ -z "$AVANTA_BOARD_NAME" ] && AVANTA_BOARD_NAME="$name"
	[ -z "$AVANTA_MODEL" ] && AVANTA_MODEL="$machine"

	[ -e "/tmp/sysinfo/" ] || mkdir -p "/tmp/sysinfo/"

	echo "$AVANTA_BOARD_NAME" > /tmp/sysinfo/board_name
	echo "$AVANTA_MODEL" > /tmp/sysinfo/model
}

avanta_board_name() {
	local name

	[ -f /tmp/sysinfo/board_name ] || avanta_board_detect
	[ -f /tmp/sysinfo/board_name ] && name=$(cat /tmp/sysinfo/board_name)
	[ -z "$name" ] && name="unknown"

	echo "$name"
}
