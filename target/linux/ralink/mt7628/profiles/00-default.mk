#
# Copyright (C) 2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Profile/Default
	NAME:=Default Profile
	PRIORITY:=1
	PACKAGES:=\
		kmod-usb-core kmod-usb2 kmod-usb-ohci kmod-usb-storage kmod-usb-storage-extras kmod-ledtrig-usbdev kmod-mt7628
endef

define Profile/Default/Description
	Default package set compatible with most boards.
endef
$(eval $(call Profile,Default))
