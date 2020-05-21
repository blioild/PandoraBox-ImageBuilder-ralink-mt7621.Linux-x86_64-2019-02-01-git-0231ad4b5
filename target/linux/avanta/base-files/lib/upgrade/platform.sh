#
# Copyright (C) 2014 OpenWrt.org
#

. /lib/avanta.sh

RAMFS_COPY_DATA=/lib/avanta.sh

REQUIRE_IMAGE_METADATA=1

RAMFS_COPY_BIN='fwtool fw_printenv fw_setenv'
RAMFS_COPY_DATA='/etc/fw_env.config /var/lock/fw_printenv.lock  /usr/sbin/pb_ubisplit'

CI_UBIPART="ubi"
CI_KERNPART="linux"
PART_NAME=firmware

ubi_kill_if_exist() {
	local ubidev="$( nand_find_ubi "$CI_UBIPART" )"
	local c_ubivol="$( nand_find_volume $ubidev $1 )"
	umount -f /dev/$c_ubivol 2>/dev/null
	[ "$c_ubivol" ] && ubirmvol /dev/$ubidev -N $1 || true
	echo "Partition $1 removed."
}



avanta_nand_upgrade_tar() {
	local kpart_size="$1"
	local tar_file="$2"
	local board_name="$(nand_board_name)"

	local kernel_length=`(tar xf $tar_file sysupgrade-$board_name/kernel -O | wc -c) 2> /dev/null`
	local rootfs_length=`(tar xf $tar_file sysupgrade-$board_name/root -O | wc -c) 2> /dev/null`

	local mtdnum="$( find_mtd_index "$CI_UBIPART" )"
	if [ ! "$mtdnum" ]; then
		echo "cannot find ubi mtd partition $CI_UBIPART"
		return 1
	fi

	local ubidev="$( nand_find_ubi "$CI_UBIPART" )"
	if [ ! "$ubidev" ]; then
		ubiattach -m "$mtdnum"
		sync
		ubidev="$( nand_find_ubi "$CI_UBIPART" )"
	fi

	if [ ! "$ubidev" ]; then
		echo "cannot find ubi device $CI_UBIPART"
		return 1
	fi

	local root_ubivol="$( nand_find_volume $ubidev rootfs )"
	# remove ubiblock device of rootfs
	local root_ubiblk="ubiblock${root_ubivol:3}"
	if [ "$root_ubivol" -a -e "/dev/$root_ubiblk" ]; then
		echo "removing $root_ubiblk"
		if ! ubiblock -r /dev/$root_ubivol; then
			echo "cannot remove $root_ubiblk"
			return 1;
		fi
	fi

	ubi_kill_if_exist rootfs
	ubi_kill_if_exist rootfs_data

	ubimkvol /dev/$ubidev -N rootfs -s $rootfs_length
	ubimkvol /dev/$ubidev -N rootfs_data -m

	local kern_ubivol="$(nand_find_volume $ubidev $CI_KERNPART)"
	tar xf $tar_file sysupgrade-$board_name/kernel -O | \
	mtd write - "kernel"

	local root_ubivol="$(nand_find_volume $ubidev rootfs)"
	tar xf $tar_file sysupgrade-$board_name/root -O | \
		ubiupdatevol /dev/$root_ubivol -s $rootfs_length -

	nand_do_upgrade_success
}

platform_check_image() {
	local board="$(avanta_board_name)"
	
	if grep -q ubi /proc/mtd
	then
	    HAS_UBI_PART="1";
	fi;
	
	[ "$#" -gt 1 ] && return 1

	case "$board" in
	"mi424-wr")
		#nand_do_platform_check $board $1

		return 0
		;;
	esac

	echo "Sysupgrade is not yet supported on $board."
	return 1
}


platform_do_upgrade() {
	local magic="$(get_magic_long "$1")"
	
	if grep -q ubi /proc/mtd
	then
	    HAS_UBI_PART="1";
	fi;
		
	case "$(board_name)" in
	"mi424-wr")
		if [ "$magic" == "27051956" ]; then
			 default_do_upgrade "$ARGV"
		else
			avanta_nand_upgrade_tar 2097152 "$ARGV"
		fi
		;;
	*)
        return 1
		;;
	esac
}

blink_led() {
	. /etc/diag.sh; set_state upgrade
}

append sysupgrade_pre_upgrade blink_led
