
SUBTARGET:=ipq806x
BOARDNAME:=QCA IPQ806x based boards
CPU_TYPE:=cortex-a15
CPU_SUBTYPE:=neon-vfpv4

DEFAULT_PACKAGES += \
		uboot-ipq806x uboot-ipq806x-fwupgrade-tools \
		kmod-qca-ssdk-hnat ethtool \
		kmod-qca-nss-gmac
		

define Target/Description
	Build firmware image for IPQ806x SoC devices.
endef
