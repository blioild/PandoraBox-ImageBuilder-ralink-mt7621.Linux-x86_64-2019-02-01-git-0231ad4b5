#!/bin/sh
# 
#   Copyright (C) 2014 D-Team Technology Co.,Ltd. ShenZhen
#   Copyright (C) 2014 lintel<lintel.huang@gmail.com>
# 
#
#    警告:对着屏幕的哥们,我们允许你使用此脚本，但不允许你抹去作者的信息,请保留这段话。
#
#    Copyright (C) 2010 OpenWrt.org
#


realtek_board_name() {
	local machine
	local name

	machine=$(awk 'BEGIN{FS="[ \t]+:[ \t]"} /machine/ {print $2}' /proc/cpuinfo)

	case "$machine" in
	*"PBR-M1R")
		name="pbr-m1r"
		;;

	*)
		name="generic"
		;;
	esac

	echo $name
}

realtek_get_mac_binary()
{
	local mtdname="$1"
	local seek="$2"
	local part

	. /lib/functions.sh

	part=$(find_mtd_part "$mtdname")
	if [ -z "$part" ]; then
		echo "realtek_get_mac_binary: partition $mtdname not found!" >&2
		return
	fi

	dd bs=1 skip=$seek count=6 if=$part 2>/dev/null | /usr/sbin/maccalc bin2mac
}

