#
# Copyright (C) 2009 OpenWrt.org
#

SUBTARGET:=rt3883
BOARDNAME:=RT3883 based boards
FEATURES+=usb
CPU_TYPE:=24kec
CPU_SUBTYPE:=dsp2
# CFLAGS:=-Os -pipe -mips32r2 -mtune=74kc -mdspr2 -mabi=32 -funit-at-a-time -fno-caller-saves

define Target/Description
	Build firmware images for Ralink RT3883 based boards.
endef

