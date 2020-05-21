define Device/AP-DK01.1-C2
	$(call Device/FitImage)
	PROFILES += $$(DEVICE_NAME)
	DEVICE_TITLE := QCA AP-DK01.1-C2
	BOARD_NAME := ap-dk01.1-c2
	DEVICE_DTS := qcom-ipq40xx-ap.dk01.1-c2
	KERNEL_LOADADDR := 0x80208000
	BLOCKSIZE := 128k
	PAGESIZE := 2048
	KERNEL_SIZE := 4096k
	UBINIZE_OPTS := -E 5
	FILESYSTEMS := squashfs
	IMAGES := sysupgrade.bin
	SUPPORTED_DEVICES = $$(BOARD_NAME)
	IMAGE/sysupgrade.bin := append-kernel | pad-to $$$$(KERNEL_SIZE) | append-ubi
	DEVICE_PACKAGES := $(PANDORABOX_ROUTER_NAS_LITE) $(USB3_SUPPORT) $(QCAWIFI_IPQ40XX_SUPPORT)
endef
TARGET_DEVICES += AP-DK01.1-C2

define Device/AP-DK07.1-C1
	$(call Device/FitImage)
	PROFILES += $$(DEVICE_NAME)
	DEVICE_TITLE := QCA AP-DK07.1-C1
	BOARD_NAME := ap-dk07.1-c1
	DEVICE_DTS := qcom-ipq40xx-ap.dk07.1-c1
	KERNEL_LOADADDR := 0x80208000
	BLOCKSIZE := 128k
	PAGESIZE := 2048
	FILESYSTEMS := squashfs
	IMAGES := sysupgrade.bin
	SUPPORTED_DEVICES = $$(BOARD_NAME)
	IMAGE/sysupgrade.bin := append-kernel | append-rootfs | pad-rootfs | append-metadata
	DEVICE_PACKAGES := $(PANDORABOX_ROUTER_NAS_LITE) $(USB3_SUPPORT) $(QCAWIFI_IPQ40XX_SUPPORT) $(QCAWIFI_QCA9984_SUPPORT) $(SYNCDIAL_PACKAGES)
endef

TARGET_DEVICES += AP-DK07.1-C1

define Device/RT-AC58U
	$(call Device/FitImage)
	PROFILES += $$(DEVICE_NAME)
	DEVICE_TITLE :=ASUS RT-AC58U
	BOARD_NAME := rt-ac58u
	DEVICE_DTS := asus-rt-ac58u
	KERNEL_LOADADDR := 0x80208000
	BLOCKSIZE := 128KiB
	PAGESIZE := 2048
	KERNEL_SIZE := 4096k
	UBINIZE_OPTS := -E 5
	FILESYSTEMS := squashfs
	KERNEL_INITRAMFS := $$(KERNEL) | uImage none
	KERNEL_INITRAMFS_SUFFIX := -factory.trx
	IMAGES := sysupgrade.bin
	SUPPORTED_DEVICES = $$(BOARD_NAME)
	UIMAGE_NAME:=PBFWRT-AC58U
	IMAGE/sysupgrade.bin := sysupgrade-tar | append-metadata
	DEVICE_PACKAGES := $(PANDORABOX_ROUTER_NAS_LITE) $(USB3_SUPPORT) $(QCAWIFI_IPQ40XX_SUPPORT) qcawifi-boarddata-asus_rt-ac58u
endef
TARGET_DEVICES += RT-AC58U


define Device/rt-acrh17
	$(call Device/FitImage)
	PROFILES += $$(DEVICE_NAME)
	DEVICE_TITLE := ASUS RT-ACRH17
	BOARD_NAME := asus,rt-acrh17
	DEVICE_DTS := qcom-ipq4019-rt-acrh17
	KERNEL_LOADADDR := 0x80208000
	BLOCKSIZE := 128k
	FILESYSTEMS := squashfs
	KERNEL_INITRAMFS := $$(KERNEL) | uImage none
	KERNEL_INITRAMFS_SUFFIX := -factory.trx
	IMAGES := sysupgrade.bin
	SUPPORTED_DEVICES = $$(BOARD_NAME)
	UIMAGE_NAME:=PBFWRT-AC82U
	IMAGE/sysupgrade.bin := sysupgrade-tar | append-metadata
	DEVICE_PACKAGES := $(PANDORABOX_ROUTER_NAS_LITE) $(USB3_SUPPORT) $(QCAWIFI_IPQ40XX_SUPPORT)  $(QCAWIFI_QCA9984_SUPPORT)  qcawifi-boarddata-asus_rt-acrh17
endef

TARGET_DEVICES += rt-acrh17

define Device/PBR-M5
	$(call Device/FitImage)
	PROFILES += $$(DEVICE_NAME)
	DEVICE_TITLE :=PandoraBox PBR-M5
	BOARD_NAME := pbr-m5
	DEVICE_DTS := pbr-m5
	KERNEL_LOADADDR := 0x80208000
	BLOCKSIZE := 128KiB
	PAGESIZE := 2048
	KERNEL_SIZE := 4096k
	UBINIZE_OPTS := -E 5
	FILESYSTEMS := squashfs
	IMAGES := sysupgrade.bin
	SUPPORTED_DEVICES = $$(BOARD_NAME)
	IMAGE/sysupgrade.bin := sysupgrade-tar | append-metadata
	DEVICE_PACKAGES := $(PANDORABOX_ROUTER_NAS_LITE) $(USB3_SUPPORT) $(QCAWIFI_IPQ40XX_SUPPORT)  $(QCAWIFI_QCA9984_SUPPORT)  \
			qcawifi-boarddata-pbr-m5
endef
TARGET_DEVICES += PBR-M5


define Device/hiwifi-c526a
	$(call Device/FitImage)
	PROFILES += $$(DEVICE_NAME)
	DEVICE_TITLE :=HiWiFi C526A
	BOARD_NAME := hiwifi-c526a
	DEVICE_DTS := hiwifi-c526a
	KERNEL_LOADADDR := 0x80208000
	BLOCKSIZE := 128KiB
	PAGESIZE := 2048
	KERNEL_SIZE := 4096k
	UBINIZE_OPTS := -E 5
	FILESYSTEMS := squashfs
	IMAGES := sysupgrade.bin
	SUPPORTED_DEVICES = $$(BOARD_NAME)
	IMAGE/sysupgrade.bin := sysupgrade-tar | append-metadata
	DEVICE_PACKAGES := $(PANDORABOX_ROUTER_NAS_LITE) $(USB3_SUPPORT) $(QCAWIFI_IPQ40XX_SUPPORT)  $(MTKWIFI_MT7615N_SUPPORT)  \
			qcawifi-boarddata-hiwifi-c526a
endef
TARGET_DEVICES += hiwifi-c526a

define Device/linksys_ea6350v3
	$(call Device/FitzImage)
	PROFILES += $$(DEVICE_NAME)
	DEVICE_TITLE := Linksys EA6350v3
	DEVICE_DTS := linksys-ea6350v3
	BOARD_NAME := ea6350v3
	KERNEL_LOADADDR := 0x80208000
	BLOCKSIZE := 128k
	PAGESIZE := 2048
	KERNEL_SIZE := 3145728
	IMAGE_SIZE := 38797312
	UBINIZE_OPTS := -E 5
	SUPPORTED_DEVICES = $$(BOARD_NAME)
	IMAGES := factory.bin sysupgrade.bin
	IMAGE/factory.bin := append-kernel | pad-to $$$${KERNEL_SIZE} | append-ubi
	IMAGE/sysupgrade.bin := sysupgrade-tar | append-metadata
	DEVICE_PACKAGES :=  $(PANDORABOX_ROUTER_NAS_LITE) $(USB3_SUPPORT) $(QCAWIFI_IPQ40XX_SUPPORT) qcawifi-boarddata-linksys-ea6350v3 uboot-envtools \
			$(LINKSYS_DUALBOOT_SUPPORT)
endef
TARGET_DEVICES += linksys_ea6350v3

# define Device/newifi5
# 	$(call Device/FitImage)
# 	PROFILES += $$(DEVICE_NAME)
# 	DEVICE_TITLE :=Newifi 5
# 	BOARD_NAME := newifi5
# 	DEVICE_DTS := newifi5
# 	KERNEL_LOADADDR := 0x80208000
# 	BLOCKSIZE := 128KiB
# 	PAGESIZE := 2048
# 	KERNEL_SIZE := 4096k
# 	UBINIZE_OPTS := -E 5
# 	FILESYSTEMS := squashfs
# 	IMAGES := sysupgrade.bin
# 	SUPPORTED_DEVICES = $$(BOARD_NAME)
# 	IMAGE/sysupgrade.bin := sysupgrade-tar | append-metadata
# 	DEVICE_PACKAGES := $(NEWIFI_RELEASE) $(QCAWIFI_IPQ40XX_SUPPORT) \
# 			 $(QCAWIFI_QCA998X_SUPPORT) $(QCAWIFI_QCA99X0_SUPPORT) $(QCAWIFI_QCA988X_SUPPORT) \
# 			qcawifi-boarddata-pbr-m5
# endef
# TARGET_DEVICES += newifi5


# define Device/NEWIFI-D2Q
# 	$(call Device/FitImage)
# 	PROFILES += $$(DEVICE_NAME)
# 	DEVICE_TITLE :=NEWIFI D2Q
# 	BOARD_NAME := newifi-d2q
# 	DEVICE_DTS := newifi-d2q
# 	KERNEL_LOADADDR := 0x80208000
# 	BLOCKSIZE := 128KiB
# 	PAGESIZE := 2048
# 	KERNEL_SIZE := 4096k
# 	UBINIZE_OPTS := -E 5
# 	FILESYSTEMS := squashfs
# 	IMAGES := sysupgrade.bin
# 	SUPPORTED_DEVICES = $$(BOARD_NAME)
# 	IMAGE/sysupgrade.bin := append-kernel | pad-to $$$$(KERNEL_SIZE) | append-ubi
# 	DEVICE_PACKAGES := $(PACKAGES_16M_FLASH) $(QCAWIFI_IPQ40XX_SUPPORT) $(SYNCDIAL_PACKAGES)
# endef
# TARGET_DEVICES += NEWIFI-D2Q
