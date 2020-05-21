#
# Copyright (C) 2009 OpenWrt.org
# Copyright (C) 2014 lintel 
#

SUBTARGET:=mt7628
BOARDNAME:=MT7628 based boards

FEATURES+=usb nand
CPU_TYPE:=24kec
CPU_SUBTYPE:=dsp

# CFLAGS:=-Os -pipe -mips32r2 -mtune=24kec -mdsp -mabi=32 -funit-at-a-time -fno-caller-saves

define Target/Description
	Build firmware images for MediaTek MT7628 based boards.
endef

