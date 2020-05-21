# Copyright (c) 2017 PandoraBox Team
#
include $(TOPDIR)/rules.mk

ARCH:=arm
BOARD:=qualcomm
BOARDNAME:=Qualcomm Atheros(IPQ)
FEATURES:=ubifs squashfs pcie usb ramdisk

SUBTARGETS:=ipq806x ipq40xx ipq807x ipq807x_64
MAINTAINER:=lintel <lintel.huang@gmail.com>

KERNELNAME:=zImage Image dtbs

KERNEL_PATCHVER:=3.14

include $(INCLUDE_DIR)/target.mk
DEFAULT_PACKAGES += \
	uboot-envtools kmod-leds-gpio  \
	kmod-usb2 kmod-usb3 \
	swconfig pb_ubisplit

$(eval $(call BuildTarget))
