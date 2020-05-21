#!/bin/sh
# Copyright (C) 2014 OpenWrt.org

. /lib/functions/leds.sh
. /lib/x86.sh

get_status_led() {
	case $(x86_board_name) in
	mi424-wr)
		status_led="wps:green"
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
	done)
		status_led_on
		;;
	esac
}
