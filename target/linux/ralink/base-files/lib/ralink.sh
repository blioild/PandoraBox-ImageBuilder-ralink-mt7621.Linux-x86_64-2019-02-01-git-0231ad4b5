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


ralink_board_detect() {
	local machine
	local name

	machine=$(awk 'BEGIN{FS="[ \t]+:[ \t]"} /machine/ {print $2}' /proc/cpuinfo)

	case "$machine" in
	"5K W20")
		name="5k-w20"
		;;
	*"ASUS RT-N13")
		name="rt-n13"
		;;
	*"HuaWei HG255D")
		name="hg255d"
		;;
	*"Mercury MW305R")
		name="mw305r"
		;;
	*"D-Team RY-1")
		name="ry1"
		;;
	"Newifi Y1S")
		name="y1s"
		;;
	*"Xunlei SuperDisk mini")
		name="superdisk_mini"
		;;
	"Newifi mini")
		name="y1"
		;;
	"Newifi 2")
		name="d1"
		;;
	"Newifi 3")
		name="d2"
		;;
	*"Fanvil VoiceGateway 100")
		name="vg100"
		;;
	*"PandoraBox PBR-M1")
		name="pbr-m1"
		;;
	*"PandoraBox PBR-M2")
		name="pbr-m2"
		;;
	*"PandoraBox PBR-C1")
		name="pbr-c1"
		;;
	*"PandoraBox PBR-D1")
		name="pbr-d1"
		;;
	*"MagicDisc")
		name="magic-disc"
		;;
	*"PandoraBox AP-Server")
		name="pbr-aps"
		;;
	*"CreativeBox MT7621 Demo board")
		name="creativebox"
		;;
	*"AmazingBox")
		name="abox"
		;;
	*"XunLei TimeCloud")
		name="timecloud"
		;;
	*"XunLei TimeCloud2")
		name="timecloud2"
		;;
	*"Youku YK1")
		name="yk1"
		;;
	*"YouKu YK-L2")
		name="yk-l2"
		;;
	*"Xiaomi Mini")
		name="xiaomi-mini"
		;;
	*"Xiaomi R1CL")
		name="xiaomi-r1cl"
		;;
	*"Xiaomi R3")
		name="xiaomi-r3"
		;;
	*"Xiaomi R3G")
		name="xiaomi-r3g"
		;;
	*"Xiaomi R3P")
		name="xiaomi-r3p"
		;;
	*"D-Link DIR-620 B2")
		name="dir620"
		;;
	*"MediaTek MT7620A Evaluation Board")
		name="mt7620a-evb"
		;;
	*"MediaTek MT7628A Evaluation Board")
		name="mt7628a-evb"
		;;
	*"PandoraBox W3 Demo Board")
		name="pbr-w3"
		;;
	*"FengLiYuan HA-1MGWA")
		name="ha-1mgwa"
		;;
	*"PandoraBox BHU Board")
		name="pbr-bhu"
		;;
	*"360Safe P2 Board")
		name="360safe-p2"
		;;
	*"Duzun DM06 Board")
		name="dm06"
		;;
	*"Widora Board")
		name="widora"
		;;
	*"Linkit Smart MT7688")
		name="linkit"
		;;
	*"PandoraBox AP7620A Board")
		name="ap7620a"
		;;
	*"PandoraBox AP7621A Board")
		name="ap7621a"
		;;
	*"MediaTek MT7621A Evaluation Board")
		name="mt7621a-evb"
		;;
	*"Aigale Ai-BR100")
		name="br100"
		;;
	*"Baidu M100 Music Board")
		name="m100"
		;;
	*"ZBT WR8305RT")
		name="wr8305rt"
		;;
	*"WRTnode Board")
		name="wrtnode"
		;;
	*"MicroWRT Board")
		name="microwrt"
		;;
	*"MTALL Board")
		name="mtall"
		;;
	*"ZTE Q7 Board")
		name="q7"
		;;
	*"OYE-0001 Board")
		name="oye-0001"
		;;
	*"Phicomm K1")
		name="k1"
		;;
	*"Phicomm K2")
		name="k2"
		;;
	*"Phicomm K2G")
		name="k2g"
		;;
	*"TOTOLINK A3004NS")
		name="a3004ns"
		;;
	*"HiWiFi HC5661")
		name="hc5661"
		;;
	*"HiWiFi HC5661A"*)
		name="hc5661a"
		;;
	*"HiWiFi HC5761")
		name="hc5761"
		;;
	*"HiWiFi HC5861")
		name="hc5861"
		;;
	*"HuaWei HG256")
		name="hg256"
		;;
	*"ZyXEL WAP120NF")
		name="wap120nf"
		;;
	*"ZBT AP8100RT")
		name="ap8100rt"
		;;
	*"RT-N10+")
		name="rt-n10-plus"
		;;
	*"RT-N15")
		name="rt-n15"
		;;
	*"RT-N56U")
		name="rt-n56u"
		;;
	*"WSR-1166DHP")
		name="wsr-1166"
		;;
	*"Linksys RE6500")
		name="re6500"
		;;
	*"Netgear R6220")
		name="r6220"
		;;
	*"Mercury MAC2600R")
		name="mac2600r"
		;;
	*"HiWiFi HC5962")
		name="hc5962"
		;;
	*"Phicomm K2P")
		name="k2p"
		;;
	*"Netgear R6120")
		name="r6120"
		;;
	*"YouHua WR1200JS")
		name="wr1200js"
		;;
	*"JCG JHR-AC860M")
		name="ac860m"
		;;
	*"PGB-M10"*)
		name="pgb-m10"
		;;
	*"PanguBox 4G Router")
		name="pgb-4gm"
		;;
	*"TOTOLINK A7000R")
		name="a7000r"
		;;
	*"GeHua GH-A1")
		name="gh-a1"
		;;
	*)
		name="generic"
		;;
	esac

	[ -z "$RALINK_BOARD_NAME" ] && RALINK_BOARD_NAME="$name"
	[ -z "$RALINK_MODEL" ] && RALINK_MODEL="$machine"

	[ -e "/tmp/sysinfo/" ] || mkdir -p "/tmp/sysinfo/"

	echo "$RALINK_BOARD_NAME" > /tmp/sysinfo/board_name
	echo "$RALINK_MODEL" > /tmp/sysinfo/model
}

ralink_get_mac_binary()
{
	local mtdname="$1"
	local seek="$2"
	local part

	. /lib/functions.sh

	part=$(find_mtd_part "$mtdname")
	if [ -z "$part" ]; then
		echo "ramips_get_mac_binary: partition $mtdname not found!" >&2
		return
	fi

	dd bs=1 skip=$seek count=6 if=$part 2>/dev/null | /usr/sbin/maccalc bin2mac
}

ralink_board_name() {
	local name

	[ -f /tmp/sysinfo/board_name ] && name=$(cat /tmp/sysinfo/board_name)
	[ -z "$name" ] && name="unknown"

	echo "$name"
}

ralink_reset_all_leds() {
 	for i in /sys/class/leds/*/trigger
	do
		echo 'none' > $i
	done
 	for i in /sys/class/leds/*/brightness
	do
		echo 0 > $i
	done
}
