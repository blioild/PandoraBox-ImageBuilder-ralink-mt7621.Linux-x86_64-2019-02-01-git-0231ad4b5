#
# Copyright (C) 2014 PandoraBox 
#
#

include $(TOPDIR)/rules.mk

ARCH:=mips
BOARD:=realtek
BOARDNAME:=Realtek SoC
SUBTARGETS:=rtl8198c rtl8954e rtl8881a
FEATURES:=squashfs jffs2 usb rtc pci pcie
# LINUX_VERSION:=3.10.49
KERNEL_PATCHVER:=3.10

include $(INCLUDE_DIR)/target.mk

DEFAULT_PACKAGES += swconfig \
		    wireless-tools \
		    maccalc gpioctl kmod-gpio-dev \
		    kmod-leds-gpio kmod-ledtrig-gpio kmod-ledtrig-timer kmod-ledtrig-netdev \
		    kmod-gpio-button-hotplug kmod-gre

define Target/Description
	Build firmware images for Realtek based boards
endef

$(eval $(call BuildTarget))
