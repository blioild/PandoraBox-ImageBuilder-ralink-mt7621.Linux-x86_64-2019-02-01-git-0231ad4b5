#
# Copyright (C) 2009-2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk

KERNEL_LOADADDR:=0x8000
UBIFS_OPTS = -m 2048 -e 126KiB -c 4096

include packages.mk

PACKAGES_16M_FLASH := $(PANDORABOX_BASE_PACKAGES) $(DNSMASQ_FULL_PACKAGES) $(STORAGE_UTILS_PACKAGES_FULL) $(WEB_PACKAGES_LUCI_FULL) \
			$(USB_3G_DONGLE_PACKAGES) $(PRINTER_PACKAGES) \
			$(MS_KMS_PACKAGES)

AR9287_WIFI_PACKAGE :=  kmod-ath9k wpad hostapd

define Device/Default
  PROFILES := Default
  KERNEL_DEPENDS = $$(wildcard $(DTS_DIR)/$$(DEVICE_DTS).dts)
  KERNEL := kernel-bin | append-dtb | uImage none
  KERNEL_NAME := zImage
  KERNEL_SUFFIX  := -uImage
  KERNEL_IN_UBI := 1

  PAGESIZE := 2048
  SUBPAGESIZE := 512
  BLOCKSIZE := 128k
  IMAGES := sysupgrade.bin factory.bin
  IMAGE/sysupgrade.bin := sysupgrade-tar | append-metadata
  IMAGE/factory.bin := append-ubi  | append-metadata
  SUPPORTED_DEVICES := $(subst _,$(comma),$(1))
endef


define Device/mi424-wr
  DEVICE_TITLE := Actiontec MI-424WR Rev I
  DEVICE_DTS := avanta-mi424wr
  DEVICE_PACKAGES := $(PACKAGES_16M_FLASH)  $(AR9287_WIFI_PACKAGE)
  DEVICE_TYPE:=nas
  KERNEL_SIZE := 2048k
  KERNEL_IN_UBI := 0
  UBINIZE_OPTS := -E 5  
  IMAGE_SIZE := 32505856
  IMAGE/factory.bin := append-kernel | pad-to $$$$(KERNEL_SIZE) | append-ubi | check-size $$$$(IMAGE_SIZE)
endef
TARGET_DEVICES += mi424-wr


$(eval $(call BuildImage))
