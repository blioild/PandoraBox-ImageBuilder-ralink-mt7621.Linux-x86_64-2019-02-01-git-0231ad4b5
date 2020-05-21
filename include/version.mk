#
# Copyright (C) 2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

# Substituted by SDK, do not remove
REVISION:=2019-02-01-git-0231ad4b5

PKG_CONFIG_DEPENDS += \
	CONFIG_VERSION_NUMBER \
	CONFIG_VERSION_NICK \
	CONFIG_VERSION_REPO \
	CONFIG_VERSION_DIST \
	CONFIG_VERSION_MANUFACTURER \
	CONFIG_VERSION_PRODUCT \
	CONFIG_VERSION_HWREV \

sanitize = $(call tolower,$(subst _,-,$(subst $(space),-,$(1))))

#发行名称
VERSION_DIST:=$(call qstrip,$(CONFIG_VERSION_DIST))
VERSION_DIST:=$(if $(VERSION_DIST),$(VERSION_DIST),PandoraBox)
VERSION_DIST_SANITIZED:=$(call sanitize,$(VERSION_DIST))

#发行代号
VERSION_NICK:=$(call qstrip,$(CONFIG_VERSION_NICK))
VERSION_NICK:=$(if $(VERSION_NICK),$(VERSION_NICK),$(RELEASE))

#Release版本号
VERSION_CODE:=$(call qstrip,$(CONFIG_VERSION_NUMBER))
VERSION_CODE:=$(if $(VERSION_CODE),$(VERSION_CODE),$(shell date +%y.%m))

#commit次数
COMMIT_VERSION:=$(shell git log |grep -e 'commit [a-zA-Z0-9]*' | wc -l)

#具体REV版本号
VERSION_NUMBER:=$(call qstrip,$(CONFIG_VERSION_NUMBER))
VERSION_NUMBER:=$(if $(VERSION_NUMBER),$(VERSION_NUMBER),$(COMMIT_VERSION))

#OPKG源路径
VERSION_REPO:=$(call qstrip,$(CONFIG_VERSION_REPO))
VERSION_REPO:=$(if $(VERSION_REPO),$(VERSION_REPO),http://downloads.pangubox.com:6380/pandorabox/$(VERSION_CODE))

#厂商
VERSION_MANUFACTURER:=$(call qstrip,$(CONFIG_VERSION_MANUFACTURER))
VERSION_MANUFACTURER:=$(if $(VERSION_MANUFACTURER),$(VERSION_MANUFACTURER),PandoraBox-Team)

VERSION_MANUFACTURER_URL:=$(call qstrip,$(CONFIG_VERSION_MANUFACTURER_URL))
VERSION_MANUFACTURER_URL:=$(if $(VERSION_MANUFACTURER_URL),$(VERSION_MANUFACTURER_URL),http://www.pandorabox.com.cn)

#产品名称
VERSION_PRODUCT:=$(call qstrip,$(CONFIG_VERSION_PRODUCT))
VERSION_PRODUCT:=$(if $(VERSION_PRODUCT),$(VERSION_PRODUCT),PandoraBox)

#硬件版本
VERSION_HWREV:=$(call qstrip,$(CONFIG_VERSION_HWREV))
VERSION_HWREV:=$(if $(VERSION_HWREV),$(VERSION_HWREV),v1)

define taint2sym
$(CONFIG_$(firstword $(subst :, ,$(subst +,,$(subst -,,$(1))))))
endef

define taint2name
$(lastword $(subst :, ,$(1)))
endef

VERSION_TAINT_SPECS := \
	-ALL:no-all \
	-IPV6:no-ipv6 \
	+USE_EGLIBC:eglibc \
	+USE_MKLIBS:mklibs \
	+BUSYBOX_CUSTOM:busybox \

VERSION_TAINTS := $(strip $(foreach taint,$(VERSION_TAINT_SPECS), \
	$(if $(findstring +,$(taint)), \
		$(if $(call taint2sym,$(taint)),$(call taint2name,$(taint))), \
		$(if $(call taint2sym,$(taint)),,$(call taint2name,$(taint))) \
	)))

PKG_CONFIG_DEPENDS += $(foreach taint,$(VERSION_TAINT_SPECS),$(call taint2sym,$(taint)))

VERSION_SED:=$(SED) 's,%U,$(VERSION_REPO),g' \
	-e 's,%V,$(VERSION_NUMBER),g' \
	-e 's,%v,\L$(subst $(space),_,$(VERSION_NUMBER)),g' \
	-e 's,%C,$(VERSION_CODE),g' \
	-e 's,%c,\L$(subst $(space),_,$(VERSION_CODE)),g' \
	-e 's,%N,$(VERSION_NICK),g' \
	-e 's,%n,\L$(subst $(space),_,$(VERSION_NICK)),g' \
	-e 's,%D,$(VERSION_DIST),g' \
	-e 's,%d,\L$(subst $(space),_,$(VERSION_DIST)),g' \
	-e 's,%R,$(REVISION),g' \
	-e 's,%T,$(BOARD),g' \
	-e 's,%S,$(BOARD)/$(if $(SUBTARGET),$(SUBTARGET),generic),g' \
	-e 's,%A,$(ARCH_PACKAGES),g' \
	-e 's,%t,$(VERSION_TAINTS),g' \
	-e 's,%M,$(VERSION_MANUFACTURER),g' \
	-e 's,%m,$(VERSION_MANUFACTURER_URL),g' \
	-e 's,%b,$(VERSION_BUG_URL),g' \
	-e 's,%s,$(VERSION_SUPPORT_URL),g' \
	-e 's,%P,$(VERSION_PRODUCT),g' \
	-e 's,%Q,$(COMMIT_VERSION),g' \
	-e 's,%h,$(VERSION_HWREV),g'
	
VERSION_SED_SCRIPT:=$(subst '\'','\'\\\\\'\'',$(VERSION_SED))
