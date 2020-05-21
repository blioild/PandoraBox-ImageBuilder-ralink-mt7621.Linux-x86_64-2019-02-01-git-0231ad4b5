#!/bin/sh
#
# Copyright (c) 2014 OpenWrt
# Copyright (C) 2013-2015 D-Team Technology Co.,Ltd. ShenZhen
# Copyright (c) 2005-2015, lintel <lintel.huang@gmail.com>
# Copyright (c) 2013, Hoowa <hoowa.sun@gmail.com>
# Copyright (c) 2015-2017, GuoGuo <gch981213@gmail.com>
#
# 	描述:Ralink/MTK无线驱动detect脚本
#
# 	嘿，对着屏幕的哥们,为了表示对原作者辛苦工作的尊重，任何引用跟借用都不允许你抹去所有作者的信息,请保留这段话。
#

append DRIVERS "rtwifi"

. /lib/functions.sh
. /lib/ralink.sh
. /lib/functions/system.sh

board=$(ralink_board_name)

rt2860v2_get_first_if_mac() {
	local wlan_mac=""
	case $board in
	hc5661 | \
	hc5761 | \
	hc5962 | \
	hc5861)
		wlan_mac=`mtd_get_mac_ascii bd_info_rsa "Vfac_mac "`
		[ -n "$wlan_mac" ] && echo $(macaddr_add "$wlan_mac" 2)
		;;
	*)
		factory_part=$(find_mtd_part Factory)
		dd bs=1 skip=4 count=6 if=$factory_part 2>/dev/null | /usr/sbin/maccalc bin2mac	
		;;
	esac
}

rt2860v2_get_second_if_mac() {
	local wlan_mac=""
	case $board in
	hc5661 | \
	hc5761 | \
	hc5962 | \
	hc5861)
		wlan_mac=`mtd_get_mac_ascii bd_info_rsa "Vfac_mac "`
		[ -n "$wlan_mac" ] && echo $(macaddr_add "$wlan_mac" 3)
		;;
	*)
		factory_part=$(find_mtd_part Factory)
		dd bs=1 skip=32772 count=6 if=$factory_part 2>/dev/null | /usr/sbin/maccalc bin2mac		
		;;
	esac
}

detect_rtwifi() {
	local macaddr

	#If mt_dbdc scripts are there,we should skip this detection so that wireless configurations will be handled by mt_dbdc script.
	[ -f /lib/wifi/mt_dbdc.sh ] && return
	for phyname in ra rai; do
	[ $( grep -c ${phyname}0 /proc/net/dev) -eq 1 ] && {
		config_get type $phyname type
		[ "$type" == "rtwifi" ] || {
			case $phyname in
				ra)
					hwmode=11g
					htmode=HT20
					pb_smart=1
					noscan=0
					macaddr=$(rt2860v2_get_first_if_mac)
					ssid="PandoraBox-2.4G-$(echo $macaddr | awk -F ":" '{print $4""$5""$6 }'| tr a-z A-Z)"
					;;
				rai)
					hwmode=11a
					htmode=VHT80
					macaddr=$(rt2860v2_get_second_if_mac)
					ssid="PandoraBox-5G-$(echo $macaddr | awk -F ":" '{print $4""$5""$6 }'| tr a-z A-Z)"
					pb_smart=0
					noscan=1
					;;
			esac
			
		[ -n "$macaddr" ] && {
			dev_id="set wireless.${phyname}.macaddr=${macaddr}"
		}
		uci -q batch <<-EOF
			set wireless.${phyname}=wifi-device
			set wireless.${phyname}.type=rtwifi
			${dev_id}
			set wireless.${phyname}.hwmode=$hwmode
			set wireless.${phyname}.channel=auto
			set wireless.${phyname}.txpower=100
			set wireless.${phyname}.htmode=$htmode
			set wireless.${phyname}.country=CN
			set wireless.${phyname}.txburst=1
			set wireless.${phyname}.noscan=$noscan
			set wireless.${phyname}.smart=$pb_smart

			set wireless.default_${phyname}=wifi-iface
			set wireless.default_${phyname}.device=${phyname}
			set wireless.default_${phyname}.network=lan
			set wireless.default_${phyname}.mode=ap
			set wireless.default_${phyname}.ssid=${ssid}
			set wireless.default_${phyname}.encryption=none
EOF
		uci -q commit wireless
		}
	}
	done
}
