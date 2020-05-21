#
# Copyright (C) 2009 OpenWrt.org
#

SUBTARGET:=rt3352
BOARDNAME:=RT3352 based boards

CFLAGS:=-Os -pipe -mips32r2 -mtune=24kec -mdsp -mabi=32 -funit-at-a-time -fno-caller-saves

define Target/Description
	Build firmware images for Ralink RT5350 based boards.
endef

