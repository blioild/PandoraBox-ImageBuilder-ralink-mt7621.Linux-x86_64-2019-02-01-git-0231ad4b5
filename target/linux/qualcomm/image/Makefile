# Copyright (c) 2014 The Linux Foundation. All rights reserved.
#
include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk

IPQ806X_KERNEL_LOADADDR = 0x42208000
IPQ40XX_KERNEL_LOADADDR = 0x80208000
IPQ807X_KERNEL_LOADADDR = 0x41208000

define Build/buffalo-rootfs-cksum
	( \
		echo -ne "\x$$(od -A n -t u1 $@ | tr -s ' ' '\n' | \
			$(STAGING_DIR_HOST)/bin/awk '{s+=$$0}END{printf "%x", 255-s%256}')"; \
	) >> $@
endef

define Device/LegacyImage
	KERNEL_SUFFIX := -uImage
	KERNEL = kernel-bin | append-dtb | uImage none
	KERNEL_NAME := zImage
endef

define Device/FitImage
	KERNEL_SUFFIX := -fit-uImage.itb
	KERNEL = kernel-bin | gzip | fit gzip $$(DTS_DIR)/$$(DEVICE_DTS).dtb
	KERNEL_NAME := Image
endef

define Device/FitImageLzma
	KERNEL_SUFFIX := -fit-uImage.itb
	KERNEL = kernel-bin | lzma | fit lzma $$(DTS_DIR)/$$(DEVICE_DTS).dtb
	KERNEL_NAME := Image
endef

define Device/FitzImage
	KERNEL_SUFFIX := -fit-zImage.itb
	KERNEL = kernel-bin | fit none $$(DTS_DIR)/$$(DEVICE_DTS).dtb
	KERNEL_NAME := zImage
endef

define Device/UbiFit
	KERNEL_IN_UBI := 1
	IMAGES := nand-factory.ubi nand-sysupgrade.tar
	IMAGE/nand-factory.ubi := append-ubi
	IMAGE/nand-sysupgrade.tar := sysupgrade-tar | append-metadata
endef

define Device/DniImage
	KERNEL_SUFFIX := -uImage
	KERNEL = kernel-bin | append-dtb | uImage none
	KERNEL_NAME := zImage
	NETGEAR_BOARD_ID :=
	NETGEAR_HW_ID :=
	UBINIZE_OPTS := -E 5
	IMAGES := factory.img sysupgrade.bin
	IMAGE/factory.img := append-kernel | pad-offset $$$$(BLOCKSIZE) 64 | append-uImage-fakehdr filesystem | pad-to $$$$(KERNEL_SIZE) | append-ubi | netgear-dni
	IMAGE/sysupgrade.bin := append-kernel | pad-offset $$$$(BLOCKSIZE) 64 | append-uImage-fakehdr filesystem | sysupgrade-tar kernel=$$$$@ | append-metadata
endef
DEVICE_VARS += NETGEAR_BOARD_ID NETGEAR_HW_ID

define Device/Default
	PROFILES := Default
	KERNEL_DEPENDS = $$(wildcard $(DTS_DIR)/$$(DEVICE_DTS).dts)
	#KERNEL_DEPENDS = $$(wildcard ../dts/$$(DTS).dts)
	#DEVICE_DTS_DIR := ../dts
	KERNEL_INITRAMFS_PREFIX := $$(IMG_PREFIX)-$(1)-initramfs
	KERNEL_PREFIX := $$(IMAGE_PREFIX)
	KERNEL_LOADADDR = 0x80208000
	SUPPORTED_DEVICES = $$(BOARD_NAME)
	IMAGE/sysupgrade.tar = sysupgrade-tar | append-metadata
endef

#Packages for Platforms
include  $(TOPDIR)/packages.mk

ifeq ($(SUBTARGET),ipq40xx)
include ipq40xx.mk
endif
ifeq ($(SUBTARGET),ipq806x)
include ipq806x.mk
endif

$(eval $(call BuildImage))
