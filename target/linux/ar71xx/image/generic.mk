#
# AR934X
#

define Device/wndr3700
  DEVICE_TITLE := NETGEAR WNDR3700
  BOARDNAME := WNDR3700
  NETGEAR_KERNEL_MAGIC := 0x33373030
  NETGEAR_BOARD_ID := WNDR3700
  DEVICE_PACKAGES := $(PANDORABOX_ROUTER_NAS_LITE) $(USB2_SUPPORT) $(QCAWIFI_BASE_SUPPORT)
  IMAGE_SIZE := 7680k
  MTDPARTS := spi0.0:320k(u-boot)ro,128k(u-boot-env)ro,7680k(firmware),64k(art)ro
  IMAGES := sysupgrade.bin factory.img factory-NA.img
  KERNEL := kernel-bin | patch-cmdline | lzma -d20 | netgear-uImage lzma
  IMAGE/default := append-kernel | pad-to $$$$(BLOCKSIZE) | netgear-squashfs | append-rootfs | pad-rootfs
  IMAGE/sysupgrade.bin := $$(IMAGE/default) | check-size $$$$(IMAGE_SIZE)
  IMAGE/factory.img := $$(IMAGE/default) | netgear-dni | check-size $$$$(IMAGE_SIZE)
  IMAGE/factory-NA.img := $$(IMAGE/default) | netgear-dni NA | check-size $$$$(IMAGE_SIZE)
endef
TARGET_DEVICES += wndr3700

define Device/wndr3700v2
  $(Device/wndr3700)
  DEVICE_TITLE := NETGEAR WNDR3700 v2
  NETGEAR_BOARD_ID := WNDR3700v2
  DEVICE_PACKAGES := $(PANDORABOX_ROUTER_NAS_LITE) $(USB2_SUPPORT) $(QCAWIFI_BASE_SUPPORT)  
  NETGEAR_KERNEL_MAGIC := 0x33373031
  NETGEAR_HW_ID := 29763654+16+64
  IMAGE_SIZE := 15872k
  MTDPARTS := spi0.0:320k(u-boot)ro,128k(u-boot-env)ro,15872k(firmware),64k(art)ro
  IMAGES := sysupgrade.bin factory.img
endef
TARGET_DEVICES += wndr3700v2

define Device/wndr3800
  $(Device/wndr3700v2)
  DEVICE_TITLE := NETGEAR WNDR3800
  NETGEAR_BOARD_ID := WNDR3800
  NETGEAR_HW_ID := 29763654+16+128
  DEVICE_PACKAGES := $(PANDORABOX_ROUTER_NAS_LITE) $(USB2_SUPPORT) $(QCAWIFI_BASE_SUPPORT) 
endef
TARGET_DEVICES += wndr3800

define Device/wndr3800ch
  $(Device/wndr3800)
  DEVICE_TITLE := NETGEAR WNDR3800 (Ch)
  NETGEAR_BOARD_ID := WNDR3800CH
DEVICE_PACKAGES := $(PANDORABOX_ROUTER_NAS_LITE) $(USB2_SUPPORT) $(QCAWIFI_BASE_SUPPORT) 
endef
TARGET_DEVICES += wndr3800ch

define LegacyDevice/WNDR4300V2
  DEVICE_TITLE := NETGEAR WNDR4300v2
  DEVICE_PACKAGES := $(PANDORABOX_ROUTER_NAS_LITE) $(USB2_SUPPORT) $(QCAWIFI_BASE_SUPPORT)  $(NAND_CORE_SUPPORT)
endef
LEGACY_DEVICES += WNDR4300V2

define LegacyDevice/WNDR4500V3
  DEVICE_TITLE := NETGEAR WNDR4500v3
  DEVICE_PACKAGES := $(PANDORABOX_ROUTER_NAS_LITE) $(USB2_SUPPORT) $(QCAWIFI_BASE_SUPPORT) $(USB2_SUPPORT)  $(NAND_CORE_SUPPORT)
endef
LEGACY_DEVICES += WNDR4500V3

define Device/tl-wr843nd-v1
  $(Device/tplink-16mlzma)
  DEVICE_TITLE := TP-LINK TL-WR843N/ND v1
  DEVICE_PACKAGES := $(PANDORABOX_ROUTER_NAS_LITE) $(USB2_SUPPORT) $(QCAWIFI_BASE_SUPPORT) $(USB2_SUPPORT)  
  BOARDNAME := TL-WR841N-v8
  DEVICE_PROFILE := TLWR843
  TPLINK_HWID := 0x08430001
endef
TARGET_DEVICES += tl-wr843nd-v1

define Device/qihoo-c301
  $(Device/seama)
  DEVICE_TITLE := Qihoo C301
  DEVICE_PACKAGES := $(PANDORABOX_ROUTER_NAS_LITE) $(USB2_SUPPORT) $(QCAWIFI_BASE_SUPPORT) 
  BOARDNAME := QIHOO-C301
  IMAGE_SIZE := 15744k
  MTDPARTS := spi0.0:256k(u-boot)ro,64k(u-boot-env),64k(devdata),64k(devconf),15744k(firmware),64k(warm_start),64k(action_image_config),64k(radiocfg)ro;spi0.1:15360k(upgrade2),1024k(privatedata)
  SEAMA_SIGNATURE := wrgac26_qihoo360_360rg
endef
TARGET_DEVICES += qihoo-c301

define Device/ap152
  DEVICE_TITLE := Qualcomm AP152 demo support
  DEVICE_PACKAGES := $(PANDORABOX_ROUTER_NAS_LITE) $(USB2_SUPPORT) $(QCAWIFI_BASE_SUPPORT) $(QCAWIFI_QCA9880_SUPPORT)
  BOARDNAME = AP152
  IMAGE_SIZE = 16000k
  CONSOLE = ttyS0,115200
  MTDPARTS = spi0.0:256k(u-boot)ro,64k(u-boot-env)ro,16000k(firmware),64k(art)ro
endef
TARGET_DEVICES += ap152

define Device/jcg-jhr-848q
  DEVICE_TITLE := JCG JHR-848Q
  DEVICE_PACKAGES := $(PANDORABOX_ROUTER_NAS_LITE) $(USB2_SUPPORT) $(QCAWIFI_BASE_SUPPORT) $(QCAWIFI_QCA9880_SUPPORT)
  BOARDNAME = JHR_848Q
  IMAGE_SIZE = 16000k
  CONSOLE = ttyS0,115200
  MTDPARTS = spi0.0:256k(u-boot)ro,64k(u-boot-env)ro,14528k(rootfs),1472k(kernel),64k(art)ro,16000k@0x50000(firmware),16384k@0x0(fullflash)
  IMAGE/sysupgrade.bin = append-rootfs | pad-rootfs | pad-to 14528k | append-kernel | check-size $$$$(IMAGE_SIZE)
endef
TARGET_DEVICES += jcg-jhr-848q

define Device/jcg-jhr-848q-ath10k
  DEVICE_TITLE := JCG JHR-848Q ATH10K
  DEVICE_PACKAGES := $(PANDORABOX_ROUTER_NAS_LITE)  $(USB2_SUPPORT) $(MAC80211_ATH9K_SUPPORT) $(MAC80211_ATH10K_QCA988X_SUPPORT)
  BOARDNAME = JHR_848Q
  IMAGE_SIZE = 16000k
  CONSOLE = ttyS0,115200
  MTDPARTS = spi0.0:256k(u-boot)ro,64k(u-boot-env)ro,14528k(rootfs),1472k(kernel),64k(art)ro,16000k@0x50000(firmware),16384k@0x0(fullflash)
  IMAGE/sysupgrade.bin = append-rootfs | pad-rootfs | pad-to 14528k | append-kernel | check-size $$$$(IMAGE_SIZE)
endef
TARGET_DEVICES += jcg-jhr-848q-ath10k

define Device/rosywrt-wr818
  DEVICE_TITLE := RosyWrt WR818
  DEVICE_PACKAGES := $(PANDORABOX_ROUTER_NAS_LITE) $(USB2_SUPPORT) $(QCAWIFI_BASE_SUPPORT)  $(QCAWIFI_QCA9880_SUPPORT)
  BOARDNAME = WR818
  IMAGE_SIZE = 16000k
  CONSOLE = ttyS0,115200
  MTDPARTS = spi0.0:256k(u-boot)ro,64k(u-boot-env)ro,14528k(rootfs),1472k(kernel),64k(art)ro,16000k@0x50000(firmware),16384k@0x0(fullflash)
  IMAGE/sysupgrade.bin = append-rootfs | pad-rootfs | pad-to 14528k | append-kernel | check-size $$$$(IMAGE_SIZE)
endef
TARGET_DEVICES += rosywrt-wr818

define Device/rosywrt-wr818-ath9k
  DEVICE_TITLE := RosyWrt WR818 ATH9k
  DEVICE_PACKAGES := $(PANDORABOX_ROUTER_NAS_LITE) $(USB2_SUPPORT) $(MAC80211_ATH9K_SUPPORT) $(MAC80211_ATH10K_QCA988X_SUPPORT)
  BOARDNAME = WR818
  IMAGE_SIZE = 16000k
  CONSOLE = ttyS0,115200
  MTDPARTS = spi0.0:256k(u-boot)ro,64k(u-boot-env)ro,14528k(rootfs),1472k(kernel),64k(art)ro,16000k@0x50000(firmware),16384k@0x0(fullflash)
  IMAGE/sysupgrade.bin = append-rootfs | pad-rootfs | pad-to 14528k | append-kernel | check-size $$$$(IMAGE_SIZE)
endef
TARGET_DEVICES += rosywrt-wr818-ath9k

define Device/letv-super-router
  DEVICE_TITLE := Letv super-router
  DEVICE_PACKAGES := $(PANDORABOX_ROUTER_GENERIC) $(USB2_SUPPORT)  $(QCAWIFI_BASE_SUPPORT) 
  BOARDNAME = LETV
  IMAGE_SIZE = 16000k
  CONSOLE = ttyS0,115200
  MTDPARTS = spi0.0:256k(u-boot)ro,64k(u-boot-env),14528k(rootfs),1472k(kernel),64k(art)ro,16000k@0x50000(firmware),16384k@0x0(fullflash)
  IMAGE/sysupgrade.bin = append-rootfs | pad-rootfs | pad-to 14528k | append-kernel | check-size $$$$(IMAGE_SIZE)
endef
TARGET_DEVICES += letv-super-router

define Device/zbt-we1526
  DEVICE_TITLE := Zbtlink ZBT-WE1526
  DEVICE_PACKAGES := $(PANDORABOX_ROUTER_NAS_LITE) $(USB2_SUPPORT) $(QCAWIFI_BASE_SUPPORT)  $(QCAWIFI_QCA9880_SUPPORT)
  BOARDNAME := ZBT-WE1526
  IMAGE_SIZE := 16000k
  KERNEL_SIZE := 1472k
  ROOTFS_SIZE := 14528k
  MTDPARTS := spi0.0:256k(u-boot)ro,64k(u-boot-env)ro,14528k(rootfs),1472k(kernel),64k(art)ro,16000k@0x50000(firmware),16384k@0x0(fullflash)
  IMAGE/sysupgrade.bin := append-rootfs | pad-rootfs | pad-to $$$$(ROOTFS_SIZE) | append-kernel | check-size $$$$(IMAGE_SIZE)
endef
TARGET_DEVICES += zbt-we1526

define Device/pgb-q10p
  DEVICE_TITLE := PanguBox PGB-Q10P
  DEVICE_PACKAGES := $(PANDORABOX_ROUTER_NAS_LITE) $(USB2_SUPPORT) $(QCAWIFI_BASE_SUPPORT)  $(QCAWIFI_QCA9880_SUPPORT) $(QCAWIFI_FACTORY_SUPPORT)
  BOARDNAME := PGB-Q10P
  IMAGE_SIZE := 16000k
  KERNEL_SIZE := 1472k
  ROOTFS_SIZE := 14528k
  MTDPARTS := spi0.0:256k(u-boot)ro,64k(u-boot-env)ro,14528k(rootfs),1472k(kernel),64k(art)ro,16000k@0x50000(firmware),16384k@0x0(fullflash)
  IMAGE/sysupgrade.bin := append-rootfs | pad-rootfs | pad-to $$$$(ROOTFS_SIZE) | append-kernel | check-size $$$$(IMAGE_SIZE)
endef
TARGET_DEVICES += pgb-q10p

define Device/domywifi-dw33d
  DEVICE_TITLE := DomyWifi DW33D
  DEVICE_PACKAGES := $(PANDORABOX_ROUTER_NAS_LITE) $(USB2_SUPPORT) $(QCAWIFI_BASE_SUPPORT)  $(QCAWIFI_QCA9880_SUPPORT)  $(NAND_CORE_SUPPORT)
  BOARDNAME = DW33D
  IMAGE_SIZE = 16000k
  CONSOLE = ttyS0,115200
  MTDPARTS = spi0.0:256k(u-boot)ro,64k(u-boot-env)ro,14528k(rootfs),1472k(kernel),64k(art)ro,16000k@0x50000(firmware),16384k@0x0(fullflash);ar934x-nfc:96m(ubi),32m(backup)ro
  IMAGE/sysupgrade.bin = append-rootfs | pad-rootfs | pad-to 14528k | append-kernel | check-size $$$$(IMAGE_SIZE)
endef
TARGET_DEVICES += domywifi-dw33d

define Device/domywifi-dw33d-ath10k
  DEVICE_TITLE := DomyWifi DW33D ATH10K
  DEVICE_PACKAGES := $(PANDORABOX_ROUTER_NAS_LITE) $(USB2_SUPPORT) $(MAC80211_ATH9K_SUPPORT) $(MAC80211_ATH10K_QCA988X_SUPPORT)  $(NAND_CORE_SUPPORT)
  BOARDNAME = DW33D
  IMAGE_SIZE = 16000k
  CONSOLE = ttyS0,115200
  MTDPARTS = spi0.0:256k(u-boot)ro,64k(u-boot-env)ro,14528k(rootfs),1472k(kernel),64k(art)ro,16000k@0x50000(firmware),16384k@0x0(fullflash);ar934x-nfc:96m(rootfs_data),32m(backup)ro
  IMAGE/sysupgrade.bin = append-rootfs | pad-rootfs | pad-to 14528k | append-kernel | check-size $$$$(IMAGE_SIZE)
endef
TARGET_DEVICES += domywifi-dw33d-ath10k

define Device/sbr-ac1750
  DEVICE_TITLE := Arris sbr-ac1750
  DEVICE_PACKAGES := $(PANDORABOX_ROUTER_NAS_LITE) $(USB2_SUPPORT) $(QCAWIFI_BASE_SUPPORT)  $(QCAWIFI_QCA9880_SUPPORT) $(NAND_CORE_SUPPORT)
  BOARDNAME := SBR-AC1750
  IMAGE_SIZE := 95m
  KERNEL_SIZE := 4096k
  BLOCKSIZE := 128k
  PAGESIZE := 2048
  UBINIZE_OPTS := -E 5
  CONSOLE := ttyS0,115200
  MTDPARTS := ar934x-nfc:1m(u-boot)ro,1m(u-boot-env)ro,4m(kernel),95m(ubi),1m(scfgmgr),4m(openwrt),1m(ft),2m(PKI),1m@0x6d00000(art)ro,36864k@0x200000(kfs),36864k@0x2600000(kfs2)
  IMAGES := sysupgrade.bin factory-kfs.bin
  KERNEL := kernel-bin | patch-cmdline | lzma | uImage lzma
  IMAGE/factory-kfs.bin := append-kernel | pad-to $$$$(KERNEL_SIZE) | append-ubi | check-size $$$$(IMAGE_SIZE)
  IMAGE/sysupgrade.bin := sysupgrade-tar | append-metadata
endef
TARGET_DEVICES += sbr-ac1750

define Device/k2t
  DEVICE_TITLE := Phicomm K2T 
  DEVICE_PACKAGES := $(PANDORABOX_ROUTER_GENERIC) $(USB2_SUPPORT)  $(QCAWIFI_BASE_SUPPORT)  $(QCAWIFI_QCA9888_SUPPORT) qcawifi-boarddata-phicomm-k2t
  BOARDNAME := K2T
  IMAGE_SIZE := 15744k
  MTDPARTS := spi0.0:192k(u-boot)ro,64k(config)ro,320k(permanent),15744k(firmware),64k(art)ro
  SUPPORTED_DEVICES := k2t
  IMAGE/sysupgrade.bin := append-kernel | pad-to $$$$(BLOCKSIZE) | \
	append-rootfs | pad-rootfs | append-metadata | check-size $$$$(IMAGE_SIZE)
endef
TARGET_DEVICES += k2t
