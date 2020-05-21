# OpenWrt base 
#
# Copyright (C) 2015 PandoraBox
#
#

#
# Realtek 8198CS I2C Driver
#
define KernelPackage/i2c-rtl8198c
  SUBMENU:=Realtek Drivers
  TITLE:=Realtek I2C Driver
  DEPENDS:=@TARGET_realtek +kmod-i2c-core
  KCONFIG:=CONFIG_RTL8198C_I2C
  FILES:=$(LINUX_DIR)/drivers/i2c/busses/i2c-rtl8198c.ko
  AUTOLOAD:=$(call AutoLoad,58,i2c-rtl8198c)
endef

define KernelPackage/i2c-rtl8198c/description
  This package is for Realtek 8198c I2C Drivers.
endef

$(eval $(call KernelPackage,i2c-rtl8198c))
