#
# Copyright (C) 2008 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Profile/generic-2440-minimal
  NAME:=Generic 2440 Board (minimal)
  PACKAGES:=
endef

define Profile/generic-2440-minimal/Description
	minimal Package set compatible with the S3C2440 hardware
endef
$(eval $(call Profile,generic-2440-minimal))

