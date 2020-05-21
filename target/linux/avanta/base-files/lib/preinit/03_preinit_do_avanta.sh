#!/bin/sh

do_avanta() {
	. /lib/avanta.sh

	avanta_board_detect
}

boot_hook_add preinit_main do_avanta
