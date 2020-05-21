#
# Copyright (C) 2009 OpenWrt.org
# Copyright (C) 2012 lintel<lintel.huang@gmail.com>
#

SUBTARGET:=mt7621
BOARDNAME:=MT7621 based boards

FEATURES+=usb nand
CPU_TYPE:=1004kc
CPU_SUBTYPE:=dsp

FEATURES += rtc nand

#CFLAGS:=-Os -pipe -mmt -mips32r2 -mtune=1004kc

# CFLAGS:=-Os -pipe -mips32r2 -mtune=1004kc -mdsp -funit-at-a-time -fno-caller-saves
DEFAULT_PACKAGES +=  \
		    hwnat
		    
define Target/Description
	Build firmware images for MediaTek MT7621 based boards.
endef

