#!/bin/sh
#
# Copyright (c) 2015 The Linux Foundation. All rights reserved.
# Copyright (C) 2011 OpenWrt.org

. /lib/qualcomm.sh
. /lib/functions.sh 
. /lib/functions/system.sh

# xor multiple hex values of the same length
xor() {
	local val
	local ret="0x$1"
	local retlen=${#1}

	shift
	while [ -n "$1" ]; do
		val="0x$1"
		ret=$((ret ^ val))
		shift
	done

	printf "%0${retlen}x" "$ret"
}

qcawifi_die() {
	echo "qcawifi_cal: " "$*"
	exit 1
}

qcawifi_extract() {
	local part=$1
	local offset=$2
	local count=$3
	local cal_bin=$4
	local mtd

	mtd=$(find_mtd_chardev $part)
	[ -n "$mtd" ] || \
		qcawifi_die "no mtd device found for partition $part"

	dd if=$mtd of=$cal_bin bs=1 skip=$offset count=$count 2>/dev/null || \
		qcawifi_die "failed to extract calibration data from $mtd"
		
}

qcawifi_ubi_extract() {
	local part=$1
	local offset=$2
	local count=$3
	local cal_bin=$4
	local ubidev
	local ubi

	. /lib/upgrade/nand.sh

	ubidev=$(nand_find_ubi $CI_UBIPART)
	ubi=$(nand_find_volume $ubidev $part)
	[ -n "$ubi" ] || \
		qcawifi_die "no UBI volume found for $part"

	dd if=/dev/$ubi of=$cal_bin bs=1 skip=$offset count=$count 2>/dev/null || \
		qcawifi_die "failed to extract from $ubi"
	    
}

qcawifi_patch_mac() {
	local mac=$1
	local cal_bin=$2
	
	[ -z "$mac" ] && return

	macaddr_2bin $mac | dd of=$cal_bin conv=notrunc bs=1 seek=6 count=6  2>/dev/null
}

qcawifi_patch_mac_crc() {
	local mac=$1
	local mac_offset=6
	local chksum_offset=2
	local xor_mac
	local xor_fw_mac
	local xor_fw_chksum
	local cal_bin=$2
	
	xor_fw_mac=$(hexdump -v -n 6 -s $mac_offset -e '/1 "%02x"' $cal_bin)
	xor_fw_mac="${xor_fw_mac:0:4} ${xor_fw_mac:4:4} ${xor_fw_mac:8:4}"

	qcawifi_patch_mac "$mac" $cal_bin && {
		xor_mac=${mac//:/}
		xor_mac="${xor_mac:0:4} ${xor_mac:4:4} ${xor_mac:8:4}"

		xor_fw_chksum=$(hexdump -v -n 2 -s $chksum_offset -e '/1 "%02x"' $cal_bin)
		xor_fw_chksum=$(xor $xor_fw_chksum $xor_fw_mac $xor_mac)

		printf "%b" "\x${xor_fw_chksum:0:2}\x${xor_fw_chksum:2:2}" | \
			dd of=$cal_bin conv=notrunc bs=1 seek=$chksum_offset count=2  2>/dev/null
	}
}

qcawifi_is_caldata_valid() {
	local expected="$1"
	local cal_bin=$2
	
	magic=$(hexdump -v -n 2 -e '1/1 "%02x"' $cal_bin)
	[[ "$magic" == "$expected" ]]
	return $?
}

do_load_qcawifi_board_bin()
{
	local board=$(qualcomm_board_name)
	local mtdblock=$(find_mtd_part 0:ART)

	local apdk="/tmp"
	mkdir -p ${apdk}

	# load board.bin
	case "$board" in
	ap-dk0*)
		mtdblock=$(find_mtd_part 0:ART)
		if [ -z "$mtdblock" ]; then
			# read from mmc
			mtdblock=$(find_mmc_part 0:ART)
		fi
		[ -n "$mtdblock" ] || return

		dd if=${mtdblock} of=${apdk}/wifi0.caldata bs=32 count=377 skip=128  2>/dev/null >/dev/null
		dd if=${mtdblock} of=${apdk}/wifi1.caldata bs=32 count=377 skip=640  2>/dev/null >/dev/null
		dd if=${mtdblock} of=${apdk}/wifi2.caldata bs=32 count=377 skip=1152 2>/dev/null >/dev/null
		;;
	ap16* | ap148*)
		mtdblock=$(find_mtd_part 0:ART)
		if [ -z "$mtdblock" ]; then
			# read from mmc
			mtdblock=$(find_mmc_part 0:ART)
		fi
		[ -n "$mtdblock" ] || return

		dd if=${mtdblock} of=${apdk}/wifi0.caldata bs=32 count=377 skip=128  2>/dev/null >/dev/null
		dd if=${mtdblock} of=${apdk}/wifi1.caldata bs=32 count=377 skip=640  2>/dev/null >/dev/null
		dd if=${mtdblock} of=${apdk}/wifi2.caldata bs=32 count=377 skip=1152 2>/dev/null >/dev/null
		;;
	asus,rt-acrh17)
		CI_UBIPART=UBI_DEV
		qcawifi_ubi_extract "Factory" 4096 12064  ${apdk}/wifi0.caldata
		qcawifi_ubi_extract "Factory" 36864 12064 ${apdk}/wifi1.caldata
		;;
	hiwifi-c526a)
		hw_mac_addr=`mtd_get_mac_ascii bdinfo "Vfac_mac "`
		[ -n "$hw_mac_addr" ] || hw_mac_addr="D4:EE:07:00:00:00"
		qcawifi_extract "ART" 4096 12064  ${apdk}/wifi0.caldata
		qcawifi_extract "ART" 20480 12064 ${apdk}/wifi1.caldata
		[ -n "$hw_mac_addr" ] && {
			qcawifi_patch_mac_crc $(macaddr_add $hw_mac_addr 2) ${apdk}/wifi0.caldata
			qcawifi_patch_mac_crc $(macaddr_add $hw_mac_addr 3) ${apdk}/wifi1.caldata
		}
		;;
	rt-ac58u)
		CI_UBIPART=UBI_DEV
		qcawifi_ubi_extract "Factory" 4096 12064  ${apdk}/wifi0.caldata
		qcawifi_ubi_extract "Factory" 20480 12064 ${apdk}/wifi1.caldata
		;;
	wxr-2533dhp)
		qcawifi_extract "ART" 4096 12064  ${apdk}/wifi0.caldata
		qcawifi_patch_mac_crc $(mtd_get_mac_binary ART 24) ${apdk}/wifi0.caldata
		qcawifi_extract "ART" 20480 12064 ${apdk}/wifi1.caldata
		qcawifi_patch_mac_crc $(mtd_get_mac_binary ART 30) ${apdk}/wifi1.caldata
		;;
	ea8500)
		hw_mac_addr=$(mtd_get_mac_ascii devinfo hw_mac_addr)
		qcawifi_extract "ART" 4096 12064  ${apdk}/wifi0.caldata
		qcawifi_extract "ART" 20480 12064 ${apdk}/wifi1.caldata
		[ -n "$hw_mac_addr" ] && {
			qcawifi_patch_mac_crc $(macaddr_add $hw_mac_addr 1) ${apdk}/wifi0.caldata
			qcawifi_patch_mac_crc $(macaddr_add $hw_mac_addr 2) ${apdk}/wifi1.caldata
		}
		;;
	ea6350v3)
		hw_mac_addr=$(mtd_get_mac_ascii devinfo hw_mac_addr)
		qcawifi_extract "0:ART" 4096 12064  ${apdk}/wifi0.caldata
		qcawifi_extract "0:ART" 20480 12064 ${apdk}/wifi1.caldata
		[ -n "$hw_mac_addr" ] && {
			qcawifi_patch_mac_crc $(macaddr_add $hw_mac_addr 1) ${apdk}/wifi0.caldata
			qcawifi_patch_mac_crc $(macaddr_add $hw_mac_addr 2) ${apdk}/wifi1.caldata
		}
		;;
	xiaomi-r3d |\
	d7800 |\
	r7500v2 |\
	r7800)
		qcawifi_extract "ART" 4096 12064  ${apdk}/wifi0.caldata
		qcawifi_patch_mac_crc $(macaddr_add $(mtd_get_mac_binary ART 6) 1) ${apdk}/wifi0.caldata
		qcawifi_extract "ART" 20480 12064 ${apdk}/wifi1.caldata
		qcawifi_patch_mac_crc $(macaddr_add $(mtd_get_mac_binary ART 6) 2) ${apdk}/wifi1.caldata
		;;
		
	*)
		qcawifi_extract "ART" 4096 12064  ${apdk}/wifi0.caldata
		qcawifi_extract "ART" 20480 12064 ${apdk}/wifi1.caldata
		qcawifi_extract "ART" 36864 12064  ${apdk}/wifi0.caldata
	;;
	esac
}
