#
# Copyright (C) 2006-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

ARCH:=i386
BOARD:=x86
BOARDNAME:=x86
FEATURES:=squashfs ext4 vdi vmdk pcmcia targz
SUBTARGETS=generic 64

KERNEL_PATCHVER:=3.14

KERNELNAME:=bzImage

include $(INCLUDE_DIR)/target.mk

DEFAULT_PACKAGES += partx-utils mkf2fs fdisk e2fsprogs wpad kmod-usb-hid \
kmod-ath5k kmod-ath9k kmod-ath9k-htc kmod-ath10k kmod-rt2800-usb kmod-e1000e kmod-igb kmod-igbvf kmod-ixgbe kmod-pcnet32 kmod-tulip kmod-vmxnet3 htop lm-sensors autocore luci luci-app-zerotier luci-app-ipsec-vpnd luci-app-zerotier \
ath10k-firmware-qca988x ath10k-firmware-qca9888 ath10k-firmware-qca9984 \
kmod-usb-net kmod-usb-net-asix kmod-usb-net-asix-ax88179

$(eval $(call BuildTarget))

$(eval $(call $(if $(CONFIG_TARGET_ROOTFS_ISO),RequireCommand,Ignore),mkisofs, \
   	Please install mkisofs. \
))
