#
# Copyright (C) 2009-2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk

KDIR_TMP:=$(KDIR)/tmp

define sanitize_profile_name
$(shell echo $(PROFILE) | tr '[:upper:]' '[:lower:]')
endef

define Image/BuildKernel/Template

	$(CP) $(KDIR)/zImage $(BIN_DIR)/$(IMG_PREFIX)-zImage
	echo -ne '\x00\x00\x00\x00' >> $(BIN_DIR)/$(IMG_PREFIX)-zImage
	$(call Image/BuildKernel/MkuImage, \
		none, 0x50008000, 0x50008040, \
		$(BIN_DIR)/$(IMG_PREFIX)-zImage, \
		$(BIN_DIR)/$(IMG_PREFIX)-uImage \
	)

 ifneq ($(CONFIG_TARGET_ROOTFS_INITRAMFS),)
	$(CP) $(KDIR)/zImage-initramfs $(BIN_DIR)/$(IMG_PREFIX)-zImage-initramfs
	echo -ne '\x00\x00\x00\x00' >> $(BIN_DIR)/$(IMG_PREFIX)-zImage-initramfs
	$(call Image/BuildKernel/MkuImage, \
		none, 0x50008000, 530008040, \
		$(BIN_DIR)/$(IMG_PREFIX)-zImage-initramfs, \
		$(BIN_DIR)/$(IMG_PREFIX)-uImage-initramfs \
	)
 endif

 ifneq ($(1),)
# 	$(CP) $(LINUX_DIR)/arch/arm/boot/dts/avanta-$(1).dtb $(BIN_DIR)/$(IMG_PREFIX)-$(1).dtb

	$(CP) $(KDIR)/zImage $(BIN_DIR)/$(IMG_PREFIX)-$(call sanitize_profile_name)-zImage
# 	cat $(BIN_DIR)/$(IMG_PREFIX)-$(1).dtb >> $(BIN_DIR)/$(IMG_PREFIX)-$(call sanitize_profile_name)-zImage
	$(call Image/BuildKernel/MkuImage, \
		none, 0x50008000, 0x50008040, \
		$(BIN_DIR)/$(IMG_PREFIX)-$(call sanitize_profile_name)-zImage, \
		$(BIN_DIR)/$(IMG_PREFIX)-$(call sanitize_profile_name)-uImage \
	)

  ifneq ($(CONFIG_TARGET_ROOTFS_INITRAMFS),)
	$(CP) $(KDIR)/zImage-initramfs $(BIN_DIR)/$(IMG_PREFIX)-$(call sanitize_profile_name)-zImage-initramfs
# 	cat $(BIN_DIR)/$(IMG_PREFIX)-$(1).dtb >> $(BIN_DIR)/$(IMG_PREFIX)-$(call sanitize_profile_name)-zImage-initramfs
	$(call Image/BuildKernel/MkuImage, \
		none, 0x50008000, 0x50008040, \
		$(BIN_DIR)/$(IMG_PREFIX)-$(call sanitize_profile_name)-zImage-initramfs, \
		$(BIN_DIR)/$(IMG_PREFIX)-$(call sanitize_profile_name)-uImage-initramfs \
	)
  endif
 endif
endef

define Image/InstallKernel/Template

 ifneq ($(CONFIG_TARGET_ROOTFS_INCLUDE_KERNEL),)
	$(INSTALL_DIR) $(TARGET_DIR)/boot
   ifneq ($(CONFIG_TARGET_ROOTFS_INCLUDE_UIMAGE),)
	$(CP) $(BIN_DIR)/$(IMG_PREFIX)-uImage $(TARGET_DIR)/boot/
	ln -sf $(IMG_PREFIX)-uImage $(TARGET_DIR)/boot/uImage
   endif
   ifneq ($(CONFIG_TARGET_ROOTFS_INCLUDE_ZIMAGE),)
	$(CP) $(BIN_DIR)/$(IMG_PREFIX)-zImage $(TARGET_DIR)/boot/
	ln -sf $(IMG_PREFIX)-zImage $(TARGET_DIR)/boot/zImage
   endif
 endif

 ifneq ($(CONFIG_TARGET_ROOTFS_INCLUDE_DTB),)
	$(INSTALL_DIR) $(TARGET_DIR)/boot
  ifneq ($(1),)
	$(CP) $(BIN_DIR)/$(IMG_PREFIX)-$(1).dtb $(TARGET_DIR)/boot/
	ln -sf $(IMG_PREFIX)-$(1).dtb $(TARGET_DIR)/boot/$(1).dtb
  endif
 endif
endef

define Image/Build/jffs2-nand-2048-128k
	dd if=$(KDIR)/root.$(1) of=$(BIN_DIR)/$(IMG_PREFIX)-$(call sanitize_profile_name)-$(1).img \
		bs=2048 conv=sync
endef

define Image/Build/squashfs
	$(call prepare_generic_squashfs,$(KDIR)/root.squashfs)
	( \
		dd if=$(KDIR)/zImage bs=4096k conv=sync; \
		dd if=$(KDIR)/root.$(1) bs=128k conv=sync; \
	) > $(BIN_DIR)/$(IMG_PREFIX)-$(call sanitize_profile_name)-$(1).img

 ifneq ($($(PROFILE)_UBI_OPTS),)
	$(call Image/Build/UbinizeImage,$(call sanitize_profile_name),,squashfs,$($(PROFILE)_UBI_OPTS))
 endif
	
endef

define BuildSysupgrade
	$(call Image/Build/SysupgradeNAND,$(2),$(1),$(BIN_DIR)/$(IMG_PREFIX)-$(2)-uImage)
endef

define Image/mkfs/targz

	$(TAR) -czpf $(BIN_DIR)/$(IMG_PREFIX)-$(call sanitize_profile_name)-rootfs.tar.gz --numeric-owner --owner=0 --group=0 -C $(TARGET_DIR)/ .
endef

define Image/Build/ubifs

 ifneq ($($(PROFILE)_UBIFS_OPTS),)
	$(CP) $(KDIR)/root.ubifs $(BIN_DIR)/$(IMG_PREFIX)-$(call sanitize_profile_name)-rootfs.ubifs
 endif
endef

define Image/Build/ubi

 ifneq ($($(PROFILE)_UBI_OPTS),)
	$(CP) $(KDIR)/root.ubi $(BIN_DIR)/$(IMG_PREFIX)-$(call sanitize_profile_name)-rootfs.ubi
 endif
endef

Image/BuildKernel/Template/Generic=$(call Image/BuildKernel/Template)
Image/InstallKernel/Template/Generic=$(call Image/InstallKernel/Template)

Image/BuildKernel/Template/SMDK6410=$(call Image/BuildKernel/Template,smdk6410)
Image/InstallKernel/Template/SMDK6410=$(call Image/InstallKernel/Template,smdk6410)
define Image/Build/Template/SMDK6410

 ifeq ($(1),squashfs)
	$(call BuildSysupgrade,$(1),$(call sanitize_profile_name))
	( \
		dd if=$(BIN_DIR)/$(IMG_PREFIX)-$(call sanitize_profile_name)-uImage bs=2048k conv=sync; \
		dd if=$(BIN_DIR)/$(IMG_PREFIX)-$(call sanitize_profile_name)-$(1)-ubinized.bin; \
	) > $(BIN_DIR)/$(IMG_PREFIX)-$(call sanitize_profile_name)-$(1)-combined.bin
 endif

endef

define Image/BuildKernel
	$(call Image/BuildKernel/Template/$(PROFILE))
endef

define Image/InstallKernel
	$(call Image/InstallKernel/Template/$(PROFILE))
endef

define Image/Build
	$(if $(Image/Build/$(1)), \
		$(call Image/Build/$(1),$(1)), \
		$(CP) $(KDIR)/root.$(1) $(BIN_DIR)/$(IMG_PREFIX)-$(call sanitize_profile_name)-$(1).img \
	)

	$(call Image/Build/Template/$(PROFILE),$(1))
endef

$(eval $(call BuildImage))
