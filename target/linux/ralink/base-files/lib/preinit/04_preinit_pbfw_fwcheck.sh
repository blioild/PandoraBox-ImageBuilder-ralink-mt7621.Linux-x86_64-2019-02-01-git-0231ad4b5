#!/bin/sh

do_fwcheck() {
	pbfw-fwcheck -v 2>&1 > /dev/null
}

boot_hook_add preinit_main do_fwcheck
boot_hook_add failsafe do_fwcheck