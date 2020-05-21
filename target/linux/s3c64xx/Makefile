#
# Copyright (C) 2012-2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/host.mk

ARCH:=arm
BOARD:=s3c64xx
BOARDNAME:=Samsung S3C64xx
FEATURES:=audio usb display gpio nand ubifs squashfs
MAINTAINER:=lintel

CPU_TYPE:=arm1176jzf-s
CPU_SUBTYPE:=vfp

KERNEL_PATCHVER:=3.14

include $(INCLUDE_DIR)/target.mk
DEFAULT_PACKAGES += kmod-usb-hid

define Target/Description
	Build firmware image for Sansumg s3c64xx SoC devices.
	Currently produces mini6410.
endef

KERNELNAME:=zImage
# KERNELNAME="uImage"

$(eval $(call BuildTarget))
