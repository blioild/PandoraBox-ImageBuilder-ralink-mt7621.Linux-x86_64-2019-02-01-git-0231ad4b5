#ARCH_PACKAGES:=qualcomm
SUBTARGET:=ipq40xx
BOARDNAME:=QCA IPQ40xx based boards
CPU_TYPE:=cortex-a7
CPU_SUBTYPE:=neon-vfpv4

DEFAULT_PACKAGES += \
	kmod-qca-edma uboot-ipq40xx kmod-usb-dwc3-ipq40xx \
	kmod-qca-ssdk-hnat 

define Target/Description
	Build firmware image for IPQ40xx SoC devices.
endef
