PART_NAME=firmware
REQUIRE_IMAGE_METADATA=1

RAMFS_COPY_BIN='fwtool fw_printenv fw_setenv'
RAMFS_COPY_DATA='/etc/fw_env.config /var/lock/fw_printenv.lock  /usr/sbin/pb_ubisplit'

ubi_kill_if_exist() {
	local ubidev="$( nand_find_ubi "$CI_UBIPART" )"
	local c_ubivol="$( nand_find_volume $ubidev $1 )"
	umount -f /dev/$c_ubivol 2>/dev/null
	[ "$c_ubivol" ] && ubirmvol /dev/$ubidev -N $1 || true
	echo "Partition $1 removed."
}

# Tar sysupgrade for ASUS NAND devices
# An ubi repartition is required due to the strange partition table created by Asus.
# We create all the factory partitions to make sure that the U-boot tftp recovery still works.
# The reserved kernel partition size should be enough to put the factory image in.
asus_nand_upgrade_tar() {
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

	ubi_kill_if_exist linux
	ubi_kill_if_exist linux2
	ubi_kill_if_exist rootfs
	ubi_kill_if_exist rootfs_data
	ubi_kill_if_exist jffs2

	ubimkvol /dev/$ubidev -N linux -s $kpart_size
	ubimkvol /dev/$ubidev -N linux2 -s $kpart_size
	ubimkvol /dev/$ubidev -N jffs2 -s 2539520
	ubimkvol /dev/$ubidev -N rootfs -s $rootfs_length
	ubimkvol /dev/$ubidev -N rootfs_data -m

	local kern_ubivol="$(nand_find_volume $ubidev $CI_KERNPART)"
	tar xf $tar_file sysupgrade-$board_name/kernel -O | \
		ubiupdatevol /dev/$kern_ubivol -s $kernel_length -

	local root_ubivol="$(nand_find_volume $ubidev rootfs)"
	tar xf $tar_file sysupgrade-$board_name/root -O | \
		ubiupdatevol /dev/$root_ubivol -s $rootfs_length -

	nand_do_upgrade_success
}

# Factory image sysupgrade for ASUS NAND devices
# Delete all the partitions we created before, create "linux" partition and write factory image in.
# Skip the first 64bytes which is an uImage header to verify the firmware.
# The kernel partition size should be the original one.
asus_nand_upgrade_factory() {
	local kpart_size="$1"
	local fw_file="$2"
	local board_name="$(nand_board_name)"

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

	ubi_kill_if_exist linux
	ubi_kill_if_exist linux2
	ubi_kill_if_exist rootfs
	ubi_kill_if_exist rootfs_data
	ubi_kill_if_exist jffs2

	ubimkvol /dev/$ubidev -N linux -s $kpart_size
	ubimkvol /dev/$ubidev -N linux2 -s $kpart_size
	ubimkvol /dev/$ubidev -N jffs2 -m

	local kern_ubivol="$(nand_find_volume $ubidev $CI_KERNPART)"
	ubiupdatevol /dev/$kern_ubivol --skip=64 $fw_file
	umount -a
	reboot -f
}

buffalo_nand_upgrade_tar() {
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

	ubi_kill_if_exist linux
	ubi_kill_if_exist linux2
	ubi_kill_if_exist kernel
	ubi_kill_if_exist rootfs
	ubi_kill_if_exist rootfs_data
	ubi_kill_if_exist jffs2
	ubi_kill_if_exist ubi_rootfs
	ubi_kill_if_exist ubi_rootfs_data

	ubimkvol /dev/$ubidev -N $CI_KERNPART -s $kpart_size
	ubimkvol /dev/$ubidev -N ubi_rootfs -s $rootfs_length
	ubimkvol /dev/$ubidev -N rootfs_data -m

	local kern_ubivol="$(nand_find_volume $ubidev $CI_KERNPART)"
	tar xf $tar_file sysupgrade-$board_name/kernel -O | \
		ubiupdatevol /dev/$kern_ubivol -s $kernel_length -

	local root_ubivol="$(nand_find_volume $ubidev ubi_rootfs)"
	tar xf $tar_file sysupgrade-$board_name/root -O | \
		ubiupdatevol /dev/$root_ubivol -s $rootfs_length -
	
	mtd erase rootfs_1
	nand_do_upgrade_success
}

platform_check_image() {
	local magic="$(get_magic_long "$1")"

	if grep -q ubi /proc/mtd
	then
	    HAS_UBI_PART="1";
	fi;
	
	case "$(board_name)" in
	d7800 |\
	r7500v2 |\
	r7800 | \
	ea8500 | \
	ea6350v3 | \
	hiwifi-c526a | \
	pbr-m5 | \
	newifi5 | \
	rt-ac58u | \
	wxr-2533dhp | \
	xiaomi-r3d |\
	asus,rt-acrh17)
		return 0
		;;
	*)
		return 0 

	esac
}

pbnand_do_upgrade() {
	[ -f /tmp/sysupgrade.meta ] &&  {                                              
                echo "Remove PandoraBox META!" > /dev/console      
                fwtool  -i /tmp/sysupgrade.meta -t "$1"                                               
        }        
        
	pb_ubisplit "$1" kernel | mtd write - "kernel"
	pb_ubisplit "$1" ubi > "${1}.ubi"
	nand_upgrade_ubinized "${1}.ubi"
}

platform_do_upgrade() {
	local magic="$(get_magic_long "$1")"
	
	if grep -q ubi /proc/mtd
	then
	    HAS_UBI_PART="1";
	fi;
		
	case "$(board_name)" in
	rt-ac58u | \
	asus,rt-acrh17)
		CI_UBIPART="UBI_DEV"
		CI_KERNPART="linux"
		if [ "$magic" == "27051956" ]; then
			asus_nand_upgrade_factory 50409472 "$ARGV"
		else
			asus_nand_upgrade_tar 33554432 "$ARGV"
		fi
		;;
	xiaomi-r3d |\
	d7800 |\
	r7500v2 |\
	r7800)
		CI_UBIPART="ubi"
		CI_KERNPART="kernel"
		nand_do_upgrade "$ARGV" "$ARGV"
		;;
	ea6350v3 |\
	ea8500)
		platform_do_upgrade_linksys "$ARGV"
		;;
	wxr-2533dhp)
		CI_UBIPART="ubi"
		CI_KERNPART="kernel"
		buffalo_nand_upgrade_tar 4194304 "$ARGV"
		;;
	hiwifi-c526a)
		CI_UBIPART="ubi"
		CI_KERNPART="kernel"
		buffalo_nand_upgrade_tar 4194304 "$ARGV"
		;;
	newifi5 | \
	pbr-m5)
		CI_UBIPART="UBI_DEV"
		CI_KERNPART="linux"
		nand_do_upgrade "$ARGV"
		;;
		
	*)
		 if [ "$HAS_UBI_PART" == "1" ]; then
		 {
			echo  "--PandoraBox-NAND-Upagrade---" > /dev/console
			pbnand_do_upgrade "$ARGV" 
		}
		else
		{
			echo  "--PandoraBox-NOR-Upagrade---" > /dev/console
			default_do_upgrade "$ARGV"
		}
		fi;
		;;
	esac
}

platform_nand_pre_upgrade() {
	case "$(board_name)" in
	zyxel,nbg6817)
		zyxel_do_upgrade "$1"
		;;
	esac
}

blink_led() {
	. /etc/diag.sh; set_state upgrade
}

append sysupgrade_pre_upgrade blink_led
