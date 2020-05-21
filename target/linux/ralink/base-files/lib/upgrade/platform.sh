#
# Copyright (C) 2013 lintel<lintel.huang@gmail.com>
#

. /lib/ralink.sh

PART_NAME=firmware
RAMFS_COPY_DATA="/lib/ralink.sh /usr/sbin/pb_ubisplit"

platform_check_image() {
	local board=$(ralink_board_name)
	local magic="$(get_magic_long "$1")"

	[ "$ARGC" -gt 1 ] && return 1

	if grep -q ubi /proc/mtd
	then
		case "$board" in
		hc5661a)
			return 0
			;;
		*)
			[ "$magic" != "27051956" ] && {
				echo "Invalid image type."
				return 1
			}
			pb_ubisplit "$1" check || {
				echo "UBI not found."
				return 1
			}
			return 0
			;;
		esac
	else
		case "$board" in
		dir-645)
			[ "$magic" != "5ea3a417" ] && {
				echo "Invalid image type."
				return 1
			}
			return 0
			;;
	# 	wsr-1166)
	# 		[ "$magic" != "48445230" ] && {
	# 			echo "Invalid image type."
	# 			return 1
	# 		}
	# 		return 0
	# 		;;
		*)
			[ "$magic" != "27051956" ] && {
				echo "Invalid image type."
				return 1
			}
			pbfw-fwcheck -l -f $1 || {
				echo "PandoraBox firmware checking failed."
				return 1
			}
			return 0
			;;
		esac
	fi
	echo "Sysupgrade is not yet supported on $board."
	return 1
}

pbnand_do_upgrade() {
	pb_ubisplit "$1" kernel | mtd write - "kernel"
	pb_ubisplit "$1" ubi > "${1}.ubi"
	nand_upgrade_ubinized "${1}.ubi"
}

platform_do_upgrade() {
	local board=$(ralink_board_name)

	case "$board" in
	pbr-m1 | \
	pbr-m2 | \
	d1 | \
	timecloud2)
		if [ -d /sys/module/ledtrig_lightflow ]
		then
			ralink_reset_all_leds
			for i in /sys/class/leds/*/trigger
			do
				echo 'lightflow' > $i
			done
		fi
	;;
	d2)
		local d2_leds="power:blue internet:blue usb:blue 5g:blue 2g:blue"
		if [ -d /sys/module/ledtrig_lightflow ]
		then
			ralink_reset_all_leds
			
			for i in $d2_leds
			do
				echo 'lightflow' > /sys/class/leds/$i/trigger
			done
		fi
	;;
	esac
	if grep -q ubi /proc/mtd
	then
		case "$board" in
		hc5661a)
			nand_do_upgrade "${1}"
			;;
		*)
			pbnand_do_upgrade "$ARGV"
			;;
		esac
	else
		default_do_upgrade "$ARGV"
	fi
}

disable_watchdog() {
	killall watchdog
	( ps | grep -v 'grep' | grep '/dev/watchdog' ) && {
		echo 'Could not disable watchdog'
		return 1
	}
}

append sysupgrade_pre_upgrade disable_watchdog
