#
# Copyright (C) 2006-2008 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Profile/PBR-M1R
  NAME:=PBR-M1R Profile
  PACKAGES:=wpad-mini 
endef

define Profile/PBR-M1R/Description
	Realtek SOC,Package support for PandoraBox PBR-M1 board
endef

$(eval $(call Profile,PBR-M1R))
