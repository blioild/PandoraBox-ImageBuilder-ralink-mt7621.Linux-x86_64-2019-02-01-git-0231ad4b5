#
# Copyright (C) 2008-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk

KERNEL_LOADADDR = 0x80060000

DEVICE_VARS += BOARDNAME CMDLINE CONSOLE IMAGE_SIZE LOADER_TYPE

DEVICE_VARS += DAP_SIGNATURE NETGEAR_BOARD_ID NETGEAR_HW_ID NETGEAR_KERNEL_MAGIC ROOTFS_SIZE SEAMA_SIGNATURE

define Build/alfa-network-rootfs-header
	mkimage \
		-A mips -O linux -T filesystem -C lzma -a 0 -e 0 \
		-n 'RootfsImage' -d $@ $@.new
	@mv $@.new $@
endef

define Build/append-md5sum-bin
	$(STAGING_DIR_HOST)/bin/mkhash md5 $@ | sed 's/../\\\\x&/g' |\
		xargs echo -ne >> $@
endef

define Build/append-string
	echo -n $(1) >> $@
endef

define Build/mkwrggimg
	$(STAGING_DIR_HOST)/bin/mkwrggimg -b \
		-i $@ -o $@.imghdr -d /dev/mtdblock/1 \
		-m $(BOARDNAME) -s $(DAP_SIGNATURE) \
		-v $(VERSION_DIST) -B $(REVISION)
	mv $@.imghdr $@
endef

define Build/mkdapimg2
	$(STAGING_DIR_HOST)/bin/mkdapimg2 \
		-i $@ -o $@.new \
		-s $(DAP_SIGNATURE) \
		-v $(VERSION_DIST)-$(firstword $(subst +, ,$(firstword $(subst -, ,$(REVISION))))) \
		-r Default \
		$(if $(1),-k $(1))
	mv $@.new $@
endef

define Build/netgear-squashfs
	rm -rf $@.fs $@.squashfs
	mkdir -p $@.fs/image
	cp $@ $@.fs/image/uImage
	$(STAGING_DIR_HOST)/bin/mksquashfs-lzma \
		$@.fs $@.squashfs \
		-noappend -root-owned -be -b 65536 \
		$(if $(SOURCE_DATE_EPOCH),-fixed-time $(SOURCE_DATE_EPOCH))

	dd if=/dev/zero bs=1k count=1 >> $@.squashfs
	mkimage \
		-A mips -O linux -T filesystem -C none \
		-M $(NETGEAR_KERNEL_MAGIC) \
		-a 0xbf070000 -e 0xbf070000 \
		-n 'MIPS $(VERSION_DIST) Linux-$(LINUX_VERSION)' \
		-d $@.squashfs $@
	rm -rf $@.squashfs $@.fs
endef

define Build/netgear-uImage
	$(call Build/uImage,$(1) -M $(NETGEAR_KERNEL_MAGIC))
endef

define Build/relocate-kernel
	rm -rf $@.relocate
	$(CP) ../../generic/image/relocate $@.relocate
	$(MAKE) -j1 -C $@.relocate KERNEL_ADDR=$(KERNEL_LOADADDR) CROSS_COMPILE=$(TARGET_CROSS)
	( \
		dd if=$@.relocate/loader.bin bs=32 conv=sync && \
		perl -e '@s = stat("$@"); print pack("N", @s[7])' && \
		cat "$@" \
	) > "$@.new"
	mv "$@.new" "$@"
	rm -rf $@.relocate
endef

define Build/seama
	$(STAGING_DIR_HOST)/bin/seama -i $@ $(if $(1),$(1),-m "dev=/dev/mtdblock/1" -m "type=firmware")
	mv $@.seama $@
endef

define Build/seama-seal
	$(call Build/seama,-s $@.seama $(1))
endef

define Build/teltonika-fw-fake-checksum
	# Teltonika U-Boot web based firmware upgrade/recovery routine compares
	# 16 bytes from md5sum1[16] field in TP-Link v1 header (offset: 76 bytes
	# from begin of the firmware file) with 16 bytes stored just before
	# 0xdeadc0de marker. Values are only compared, MD5 sum is not verified.
	let \
		offs="$$(stat -c%s $@) - 20"; \
		dd if=$@ bs=1 count=16 skip=76 |\
		dd of=$@ bs=1 count=16 seek=$$offs conv=notrunc
endef

define Build/uImageHiWiFi
	# Field ih_name needs to start with "tw150v1"
	mkimage -A $(LINUX_KARCH) \
		-O linux -T kernel \
		-C $(1) -a $(KERNEL_LOADADDR) -e $(if $(KERNEL_ENTRY),$(KERNEL_ENTRY),$(KERNEL_LOADADDR)) \
		-n 'tw150v1 $(call toupper,$(LINUX_KARCH)) $(VERSION_DIST) Linux-$(LINUX_VERSION)' -d $@ $@.new
	@mv $@.new $@
endef

define Build/wrgg-pad-rootfs
	$(STAGING_DIR_HOST)/bin/padjffs2 $(IMAGE_ROOTFS) -c 64 >>$@
endef

# include ./generic.mk
# include ./generic-legacy-devices.mk
# include ./generic-tp-link.mk
# include ./nand.mk
# include ./legacy.mk
include $(TOPDIR)/packages.mk
include ./common-tp-link.mk
include ./generic.mk
include ./legacy.mk

define Build/loader-common
	rm -rf $@.src
	$(MAKE) -C lzma-loader \
		PKG_BUILD_DIR="$@.src" \
		TARGET_DIR="$(dir $@)" LOADER_NAME="$(notdir $@)" \
		BOARD="$(BOARDNAME)" \
		LZMA_TEXT_START=0x80a00000 LOADADDR=0x80060000 \
		$(1) compile loader.$(LOADER_TYPE)
	mv "$@.$(LOADER_TYPE)" "$@"
	rm -rf $@.src
endef

define Build/loader-kernel
	$(call Build/loader-common,LOADER_DATA="$@")
endef

define Build/loader-kernel-cmdline
	$(call Build/loader-common,LOADER_DATA="$@" KERNEL_CMDLINE="$(CMDLINE)")
endef

define Device/Default
  BOARDNAME :=
  DEVICE_PROFILE = $$(BOARDNAME)
  PROFILES = Default Minimal $$(DEVICE_PROFILE)
  MTDPARTS :=
  BLOCKSIZE := 64k
  CONSOLE := ttyS0,115200
  CMDLINE = $$(if $$(BOARDNAME),board=$$(BOARDNAME)) $$(if $$(MTDPARTS),mtdparts=$$(MTDPARTS)) $$(if $$(CONSOLE),console=$$(CONSOLE))
  KERNEL := kernel-bin | patch-cmdline | lzma | uImage lzma
  COMPILE :=
  IMAGE_PREFIX = $(IMG_PREFIX)-$(1)-$(REVISION)
  UBINIZE_OPTS := -E 5
  IMAGES := sysupgrade.bin
  IMAGE/sysupgrade.bin = append-kernel | pad-to $$$$(BLOCKSIZE) | append-rootfs | pad-rootfs | check-size $$$$(IMAGE_SIZE)
endef

$(eval $(call BuildImage))
