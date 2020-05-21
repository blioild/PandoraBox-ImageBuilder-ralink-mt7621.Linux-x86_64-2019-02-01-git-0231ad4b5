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
		kmod-usb-core kmod-usb2 kmod-usb-ohci kmod-usb-storage kmod-usb-storage-extras kmod-ledtrig-usbdev  \
		kmod-nls-cp936 kmod-nls-iso8859-1 kmod-nls-cp437 kmod-nls-utf8 kmod-fs-ext4  kmod-fs-vfat \
		uhttpd iwinfo libiwinfo-lua luci luci-mod-admin-full luci-app-firewall luci-app-upnp luci-theme-bootstrap \
		kmod-mt76x2e block-mount
endef

define Profile/Default/Description
	Default package set compatible with most boards.
endef
$(eval $(call Profile,Default))
