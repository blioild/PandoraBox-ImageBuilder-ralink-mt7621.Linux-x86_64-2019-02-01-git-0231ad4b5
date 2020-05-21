#!/bin/sh
#
# Copyright (c) 2014 The Linux Foundation. All rights reserved.
#

do_qualcomm() {
	. /lib/qualcomm.sh

	qualcomm_board_detect
}

boot_hook_add preinit_main do_qualcomm
