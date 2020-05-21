#
# Copyright (C) 2008-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

ARCH:=mips
BOARD:=ar71xx
BOARDNAME:=Atheros AR93xx/QCA95xx
#FEATURES:=mips16
FEATURES+=usb squashfs pcie ramdisk

SUBTARGETS:=generic obsolete

define Target/Description
	Build firmware images for generic Atheros AR934x/QCA95xx based boards.
endef

KERNEL_PATCHVER:=3.14

include $(INCLUDE_DIR)/target.mk

DEFAULT_PACKAGES += \
	kmod-gpio-button-pandorabox swconfig \
	uboot-envtools

$(eval $(call BuildTarget))
