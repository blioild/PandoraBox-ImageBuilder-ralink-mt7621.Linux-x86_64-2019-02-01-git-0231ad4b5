#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Profile/SMDK6410
  NAME:=Samsung SMDK6410 Board
  PACKAGES:= \
	kmod-usb-storage \
	kmod-leds-gpio kmod-ledtrig-netdev \
	kmod-ledtrig-usbdev wpad-mini \
	uboot-envtools
endef

define Profile/SMDK6410/Description
 Package set compatible with Samsung SMDK6410 rev. I.
endef

SMDK6410_UBIFS_OPTS:="-m 2048 -e 126KiB -c 4096"
SMDK6410_UBI_OPTS:="-m 2048 -p 128KiB -s 512"

$(eval $(call Profile,SMDK6410))
