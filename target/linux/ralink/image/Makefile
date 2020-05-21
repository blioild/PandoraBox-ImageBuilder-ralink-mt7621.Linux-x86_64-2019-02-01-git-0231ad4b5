#
# Copyright (C) 2008-2011 OpenWrt.org
# Copyright (C) 2005-2014 lintel<lintel.huang@gmail.com>
# Copyright (C) 2015-2016 GuoGuo<gch981213@gmail.com>
# Copyright (C) 2013-2017 PandoraBox Team
#
#
include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk

UBIFS_OPTS = -m 2048 -e 126KiB -c 4096

define imgname
$(BIN_DIR)/$(IMG_PREFIX)-$(2)-$(1)
endef

define sysupname
$(call imgname,$(1),$(2))-sysupgrade.bin
endef

VMLINUX:=$(IMG_PREFIX)-vmlinux
UIMAGE:=$(IMG_PREFIX)-uImage

DEVICE_VARS += CMDLINE CONSOLE IMAGE_SIZE BOARDNAME

loadaddr-y := 0x80000000
loadaddr-$(CONFIG_RALINK_RT2880) := 0x88000000
loadaddr-$(CONFIG_RALINK_MT7621) := 0x80001000

KERNEL_LOADADDR := $(loadaddr-y)

ralink_default_fw_size_4M=3866624
ralink_default_fw_size_8M=8060928
ralink_default_fw_size_16M=16121856
ralink_default_fw_size_32M=33226752
ralink_default_fw_size_128M=134217728
ralink_default_fw_size_256M=268435456

GENERIC_RSA_KEY=./rsa_keys/generic/rsa_private.key
BOARD_RSA_KEY=./rsa_keys/$(BOARDNAME)/rsa_private.key
#DEVICE_RSA_KEY=./rsa_keys/$(DEVICE_NAME)/rsa_private.key
DEVICE_RSA_KEY ?= $(if $(wildcard $(BOARD_RSA_KEY)),$(BOARD_RSA_KEY),$(GENERIC_RSA_KEY))

GENERIC_RSA_PUBKEY=./rsa_keys/generic/rsa_public.key
BOARD_RSA_PUBKEY=./rsa_keys/$(BOARDNAME)/rsa_public.key
DEVICE_RSA_PUBKEY ?= $(if $(wildcard $(BOARD_RSA_PUBKEY)),$(BOARD_RSA_PUBKEY),$(GENERIC_RSA_PUBKEY))


define Build/patch-pubkey
	$(STAGING_DIR_HOST)/bin/patch_pubkey $@ $(DEVICE_RSA_PUBKEY)
endef

define Build/prepare-pbfw
	$(STAGING_DIR_HOST)/bin/mkpbfw -m fw -k $(DEVICE_RSA_KEY) -K $(IMAGE_KERNEL) -R $(IMAGE_ROOTFS)  -o $@
endef

define Build/trx
	$(STAGING_DIR_HOST)/bin/trx \
		-o $@ \
		-m $(IMAGE_SIZE) \
		-f $(IMAGE_KERNEL) \
		-a 4 -f $(IMAGE_ROOTFS)
endef

define Device/Default
  BOARDNAME :=
  DEVICE_PROFILE = $$(BOARDNAME)
  PROFILES = Default $$(DEVICE_PROFILE)
  MTDPARTS :=
  FILESYSTEMS = $(filter-out jffs2-%,$(TARGET_FILESYSTEMS)) jffs2-$$(BLOCKSIZE)
  CONSOLE = ttyS1,115200
  CMDLINE = $$(if $$(BOARDNAME),board=$$(BOARDNAME)) $$(if $$(MTDPARTS),mtdparts=$$(MTDPARTS)) $$(if $$(CONSOLE),console=$$(CONSOLE))
  KERNEL := kernel-bin | patch-cmdline | patch-pubkey | lzma | uImage lzma
  COMPILE :=
  IMAGE_PREFIX = $(IMG_PREFIX)-$(1)-$(REVISION)
  IMAGES := sysupgrade.bin
  IMAGE_SIZE := $(ralink_default_fw_size_8M)
  SUPPORTED_DEVICES = $(1)
  IMAGE/sysupgrade.bin = prepare-pbfw | pad-rootfs | append-metadata | check-size $$$$(IMAGE_SIZE)
endef

#Packages for Platforms
include $(TOPDIR)/packages.mk

ifeq ($(SUBTARGET),mt7620)
include mt7620.mk
endif
ifeq ($(SUBTARGET),mt7621)
include mt7621.mk
endif

ifeq ($(SUBTARGET),mt7628)
include mt7628.mk
endif

ifndef TARGET_DEVICES
#Legacy build code here

ifeq ($(CONFIG_RALINK_MT7621),y)
define kernel_entry
-a 0x80001000 -e 0x80001000
endef
else
ifeq ($(CONFIG_RALINK_RT2880),y)
define kernel_entry
 -a 0x88000000 -e 0x88000000
endef
else
define kernel_entry
-a 0x80000000 -e 0x80000000
endef
endif
endif

define mkcmdline
board=$(1) console=$(2),$(3)
endef

define CompressLzma
  @$(STAGING_DIR_HOST)/bin/lzma e $(1) -lc1 -lp2 -pb2 $(2)
endef

define PatchKernelLzma

	@cp $(KDIR)/vmlinux $(KDIR)/vmlinux-$(1)
	@$(STAGING_DIR_HOST)/bin/patch-cmdline $(KDIR)/vmlinux-$(1) '$(strip $(2))'
	$(call CompressLzma,$(KDIR)/vmlinux-$(1),$(KDIR)/vmlinux-$(1).bin.lzma)
endef

define MkImage
	@mkimage -A mips -O linux -T kernel -C $(1) $(call kernel_entry)\
		-n 'PandoraBox Linux-$(LINUX_VERSION)' \
		-d $(2) $(3)
endef

define MkImageLzma
	$(call PatchKernelLzma,$(1),$(2))
	$(call MkImage,lzma,$(KDIR)/vmlinux-$(1).bin.lzma,$(KDIR)/vmlinux-$(1).uImage)
endef

define MkImage_CustomMagic
	@mkimage -A mips -O linux -T kernel -C $(1) $(call kernel_entry)\
		-n 'PandoraBox Linux-$(LINUX_VERSION)' -M $(4)\
		-d $(2) $(3)
endef

define MkImageLzma_CustomMagic
	$(call PatchKernelLzma,$(1),$(2))
	$(call MkImage_CustomMagic,lzma,$(KDIR)/vmlinux-$(1).bin.lzma,$(KDIR)/vmlinux-$(1).uImage,$(3))
endef

define CatFiles
		@( dd if=$(1); dd if=$(2) ) > $(3).bin; $(call prepare_generic_squashfs,$(3).bin);
endef

#./mkpbfw -m fw -k rsa_keys/rsa_private.key -K vmlinux.uImage  -R root.squashfs  -o fw.bin
define CatFiles_rsa
		@$(STAGING_DIR_HOST)/bin/mkpbfw -m fw -k $(DEVICE_RSA_KEY) -K $(1) -R $(2)  -o $(3).bin;$(call prepare_generic_squashfs,$(3).bin);
endef

define Sysupgrade/KRuImage
	$(eval output_name=$(IMG_PREFIX)-$(2)-$(1)-sysupgrade)
	$(call CatFiles_rsa,$(KDIR)/vmlinux-$(2).uImage,$(KDIR)/root.$(1),$(KDIR)/$(output_name))
	@if [ `stat -c%s "$(KDIR)/$(output_name).bin"` -gt $(3) ]; then \
		echo "Warning: Image $(output_name).bin is too big." >&2; \
	else \
		cp $(KDIR)/$(output_name).bin $(BIN_DIR)/$(output_name).bin; \
		cp $(KDIR)/$(output_name).bin $(BIN_DIR)/$(output_name)-$(REVISION).bin; \
		rm -rf $(KDIR)/$(output_name).bin; \
	fi
endef

define BuildFirmware/Generic/squashfs

ifeq ($(1),squashfs)
	$(call MkImageLzma,$(2),$(3))
	$(call Sysupgrade/KRuImage,$(1),$(2),$(4))
endif

endef

define BuildFirmware/Generic/nand
	
ifeq ($(1),squashfs)
	$(call MkImageLzma,$(2),$(3))
	$(call prepare_generic_squashfs,$(KDIR)/root.squashfs)
	$(call Image/Build/UbinizeImage,$(2),,squashfs,$(RALINK_UBI_OPTS))
	$(call BuildSysupgrade,$(1),$(2))
	( \
		dd if=$(KDIR)/vmlinux-$(2).uImage bs=2048k conv=sync; \
		dd if=$(BIN_DIR)/$(IMG_PREFIX)-$(2)-$(1)-ubinized.bin; \
	) > $(BIN_DIR)/$(IMG_PREFIX)-$(2)-$(1)-nand-$(REVISION)-$(shell date +%Y%m%d).bin
endif

endef

define BuildFirmware/Generic/squashfs_CustomMagic
	$(call MkImageLzma_CustomMagic,$(2),$(3),$(5))
	$(call Sysupgrade/KRuImage,$(1),$(2),$(4))
endef

define BuildFirmware/Generic/initramfs
	$(call MkImageLzma,$(2),$(3))
	$(CP) $(KDIR)/vmlinux-$(2).uImage $(call imgname,$(1),$(2))-uImage.bin
endef

BuildFirmware/RA_4M/squashfs=$(call BuildFirmware/Generic/squashfs,$(1),$(2),$(3),$(ralink_default_fw_size_4M))
BuildFirmware/RA_8M/squashfs=$(call BuildFirmware/Generic/squashfs,$(1),$(2),$(3),$(ralink_default_fw_size_8M))
BuildFirmware/RA_16M/squashfs=$(call BuildFirmware/Generic/squashfs,$(1),$(2),$(3),$(ralink_default_fw_size_16M))
BuildFirmware/RA_32M/squashfs=$(call BuildFirmware/Generic/squashfs,$(1),$(2),$(3),$(ralink_default_fw_size_32M))
BuildFirmware/RA_4M/initramfs=$(call BuildFirmware/Generic/initramfs,$(1),$(2),$(3),$(4))
BuildFirmware/RA_8M/initramfs=$(call BuildFirmware/Generic/initramfs,$(1),$(2),$(3),$(4))
BuildFirmware/RA_16M/initramfs=$(call BuildFirmware/Generic/initramfs,$(1),$(2),$(3),$(4))
BuildFirmware/RA_32M/initramfs=$(call BuildFirmware/Generic/initramfs,$(1),$(2),$(3),$(4))

BuildFirmware/RA_Custom/squashfs=$(call BuildFirmware/Generic/squashfs,$(1),$(2),$(3),$(4))
BuildFirmware/RA_Custom/initramfs=$(call BuildFirmware/Generic/initramfs,$(1),$(2),$(3))
BuildFirmware/RA_NAND_128M/squashfs=$(call BuildFirmware/Generic/nand,$(1),$(2),$(3),$(ralink_default_fw_size_128M))

#RT5350 Boards
define BuildFirmware/FWR601
	$(call BuildFirmware/RA_16M/$(1),$(1),fwr601,$(call mkcmdline,FWR601,ttyS1,115200) )
endef

define Image/Build/Profile/Default_RT5350

	$(call BuildFirmware/FWR601,$(1))
endef

#RT3052 Boards
define BuildFirmware/HG255D
	$(call BuildFirmware/RA_16M/$(1),$(1),hg255d,$(call mkcmdline,HG255D,ttyS1,115200) )
endef

define Image/Build/Profile/Default_RT3052
	$(call BuildFirmware/HG255D,$(1))
	
	#RT-N13U
	$(call BuildFirmware/RA_16M/$(1),$(1),rt-n13u,$(call mkcmdline,RT-N13U,ttyS1,115200) )
endef

define Image/Build

ifeq ($(CONFIG_RALINK_RT5350),y)
 	$(call Image/Build/Profile/Default_RT5350,$(1))
endif
ifeq ($(CONFIG_RALINK_RT3052),y)
 	$(call Image/Build/Profile/Default_RT3052,$(1))
endif

endef

endif

$(eval $(call BuildImage))
