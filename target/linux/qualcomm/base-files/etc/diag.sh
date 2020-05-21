#!/bin/sh
# Copyright (c) 2013 OpenWrt
# Copyright (c) 2005-2014, lintel <lintel.huang@gmail.com>
# Copyright (c) 2018, PandoraBox Team
#
#
#     警告:对着屏幕的哥们,我们允许你使用此脚本，但不允许你抹去作者的信息,请保留这段话。
#

. /lib/functions.sh
. /lib/functions/leds.sh

status_led=""

led_set_attr() {
	[ -f "/sys/class/leds/$1/$2" ] && echo "$3" > "/sys/class/leds/$1/$2"
}

status_led_set_timer() {
	led_set_attr $status_led "trigger" "timer"
	led_set_attr $status_led "delay_on" "$1"
	led_set_attr $status_led "delay_off" "$2"
}

status_led_on() {
	led_set_attr $status_led "trigger" "none"
	led_set_attr $status_led "brightness" 255
}

status_led_off() {
	led_set_attr $status_led "trigger" "none"
	led_set_attr $status_led "brightness" 0
}

get_status_led() {
	board=$(board_name)
	boardname="${board##*,}"

	case $board in
	asus,rt-acrh17)
		status_led="${boardname}:blue:power"
		;;
	ea6350v3 |\
	hiwifi-c526a |\
	rt-ac58u)
		status_led="${boardname}:blue:status"
		;;
	newifi5)
		status_led="newifi:power"
		;;
	xiaomi-r3d)
		status_led="miwifi:yellow:status"
		;;
	d7800 |\
	ea8500 |\
	r7500v2 |\
	r7800 |\
	wxr-2533dhp)
		status_led="${boardname}:white:power"
		;;
	*)
		[ -d /sys/class/leds/power ] && status_led="power";
		[ -d /sys/class/leds/sys ] && status_led="sys";
		;;
	esac
}

set_led_boot_done() {
	board=$(board_name)
	boardname="${board##*,}"

	case $board in
	xiaomi-r3d |\
	d2q)
		status_led_off
		;;
	*)
		status_led_on
		;;
	esac
}

set_state() {
	get_status_led

	case "$1" in
	preinit)
		status_led_blink_preinit
		;;
	failsafe)
		status_led_blink_failsafe
		;;
	upgrade | \
	preinit_regular)
		status_led_blink_preinit_regular
		;;
	done)
		set_led_boot_done
		;;
	esac
}
