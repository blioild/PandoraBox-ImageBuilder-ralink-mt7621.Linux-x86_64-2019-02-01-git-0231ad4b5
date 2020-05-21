# PandoraBox Ralink/MTK Modules
# 
# Copyright (C) 2013 lintel<lintel.huang@gmail.com>
# Copyright (C) 2015 PandoraBox Team
#

define KernelPackage/usb-rt305x-dwc_otg
  TITLE:=RT305X USB OTG controller driver
  DEPENDS:=@TARGET_ralink_rt305x
  KCONFIG:= \
	CONFIG_DWC_OTG \
	CONFIG_DWC_OTG_HOST_ONLY=y \
	CONFIG_DWC_OTG_DEVICE_ONLY=n \
	CONFIG_DWC_OTG_DEBUG=n
  FILES:=$(LINUX_DIR)/drivers/usb/dwc_otg/dwc_otg.ko
  AUTOLOAD:=$(call AutoLoad,54,dwc_otg,1)
  $(call AddDepends/usb)
endef

define KernelPackage/usb-rt305x-dwc_otg/description
  This driver provides USB Device Controller support for the
  Synopsys DesignWare USB OTG Core used in the Ralink RT305X SoCs.
endef

$(eval $(call KernelPackage,usb-rt305x-dwc_otg))

#
# MT762x MMC SD
#
define KernelPackage/mt762x-mmc
  SUBMENU:=Ralink Drivers
  TITLE:=Ralink/MTK SDXC/MMC Driver
  DEPENDS:= +kmod-mmc
  KCONFIG:=CONFIG_MTK_MMC \
	   CONFIG_MTK_AEE_KDUMP=n \
	   CONFIG_MTK_MMC_CD_POLL=y \
	   CONFIG_ETH_ONE_PORT_ONLY=y \
	   CONFIG_MTK_MMC_EMMC_8BIT=n
  FILES:=$(LINUX_DIR)/drivers/mmc/host/mtk-mmc/mtk_sd.ko
  AUTOLOAD:=$(call AutoLoad,92,mtk_sd,1)
endef

define KernelPackage/mt762x-mmc/description
  This package contains the MT762x MMC driver,use for SDXC/MMC.
endef

$(eval $(call KernelPackage,mt762x-mmc))


#
# MT7628 AES Engine
#
define KernelPackage/mt7628-aes
  SUBMENU:=Ralink Drivers
  TITLE:=MediaTek MT7628 AES Engine
  KCONFIG:=CONFIG_CRYPTO_DEV_MTK_AES \
			CONFIG_CRYPTO_USER_API_SKCIPHER
  DEPENDS+=+kmod-crypto-core +kmod-crypto-aes +kmod-crypto-manager @TARGET_ralink_mt7628
  
  FILES:=$(LINUX_DIR)/drivers/crypto/aes_engine/mtk_aes.ko
  AUTOLOAD:=$(call AutoLoad,93,mtk_aes,1)
endef

define KernelPackage/mt7628-aes/description
  Turn on the configuration will include MediaTek AES Engine driver.
endef

$(eval $(call KernelPackage,mt7628-aes))

#
#Ralink I2C Driver
#
define KernelPackage/ralink-i2c
  SUBMENU:=Ralink Drivers
  TITLE:=Ralink I2C Driver
  DEPENDS:=@TARGET_ralink +kmod-i2c-core
  KCONFIG:=CONFIG_I2C_RALINK
  FILES:=$(LINUX_DIR)/drivers/i2c/busses/i2c-ralink.ko
  AUTOLOAD:=$(call AutoLoad,59,i2c-ralink,1)
endef

define KernelPackage/ralink-i2c/description
  This package for Ralink I2C Drivers.
endef

$(eval $(call KernelPackage,ralink-i2c))

#
#Ralink I2S ASound Driver
#

define KernelPackage/sound-mt762x
  TITLE:=MT762x I2S Alsa Driver
  DEPENDS:= +kmod-sound-soc-core +kmod-regmap +kmod-ralink-i2c @(TARGET_ralink_mt7628||TARGET_ralink_mt7621||TARGET_ralink_mt7620)
  KCONFIG:= \
	CONFIG_SND_MT76XX_SOC \
	CONFIG_SND_MT76XX_I2S \
	CONFIG_SND_MT76XX_PCM \
	CONFIG_SND_SOC_WM8960
  FILES:= \
	$(LINUX_DIR)/sound/soc/mtk/snd-soc-mt76xx-i2s-ctl.ko \
	$(LINUX_DIR)/sound/soc/mtk/snd-soc-mt76xx-i2s.ko \
	$(LINUX_DIR)/sound/soc/mtk/snd-soc-mt76xx-pcm.ko \
	$(LINUX_DIR)/sound/soc/mtk/snd-soc-mt76xx-machine.ko \
	$(LINUX_DIR)/sound/soc/codecs/snd-soc-wm8960.ko
  AUTOLOAD:=$(call AutoLoad,90,snd-soc-wm8960 snd-soc-mt76xx-i2s-ctl snd-soc-mt76xx-i2s snd-soc-mt76xx-pcm snd-soc-mt76xx-machine)
  $(call AddDepends/sound)
endef

define KernelPackage/sound-mt762x/description
 Alsa modules for mt762x i2s controller.
endef

$(eval $(call KernelPackage,sound-mt762x))

#
#Ralink HWNAT Driver
#
define KernelPackage/ralink-hwnat
  SUBMENU:=Ralink Drivers
  TITLE:=Ralink/MTK HW-NAT Driver
  DEPENDS:=@TARGET_ralink
  FILES:=$(LINUX_DIR)/net/nat/hw_nat/hw_nat.ko
endef

define KernelPackage/ralink-hwnat/description
  This package for Ralink/MTK Hardware NAT Drivers.
endef

$(eval $(call KernelPackage,ralink-hwnat))

define KernelPackage/ralink-wdt
   SUBMENU:=Ralink Drivers
   TITLE:=Ralink Watchdog timer
   DEPENDS:=@TARGET_ralink
   KCONFIG:=CONFIG_RALINK_WATCHDOG \
 	CONFIG_RALINK_TIMER_WDG_RESET_OUTPUT=n
 		
   FILES:=$(LINUX_DIR)/drivers/watchdog/ralink_wdt.ko
   AUTOLOAD:=$(call AutoLoad,50,ralink_wdt)
 endef
 
 define KernelPackage/ralink-wdt/description
   Kernel module for Ralink/MTK watchdog timer.
endef
 
 $(eval $(call KernelPackage,ralink-wdt))
