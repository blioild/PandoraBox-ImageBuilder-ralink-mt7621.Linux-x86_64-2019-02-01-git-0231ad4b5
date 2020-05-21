#!/bin/sh

do_realtek() {
	. /lib/realtek.sh
}

boot_hook_add preinit_main do_realtek
