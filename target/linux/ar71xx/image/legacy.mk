rootfs_type=$(patsubst squashfs-%,squashfs,$(1))

# $(1): rootfs type.
# $(2): board name.
define imgname
$(BIN_DIR)/$(IMG_PREFIX)-$(2)-$(REVISION)-$(call rootfs_type,$(1))
endef

define rootfs_align
$(patsubst %-256k,0x40000,$(patsubst %-128k,0x20000,$(patsubst %-64k,0x10000,$(patsubst squashfs%,0x4,$(patsubst root.%,%,$(1))))))
endef

define sysupname
$(call imgname,$(1),$(2))-sysupgrade.bin
endef

define factoryname
$(call imgname,$(1),$(2))-factory.bin
endef

COMMA:=,

define mkcmdline
$(if $(1),board=$(1) )$(if $(2),console=$(2)$(COMMA)$(3))
endef

define mtdpartsize
$(shell sz=`echo '$(2)' | sed -ne 's/.*[:$(COMMA)]\([0-9]*\)k[@]*[0-9a-zx]*($(1)).*/\1/p'`; [ -n "$$sz" ] && echo $$(($$sz * 1024)))
endef

# $(1)      : name of image build method to be used, e.g., AthLzma.
# $(2)      : name of the build template to be used, e.g. 64k, 64kraw, 128k, etc.
# $(3)      : name of the profile to be defined.
# $(4)      : board name.
# $(5)~$(7) : arguments for $(mkcmdline)
#		board=$(1) console=$(2),$(3)
# $(8)~$(14): extra arguments.
define SingleProfile
  # $(1): action name, e.g. loader, buildkernel, squashfs, etc.
  define Image/Build/Profile/$(3)
	$$(call Image/Build/Template/$(2)/$$(1),$(1),$(4),$$(call mkcmdline,$(5),$(6),$(7)),$(8),$(9),$(10),$(11),$(12),$(13),$(14))
  endef
endef

LOADER_MAKE := $(NO_TRACE_MAKE) -C lzma-loader KDIR=$(KDIR)

VMLINUX:=$(BIN_DIR)/$(IMG_PREFIX)-vmlinux
UIMAGE:=$(BIN_DIR)/$(IMG_PREFIX)-uImage

# $(1): input file.
# $(2): output file.
# $(3): extra arguments for lzma.
define CompressLzma
  $(STAGING_DIR_HOST)/bin/lzma e $(1) -lc1 -lp2 -pb2 $(3) $(2)
endef

define PatchKernel
	cp $(KDIR)/vmlinux$(3) $(KDIR_TMP)/vmlinux$(3)-$(1)
	$(STAGING_DIR_HOST)/bin/patch-cmdline $(KDIR_TMP)/vmlinux$(3)-$(1) "$(strip $(2))"
endef

define PatchKernel/initramfs
	$(call PatchKernel,$(1),$(2),-initramfs)
	cp $(KDIR_TMP)/vmlinux-initramfs-$(1) $(call imgname,initramfs,$(1)).bin
endef

# $(1): board name.
# $(2): kernel command line.
# $(3): extra argumetns for lzma.
# $(4): name suffix, e.g. "-initramfs".
define PatchKernelLzma
	cp $(KDIR)/vmlinux$(4) $(KDIR_TMP)/vmlinux$(4)-$(1)
	$(STAGING_DIR_HOST)/bin/patch-cmdline $(KDIR_TMP)/vmlinux$(4)-$(1) "$(strip $(2))"
	$(call CompressLzma,$(KDIR_TMP)/vmlinux$(4)-$(1),$(KDIR_TMP)/vmlinux$(4)-$(1).bin.lzma,$(3))
endef

define PatchKernelGzip
	cp $(KDIR)/vmlinux$(3) $(KDIR_TMP)/vmlinux$(3)-$(1)
	$(STAGING_DIR_HOST)/bin/patch-cmdline $(KDIR_TMP)/vmlinux$(3)-$(1) "$(strip $(2))"
	gzip -9n -c $(KDIR_TMP)/vmlinux$(3)-$(1) > $(KDIR_TMP)/vmlinux$(3)-$(1).bin.gz
endef

ifneq ($(SUBTARGET),mikrotik)
# $(1): compression method of the data.
# $(2): extra arguments.
# $(3): input data file.
# $(4): output file.
define MkuImage
	mkimage -A mips -O linux -T kernel -a 0x80060000 -C $(1) $(2) \
		-e 0x80060000 -n 'MIPS $(VERSION_DIST) Linux-$(LINUX_VERSION)' \
		-d $(3) $(4)
endef

# $(1): board name.
# $(2): kernel command line.
# $(3): extra arguments for lzma.
# $(4): name suffix, e.g. "-initramfs".
# $(5): extra arguments for mkimage.
define MkuImageLzma
	$(call PatchKernelLzma,$(1),$(2),$(3),$(4))
	$(call MkuImage,lzma,$(5),$(KDIR_TMP)/vmlinux$(4)-$(1).bin.lzma,$(KDIR_TMP)/vmlinux$(4)-$(1).uImage)
endef

define MkuImageLzma/initramfs
	$(call PatchKernelLzma,$(1),$(2),$(3),-initramfs)
	$(call MkuImage,lzma,$(4),$(KDIR_TMP)/vmlinux-initramfs-$(1).bin.lzma,$(call imgname,initramfs,$(1))-uImage.bin)
endef

define MkuImageGzip
	$(call PatchKernelGzip,$(1),$(2))
	$(call MkuImage,gzip,,$(KDIR_TMP)/vmlinux-$(1).bin.gz,$(KDIR_TMP)/vmlinux-$(1).uImage)
endef

define MkuImageGzip/initramfs
	$(call PatchKernelGzip,$(1),$(2),-initramfs)
	$(call MkuImage,gzip,,$(KDIR_TMP)/vmlinux-initramfs-$(1).bin.gz,$(call imgname,initramfs,$(1))-uImage.bin)
endef

define MkuImageOKLI
	$(call MkuImage,lzma,-M 0x4f4b4c49,$(KDIR)/vmlinux.bin.lzma,$(KDIR_TMP)/vmlinux-$(1).okli)
endef
endif

# $(1): name of the 1st file.
# $(2): size limit of the 1st file if it is greater than 262144, or
#       the erase size of the flash if it is greater than zero and less
#       than 262144
# $(3): name of the 2nd file.
# $(4): size limit of the 2nd file if $(2) is greater than 262144, otherwise
#       it is the size limit of the output file
# $(5): name of the output file.
# $(6): padding size.
define CatFiles
	if [ $(2) -eq 0 ]; then \
		filename="$(3)"; fstype=$${filename##*\.}; \
		case "$${fstype}" in \
		*) bs=`stat -c%s $(1)`;; \
		esac; \
		( dd if=$(1) bs=$${bs} conv=sync;  cat $(3) ) > $(5); \
		if [ -n "$(6)" ]; then \
			case "$${fstype}" in \
			squashfs*) \
				padjffs2 $(5) $(6); \
				;; \
			esac; \
		fi; \
		if [ `stat -c%s $(5)` -gt $(4) ]; then \
			echo "Warning: $(5) is too big (> $(4) bytes)" >&2; \
			rm -f $(5); \
		fi; \
	else if [ $(2) -gt 262144 ]; then \
		if [ `stat -c%s "$(1)"` -gt $(2) ]; then \
			echo "Warning: $(1) is too big (> $(2) bytes)" >&2; \
		else if [ `stat -c%s $(3)` -gt $(4) ]; then \
			echo "Warning: $(3) is too big (> $(4) bytes)" >&2; \
		else \
			( dd if=$(1) bs=$(2) conv=sync; dd if=$(3) ) > $(5); \
		fi; fi; \
	else \
		( dd if=$(1) bs=$(2) conv=sync; dd if=$(3) ) > $(5); \
		if [ `stat -c%s $(5)` -gt $(4) ]; then \
			echo "Warning: $(5) is too big (> $(4) bytes)" >&2; \
			rm -f $(5); \
		fi; \
	fi; fi
endef

# $(1): rootfs type.
# $(2): board name.
# $(3): kernel image size limit.
# $(4): rootfs image size limit.
# $(5): padding argument for padjffs2.
Sysupgrade/KR=$(call CatFiles,$(2),$(3),$(KDIR)/root.$(1),$(4),$(call sysupname,$(1),$(5)))
Sysupgrade/KRuImage=$(call CatFiles,$(KDIR_TMP)/vmlinux-$(2).uImage,$(3),$(KDIR)/root.$(1),$(4),$(call sysupname,$(1),$(2)),$(5))
Sysupgrade/RKuImage=$(call CatFiles,$(KDIR)/root.$(1),$(4),$(KDIR_TMP)/vmlinux-$(2).uImage,$(3),$(call sysupname,$(1),$(2)))

# $(1): ubinize ini file
# $(2): working directory
# $(3): output file
# $(4): physical erase block size
# $(5): minimum I/O unit size
# $(6): custom options
define ubinize
	$(CP) $(1) $(2)
	( cd $(2); $(STAGING_DIR_HOST)/bin/ubinize -o $(3) -p $(4) -m $(5) $(6) $(1))
endef

#
# Embed lzma-compressed kernel inside lzma-loader.
#
# $(1), suffix of output filename, e.g. generic, lowercase board name, etc.
# $(2), suffix of target file to build, e.g. bin, gz, elf
# $(3), kernel command line to pass from lzma-loader to kernel
# $(4), unused here
# $(5), suffix of kernel filename, e.g. -initramfs, or empty
define Image/BuildLoader
	-rm -rf $(KDIR)/lzma-loader
	$(LOADER_MAKE) LOADER=loader-$(1).$(2) KERNEL_CMDLINE="$(3)"\
		LZMA_TEXT_START=0x80a00000 LOADADDR=0x80060000 \
		LOADER_DATA="$(KDIR)/vmlinux$(5).bin.lzma" BOARD="$(1)" \
		compile loader.$(2)
	-$(if $(5),$(CP) $(KDIR)/loader-$(1).$(2) $(KDIR)/loader-$(1)$(5).$(2))
endef

#
# Build lzma-loader alone which will search for lzma-compressed kernel identified by
# uImage header with magic "OKLI" at boot time.
#
# $(4), offset into the flash space to start searching uImage magic "OKLI".
# $(5), size of search range starting at $(4).  With 0 as the value, uImage
#	header is expected to be at precisely $(4)
define Image/BuildLoaderAlone
	-rm -rf $(KDIR)/lzma-loader
	$(LOADER_MAKE) LOADER=loader-$(1).$(2) KERNEL_CMDLINE="$(3)" \
		LZMA_TEXT_START=0x80a00000 LOADADDR=0x80060000 \
		BOARD="$(1)" FLASH_OFFS=$(4) FLASH_MAX=$(5) \
		compile loader.$(2)
endef

define Build/Clean
	$(LOADER_MAKE) clean
endef

alfa_ap120c_mtdlayout=mtdparts=spi0.0:256k(u-boot)ro,64k(u-boot-env)ro,13312k(rootfs),1536k(kernel),1152k(unknown)ro,64k(art)ro;spi0.1:-(unknown)
alfa_ap96_mtdlayout=mtdparts=spi0.0:256k(u-boot)ro,256k(u-boot-env)ro,13312k(rootfs),2048k(kernel),512k(caldata)ro,15360k@0x80000(firmware)
alfa_mtdlayout_8M=mtdparts=spi0.0:256k(u-boot)ro,64k(u-boot-env)ro,6144k(rootfs),1600k(kernel),64k(nvram),64k(art)ro,7744k@0x50000(firmware)
alfa_mtdlayout_16M=mtdparts=spi0.0:256k(u-boot)ro,64k(u-boot-env)ro,15936k(firmware),64k(nvram),64k(art)ro
all0258n_mtdlayout=mtdparts=spi0.0:256k(u-boot)ro,64k(u-boot-env),6272k(firmware),1536k(failsafe),64k(art)ro
all0315n_mtdlayout=mtdparts=spi0.0:256k(u-boot)ro,256k(u-boot-env),13568k(firmware),2048k(failsafe),256k(art)ro
ap96_mtdlayout=mtdparts=spi0.0:192k(u-boot)ro,64k(u-boot-env)ro,6144k(rootfs),1728k(kernel),64k(art)ro,7872k@0x40000(firmware)
ap121_mtdlayout_8M=mtdparts=spi0.0:256k(u-boot)ro,64k(u-boot-env)ro,6144k(rootfs),1600k(kernel),64k(nvram),64k(art)ro,7744k@0x50000(firmware)
ap121_mtdlayout_16M=mtdparts=spi0.0:256k(u-boot)ro,64k(u-boot-env)ro,10944k(rootfs),4992k(kernel),64k(nvram),64k(art)ro,15936k@0x50000(firmware)
ap132_mtdlayout=mtdparts=spi0.0:256k(u-boot)ro,64k(u-boot-env)ro,1408k(kernel),6400k(rootfs),64k(art)ro,7808k@0x50000(firmware)
ap135_mtdlayout=mtdparts=spi0.0:256k(u-boot)ro,64k(u-boot-env)ro,14528k(rootfs),1472k(kernel),64k(art)ro,16000k@0x50000(firmware)
ap136_mtdlayout=mtdparts=spi0.0:256k(u-boot)ro,64k(u-boot-env)ro,6336k(rootfs),1408k(kernel),64k(mib0),64k(art)ro,7744k@0x50000(firmware)
ap143_mtdlayout_8M=mtdparts=spi0.0:256k(u-boot)ro,64k(u-boot-env)ro,6336k(rootfs),1472k(kernel),64k(art)ro,7744k@0x50000(firmware)
ap143_mtdlayout_16M=mtdparts=spi0.0:256k(u-boot)ro,64k(u-boot-env)ro,14528k(rootfs),1472k(kernel),64k(art)ro,16000k@0x50000(firmware)
ap147_mtdlayout=mtdparts=spi0.0:256k(u-boot)ro,64k(u-boot-env)ro,14528k(rootfs),1472k(kernel),64k(art)ro,16000k@0x50000(firmware)
ap152_mtdlayout_16M=mtdparts=spi0.0:256k(u-boot)ro,64k(u-boot-env)ro,14528k(rootfs),1472k(kernel),64k(art)ro,16000k@0x50000(firmware)
bxu2000n2_mtdlayout=mtdparts=spi0.0:256k(u-boot)ro,64k(u-boot-env)ro,1408k(kernel),8448k(rootfs),6016k(user),64k(cfg),64k(oem),64k(art)ro
cameo_ap81_mtdlayout=mtdparts=spi0.0:128k(u-boot)ro,64k(config)ro,3840k(firmware),64k(art)ro
cameo_ap91_mtdlayout=mtdparts=spi0.0:192k(u-boot)ro,64k(nvram)ro,3712k(firmware),64k(mac)ro,64k(art)ro
cameo_ap99_mtdlayout=mtdparts=spi0.0:192k(u-boot)ro,64k(nvram)ro,3520k(firmware),64k(mac)ro,192k(lp)ro,64k(art)ro
cameo_ap121_mtdlayout=mtdparts=spi0.0:64k(u-boot)ro,64k(art)ro,64k(mac)ro,64k(nvram)ro,192k(language)ro,3648k(firmware)
cameo_ap121_mtdlayout_8M=mtdparts=spi0.0:64k(u-boot)ro,64k(art)ro,64k(mac)ro,64k(nvram)ro,256k(language)ro,7680k@0x80000(firmware)
cameo_ap123_mtdlayout_4M=mtdparts=spi0.0:64k(u-boot)ro,64k(nvram)ro,3712k(firmware),192k(lang)ro,64k(art)ro
cameo_db120_mtdlayout=mtdparts=spi0.0:64k(uboot)ro,64k(nvram)ro,15936k(firmware),192k(lang)ro,64k(mac)ro,64k(art)ro
cameo_db120_mtdlayout_8M=mtdparts=spi0.0:64k(uboot)ro,64k(nvram)ro,7872k(firmware),128k(lang)ro,64k(art)ro
cap4200ag_mtdlayout=mtdparts=spi0.0:256k(u-boot)ro,64k(u-boot-env),320k(custom)ro,1536k(kernel),12096k(rootfs),2048k(failsafe),64k(art)ro,13632k@0xa0000(firmware)
eap300v2_mtdlayout=mtdparts=spi0.0:256k(u-boot)ro,64k(u-boot-env),320k(custom),13632k(firmware),2048k(failsafe),64k(art)ro
db120_mtdlayout=mtdparts=spi0.0:256k(u-boot)ro,64k(u-boot-env)ro,6336k(rootfs),1408k(kernel),64k(nvram),64k(art)ro,7744k@0x50000(firmware)
dgl_5500_mtdlayout=mtdparts=spi0.0:192k(u-boot)ro,64k(nvram)ro,15296k(firmware),192k(lang)ro,512k(my-dlink)ro,64k(mac)ro,64k(art)ro
dlan_hotspot_mtdlayout=mtdparts=spi0.0:128k(u-boot)ro,64k(Config1)ro,64k(Config2)ro,7872k@0x40000(firmware),64k(art)ro
dlan_pro_500_wp_mtdlayout=mtdparts=spi0.0:256k(u-boot)ro,64k(u-boot-env)ro,64k(Config1)ro,64k(Config2)ro,7680k@0x70000(firmware),64k(art)ro
dlan_pro_1200_ac_mtdlayout=mtdparts=spi0.0:256k(u-boot)ro,64k(u-boot-env)ro,64k(Config1)ro,64k(Config2)ro,15872k@0x70000(firmware),64k(art)ro
cameo_ap94_mtdlayout=mtdparts=spi0.0:256k(uboot)ro,64k(config)ro,6208k(firmware),64k(caldata)ro,1600k(unknown)ro,64k@0x7f0000(caldata_copy)
cameo_ap94_mtdlayout_fat=mtdparts=spi0.0:256k(uboot)ro,64k(config)ro,7808k(firmware),64k(caldata)ro,64k@0x660000(caldata_orig),6208k@0x50000(firmware_orig)
esr900_mtdlayout=mtdparts=spi0.0:192k(u-boot)ro,64k(u-boot-env)ro,1408k(kernel),13248k(rootfs),1024k(manufacture)ro,64k(backup)ro,320k(storage)ro,64k(caldata)ro,14656k@0x40000(firmware)
esr1750_mtdlayout=mtdparts=spi0.0:192k(u-boot)ro,64k(u-boot-env)ro,1408k(kernel),13248k(rootfs),1024k(manufacture)ro,64k(backup)ro,320k(storage)ro,64k(caldata)ro,14656k@0x40000(firmware)
epg5000_mtdlayout=mtdparts=spi0.0:192k(u-boot)ro,64k(u-boot-env)ro,1408k(kernel),13248k(rootfs),1024k(manufacture)ro,64k(backup)ro,320k(storage)ro,64k(caldata)ro,14656k@0x40000(firmware)
f9k1115v2_mtdlayout=mtdparts=spi0.0:256k(u-boot)ro,64k(u-boot-env),14464k(rootfs),1408k(kernel),64k(nvram)ro,64k(envram)ro,64k(art)ro,15872k@0x50000(firmware)
dlrtdev_mtdlayout=mtdparts=spi0.0:256k(uboot)ro,64k(config)ro,6208k(firmware),64k(caldata)ro,640k(certs),960k(unknown)ro,64k@0x7f0000(caldata_copy)
dlrtdev_mtdlayout_fat=mtdparts=spi0.0:256k(uboot)ro,64k(config)ro,7168k(firmware),640k(certs),64k(caldata)ro,64k@0x660000(caldata_orig),6208k@0x50000(firmware_orig)
planex_mtdlayout=mtdparts=spi0.0:256k(u-boot)ro,64k(u-boot-env)ro,7744k(firmware),128k(art)ro
whrhpg300n_mtdlayout=mtdparts=spi0.0:248k(u-boot)ro,8k(u-boot-env)ro,3712k(firmware),64k(art)ro
wndap360_mtdlayout=mtdparts=spi0.0:256k(u-boot)ro,64k(u-boot-env)ro,7744k(firmware),64k(nvram)ro,64k(art)ro
wnr2200_mtdlayout=mtdparts=spi0.0:256k(u-boot)ro,64k(u-boot-env)ro,7808k(firmware),64k(art)ro
wnr2000_mtdlayout=mtdparts=spi0.0:256k(u-boot)ro,64k(u-boot-env)ro,3712k(firmware),64k(art)ro
wnr2000v3_mtdlayout=mtdparts=spi0.0:256k(u-boot)ro,64k(u-boot-env)ro,3712k(firmware),64k(art)ro
wnr2000v4_mtdlayout=mtdparts=spi0.0:192k(u-boot)ro,64k(u-boot-env)ro,3776k(firmware),64k(art)ro
r6100_mtdlayout=mtdparts=ar934x-nfc:128k(u-boot)ro,256k(caldata)ro,256k(caldata-backup),512k(config),512k(pot),2048k(kernel),122240k(ubi),25600k@0x1a0000(firmware),2048k(language),3072k(traffic_meter)
tew823dru_mtdlayout=mtdparts=spi0.0:192k(u-boot)ro,64k(nvram)ro,15296k(firmware),192k(lang)ro,512k(my-dlink)ro,64k(mac)ro,64k(art)ro
wndr4300_mtdlayout=mtdparts=ar934x-nfc:256k(u-boot)ro,256k(u-boot-env)ro,256k(caldata)ro,512k(pot),2048k(language),512k(config),3072k(traffic_meter),2048k(kernel),23552k(ubi),25600k@0x6c0000(firmware),256k(caldata_backup),-(reserved)
wndr4500v3_mtdlayout=mtdparts=spi0.0:256k(u-boot)ro,64k(u-boot-env)ro,64k(caldata_backup),64k(config),64k(traffic_meter),64k(pot),1408k(reserved),64k(caldata);spi0.1:2048k(kernel),23552k(ubi),25600k@0x0(firmware),2048k(language),128k(mtdoops),-(reserved) nofwsplit

zcn1523h_mtdlayout=mtdparts=spi0.0:256k(u-boot)ro,64k(u-boot-env)ro,6208k(rootfs),1472k(kernel),64k(configure)ro,64k(mfg)ro,64k(art)ro,7680k@0x50000(firmware)
mynet_rext_mtdlayout=mtdparts=spi0.0:256k(u-boot)ro,7808k(firmware),64k(nvram)ro,64k(ART)ro
zyx_nbg6716_mtdlayout=mtdparts=spi0.0:256k(u-boot)ro,64k(env)ro,64k(RFdata)ro,-(nbu);ar934x-nfc:2048k(zyxel_rfsd),2048k(romd),1024k(header),2048k(kernel),-(ubi)

define Image/BuildKernel
	cp $(KDIR)/vmlinux.elf $(VMLINUX).elf
	cp $(KDIR)/vmlinux $(VMLINUX).bin
	dd if=$(KDIR)/vmlinux.bin.lzma of=$(VMLINUX).lzma bs=65536 conv=sync
	$(call MkuImage,lzma,,$(KDIR)/vmlinux.bin.lzma,$(UIMAGE)-lzma.bin)
	cp $(KDIR)/loader-generic.elf $(VMLINUX)-lzma.elf
	-mkdir -p $(KDIR_TMP)
endef

define Image/BuildKernel/Initramfs
	cp $(KDIR)/vmlinux-initramfs.elf $(VMLINUX)-initramfs.elf
	cp $(KDIR)/vmlinux-initramfs $(VMLINUX)-initramfs.bin
	dd if=$(KDIR)/vmlinux-initramfs.bin.lzma of=$(VMLINUX)-initramfs.lzma bs=65536 conv=sync
	$(call MkuImage,lzma,,$(KDIR)/vmlinux-initramfs.bin.lzma,$(UIMAGE)-initramfs-lzma.bin)
	cp $(KDIR)/loader-generic-initramfs.elf $(VMLINUX)-initramfs-lzma.elf
	$(call Image/Build/Initramfs)
endef

Image/Build/WRT400N/buildkernel=$(call MkuImageLzma,$(2),$(3))

define Image/Build/WRT400N
	$(call Sysupgrade/KRuImage,$(1),$(2),1310720,6488064)
	if [ -e "$(call sysupname,$(1),$(2))" ]; then \
		wrt400n $(KDIR_TMP)/vmlinux-$(2).uImage $(KDIR)/root.$(1) $(call factoryname,$(1),$(2)); \
	fi
endef


define Image/Build/CameoAP94/buildkernel
	$(call MkuImageLzma,$(2),$(3) $(4))
	$(call MkuImageLzma,$(2)-fat,$(3) $(5))
endef

define Image/Build/CameoAP94
	$(eval fwsize=$(call mtdpartsize,firmware,$(4)))
	$(eval fwsize_fat=$(call mtdpartsize,firmware,$(5)))
	$(call Sysupgrade/KRuImage,$(1),$(2),0,$$(($(fwsize)-4*64*1024)),64)
	if [ -e "$(call sysupname,$(1),$(2))" ]; then \
		( \
			dd if=$(call sysupname,$(1),$(2)); \
			echo -n "$(6)"; \
		) > $(call imgname,$(1),$(2))-backup-loader.bin; \
		if [ `stat -c%s $(call sysupname,$(1),$(2))` -gt 4194304 ]; then \
			echo "Warning: $(call sysupname,$(1),$(2)) is too big" >&2; \
		else \
			( \
				dd if=$(call sysupname,$(1),$(2)) bs=4096k conv=sync; \
				echo -n "$(7)"; \
			) > $(call factoryname,$(1),$(2)); \
		fi; \
	fi
	$(call CatFiles,$(KDIR_TMP)/vmlinux-$(2)-fat.uImage,0,$(KDIR)/root.$(1),$$(($(fwsize_fat)-4*64*1024)),$(KDIR_TMP)/$(2)-fat.bin,64)
	if [ -e "$(KDIR_TMP)/$(2)-fat.bin" ]; then \
		echo -n "" > $(KDIR_TMP)/$(2)-fat.dummy; \
		sh $(TOPDIR)/scripts/combined-image.sh \
			"$(KDIR_TMP)/$(2)-fat.bin" \
			"$(KDIR_TMP)/$(2)-fat.dummy" \
			$(call sysupname,$(1),$(2)-fat); \
	fi
endef

define Image/Build/WZRHP
	$(call Sysupgrade/KRuImage,$(1),$(2),0,$$(($(3)-4*$(4)*1024)),$(4))
	if [ -e "$(call sysupname,$(1),$(2))" ]; then \
		( \
			echo -n -e "# Airstation Public Fmt1\x00\x00\x00\x00\x00\x00\x00\x00"; \
			dd if=$(call sysupname,$(1),$(2)); \
		) > $(call imgname,$(1),$(2))-tftp.bin; \
		buffalo-enc -p $(5) -v 1.99 \
			-i $(call sysupname,$(1),$(2)) \
			-o $(KDIR_TMP)/$(2).enc; \
		buffalo-tag -b $(5) -p $(5) -a ath -v 1.99 -m 1.01 -l mlang8 \
			-w 3 -c 0x80041000 -d 0x801e8000 -f 1 -r M_ \
			-i $(KDIR_TMP)/$(2).enc \
			-o $(call factoryname,$(1),$(2)); \
	fi
endef

Image/Build/WZRHP64K/buildkernel=$(call MkuImageLzma,$(2),$(3))
Image/Build/WZRHP64K/initramfs=$(call MkuImageLzma/initramfs,$(2),$(3) $(4))
Image/Build/WZRHP64K=$(call Image/Build/WZRHP,$(1),$(2),33095680,64,$(4))

Image/Build/WZRHP128K/buildkernel=$(call MkuImageLzma,$(2),$(3))
Image/Build/WZRHP128K/initramfs=$(call MkuImageLzma/initramfs,$(2),$(3) $(4))
Image/Build/WZRHP128K=$(call Image/Build/WZRHP,$(1),$(2),33030144,128,$(4))


Image/Build/WHRHPG300N/buildkernel=$(call MkuImageLzma,$(2),$(3) $(4))
Image/Build/WHRHPG300N/initramfs=$(call MkuImageLzma/initramfs,$(2),$(3) $(4))

define Image/Build/WHRHPG300N
	$(eval fwsize=$(call mtdpartsize,firmware,$(4)))
	$(call Sysupgrade/KRuImage,$(1),$(2),0,$$(($(fwsize)-4*64*1024)),64)
	if [ -e "$(call sysupname,$(1),$(2))" ]; then \
		( \
			echo -n -e "# Airstation Public Fmt1\x00\x00\x00\x00\x00\x00\x00\x00"; \
			dd if=$(call sysupname,$(1),$(2)); \
		) > $(call imgname,$(1),$(2))-tftp.bin; \
		buffalo-enc -p $(5) -v 1.99 \
			-i $(call sysupname,$(1),$(2)) \
			-o $(KDIR_TMP)/$(2).enc; \
		buffalo-tag -b $(5) -p $(5) -a ath -v 1.99 -m 1.01 -l mlang8 \
			-w 3 -c 0x80041000 -d 0x801e8000 -f 1 -r M_ \
			-i $(KDIR_TMP)/$(2).enc \
			-o $(call factoryname,$(1),$(2)); \
	fi
endef


define Image/Build/Cameo
	$(eval fwsize=$(call mtdpartsize,firmware,$(4)))
	$(call Sysupgrade/KRuImage,$(1),$(2),0,$$(($(fwsize)-4*64*1024)),64)
	if [ -e "$(call sysupname,$(1),$(2))" ]; then \
		factory_size=$$(($(fwsize) - $(6))); \
		( \
			dd if=$(call sysupname,$(1),$(2)) bs=$${factory_size} conv=sync; \
			echo -n $(5); \
		) > $(call factoryname,$(1),$(2)); \
	fi
endef

Image/Build/CameoAP81/buildkernel=$(call MkuImageLzma,$(2),$(3) $(cameo_ap81_mtdlayout))
Image/Build/CameoAP81=$(call Image/Build/Cameo,$(1),$(2),$(3),$(cameo_ap81_mtdlayout),$(4),65536)
Image/Build/CameoAP81/initramfs=$(call MkuImageLzma/initramfs,$(2),$(3) $(cameo_ap81_mtdlayout))

Image/Build/CameoAP91/buildkernel=$(call MkuImageLzma,$(2),$(3) $(cameo_ap91_mtdlayout))
Image/Build/CameoAP91=$(call Image/Build/Cameo,$(1),$(2),$(3),$(cameo_ap91_mtdlayout),$(4),65536)
Image/Build/CameoAP91/initramfs=$(call MkuImageLzma/initramfs,$(2),$(3) $(cameo_ap91_mtdlayout))

Image/Build/CameoAP99/buildkernel=$(call MkuImageLzma,$(2),$(3) $(cameo_ap99_mtdlayout))
Image/Build/CameoAP99=$(call Image/Build/Cameo,$(1),$(2),$(3),$(cameo_ap99_mtdlayout),$(4),65536)
Image/Build/CameoAP99/initramfs=$(call MkuImageLzma/initramfs,$(2),$(3) $(cameo_ap99_mtdlayout))

Image/Build/CameoAP123_4M/buildkernel=$(call MkuImageLzma,$(2),$(3) $(cameo_ap123_mtdlayout_4M))
Image/Build/CameoAP123_4M=$(call Image/Build/Cameo,$(1),$(2),$(3),$(cameo_ap123_mtdlayout_4M),$(4),26)
Image/Build/CameoAP123_4M/initramfs=$(call MkuImageLzma/initramfs,$(2),$(3) $(cameo_ap123_mtdlayout_4M))

Image/Build/CameoAP135/buildkernel=$(call MkuImageLzma,$(2),$(3) $(4))
Image/Build/CameoAP135=$(call Image/Build/Cameo,$(1),$(2),$(3),$(4),$(5),26)
Image/Build/CameoAP135/initramfs=$(call MkuImageLzma/initramfs,$(2),$(3) $(4))

Image/Build/CameoDB120/buildkernel=$(call MkuImageLzma,$(2),$(3) $(cameo_db120_mtdlayout))
Image/Build/CameoDB120=$(call Image/Build/Cameo,$(1),$(2),$(3),$(cameo_db120_mtdlayout),$(4),26)
Image/Build/CameoDB120/initramfs=$(call MkuImageLzma/initramfs,$(2),$(3) $(cameo_db120_mtdlayout))

Image/Build/CameoDB120_8M/buildkernel=$(call MkuImageLzma,$(2),$(3) $(cameo_db120_mtdlayout_8M))
Image/Build/CameoDB120_8M=$(call Image/Build/Cameo,$(1),$(2),$(3),$(cameo_db120_mtdlayout_8M),$(4),26)
Image/Build/CameoDB120_8M/initramfs=$(call MkuImageLzma/initramfs,$(2),$(3) $(cameo_db120_mtdlayout_8M))

define Image/Build/CameoHornet
	$(eval fwsize=$(call mtdpartsize,firmware,$(4)))
	$(call Sysupgrade/KRuImage,$(1),$(2),0,$$(($(fwsize)-4*64*1024)),64)
	if [ -e "$(call sysupname,$(1),$(2))" ]; then \
		for r in $(7); do \
			[ -n "$$r" ] && dashr="-$$r" || dashr=; \
			[ -z "$$r" ] && r="DEF"; \
			mkcameofw -M HORNET -R "$$r" -S $(5) -V $(6) -c \
				-K $(8) -I $(fwsize) \
				-k "$(call sysupname,$(1),$(2))" \
				-o $(call imgname,$(1),$(2))-factory$$dashr.bin; \
			true; \
		done; \
	fi
endef

Image/Build/CameoAP121/buildkernel=$(call MkuImageLzma,$(2),$(3) $(cameo_ap121_mtdlayout))
Image/Build/CameoAP121=$(call Image/Build/CameoHornet,$(1),$(2),$(3),$(cameo_ap121_mtdlayout),$(4),$(5),$(6),0xe0000)
Image/Build/CameoAP121/initramfs=$(call MkuImageLzma/initramfs,$(2),$(3) $(cameo_ap121_mtdlayout))

Image/Build/CameoAP121_8M/buildkernel=$(call MkuImageLzma,$(2),$(3) $(cameo_ap121_mtdlayout_8M))
Image/Build/CameoAP121_8M=$(call Image/Build/CameoHornet,$(1),$(2),$(3),$(cameo_ap121_mtdlayout_8M),$(4),$(5),$(6),0x100000)
Image/Build/CameoAP121_8M/initramfs=$(call MkuImageLzma/initramfs,$(2),$(3) $(cameo_ap121_mtdlayout_8M))

define Image/Build/dLAN
	$(eval fwsize=$(call mtdpartsize,firmware,$(4)))
	$(eval rootsize=$(call mtdpartsize,rootfs,$(4)))
	$(eval kernsize=$(call mtdpartsize,kernel,$(4)))
	$(call Sysupgrade/$(5),$(1),$(2),$(if $(6),$(6),$(kernsize)),$(if $(rootsize),$(rootsize),$(fwsize)))
endef

Image/Build/dLANLzma/buildkernel=$(call MkuImageLzma,$(2),$(3) $(4))
Image/Build/dLANLzma=$(call Image/Build/dLAN,$(1),$(2),$(3),$(4),$(5),$(6),$(7))
Image/Build/dLANLzma/initramfs=$(call MkuImageLzma/initramfs,$(2),$(3) $(4))

define Image/Build/Ath
	$(eval fwsize=$(call mtdpartsize,firmware,$(4)))
	$(eval rootsize=$(call mtdpartsize,rootfs,$(4)))
	$(eval kernsize=$(call mtdpartsize,kernel,$(4)))
	$(call Sysupgrade/$(5),$(1),$(2),$(if $(6),$(6),$(kernsize)),$(if $(rootsize),$(rootsize),$(fwsize)))
endef

Image/Build/AthGzip/buildkernel=$(call MkuImageGzip,$(2),$(3) $(4))
Image/Build/AthGzip=$(call Image/Build/Ath,$(1),$(2),$(3),$(4),$(5),$(6),$(7))
Image/Build/AthGzip/initramfs=$(call MkuImageGzip/initramfs,$(2),$(3) $(4))

Image/Build/AthLzma/buildkernel=$(call MkuImageLzma,$(2),$(3) $(4))
Image/Build/AthLzma=$(call Image/Build/Ath,$(1),$(2),$(3),$(4),$(5),$(6),$(7))
Image/Build/AthLzma/initramfs=$(call MkuImageLzma/initramfs,$(2),$(3) $(4))


Image/Build/Belkin/buildkernel=$(call MkuImageLzma,$(2),$(3) $(4))
Image/Build/Belkin/initramfs=$(call MkuImageLzma/initramfs,$(2),$(3) $(4))

define Image/Build/Belkin
	$(eval fwsize=$(call mtdpartsize,firmware,$(4)))
	$(eval kernsize=$(call mtdpartsize,kernel,$(4)))
	$(eval rootsize=$(call mtdpartsize,rootfs,$(4)))
	$(call Sysupgrade/RKuImage,$(1),$(2),$(kernsize),$(rootsize))
	if [ -e "$(call sysupname,$(1),$(2))" ]; then \
		edimax_fw_header -m $(5) -v "$(shell echo -n $(VERSION_DIST)$(REVISION) | cut -c -13)" \
			-n "uImage" \
			-i $(KDIR_TMP)/vmlinux-$(2).uImage \
			-o $(KDIR_TMP)/$(2)-uImage; \
		edimax_fw_header -m $(5) -v "$(shell echo -n $(VERSION_DIST)$(REVISION) | cut -c -13)" \
			-n "rootfs" \
			-i $(KDIR)/root.$(1) \
			-o $(KDIR_TMP)/$(2)-rootfs; \
		( \
			dd if=$(KDIR_TMP)/$(2)-rootfs; \
			dd if=$(KDIR_TMP)/$(2)-uImage; \
		) > "$(call factoryname,$(1),$(2))"; \
	fi
endef

define Image/Build/EnGenius
	$(eval fwsize=$(call mtdpartsize,firmware,$(4)))
	$(eval rootsize=$(call mtdpartsize,rootfs,$(4)))
	$(eval kernsize=$(call mtdpartsize,kernel,$(4)))
	$(call Sysupgrade/$(5),$(1),$(2),$(if $(6),$(6),$(kernsize)),$(if $(rootsize),$(rootsize),$(fwsize)))
	if [ -e "$(call sysupname,$(1),$(2))" ]; then \
		mksenaofw -e $(call sysupname,$(1),$(2)) \
			-o $(call imgname,$(1),$(2))-factory.dlf \
			-r 0x101 -p $(7) -t 2; \
	fi
endef

Image/Build/EnGenius/buildkernel=$(call MkuImageLzma,$(2),$(3) $(4))
Image/Build/EnGenius/initramfs=$(call MkuImageLzma/initramfs,$(2),$(3) $(4))


Image/Build/PB4X/buildkernel=$(call PatchKernelLzma,$(2),$(3))

define Image/Build/PB4X
	dd if=$(KDIR_TMP)/vmlinux-$(2).bin.lzma \
	   of=$(call imgname,kernel,$(2)).bin bs=64k conv=sync
	dd if=$(KDIR)/root.$(1) \
	   of=$(call imgname,$(1),$(2)-rootfs).bin bs=128k conv=sync
	-sh $(TOPDIR)/scripts/combined-image.sh \
		"$(call imgname,kernel,$(2)).bin" \
		"$(call imgname,$(1),$(2)-rootfs).bin" \
		$(call sysupname,$(1),$(2))
endef


Image/Build/MyLoader/buildkernel=$(call PatchKernelLzma,$(2),$(3))
Image/Build/MyLoader/initramfs=$(call PatchKernel/initramfs,$(2),$(3))

define Image/Build/MyLoader
	$(eval fwsize=$(shell echo $$(($(4)-0x30000-4*64*1024))))
	$(eval fwimage=$(KDIR_TMP)/$(2)-$(5)-firmware.bin)
	$(call CatFiles,$(KDIR_TMP)/vmlinux-$(2).bin.lzma,65536,$(KDIR)/root.$(1),$(fwsize),$(fwimage))
	if [ -e "$(fwimage)" ]; then \
		$(STAGING_DIR_HOST)/bin/mkmylofw -B $(2) -s $(4) -v \
			-p0x00030000:0:al:0x80060000:firmware:$(fwimage) \
			$(call imgname,$(1),$(2))-$(5)-factory.img; \
		echo -n "" > $(KDIR_TMP)/empty.bin; \
		sh $(TOPDIR)/scripts/combined-image.sh \
			$(fwimage) $(KDIR_TMP)/empty.bin \
			$(call imgname,$(1),$(2))-$(5)-sysupgrade.bin; \
	fi
endef

Image/Build/Planex/initramfs=$(call MkuImageGzip/initramfs,$(2),$(3) $(planex_mtdlayout))
Image/Build/Planex/loader=$(call Image/BuildLoaderAlone,$(1),gz,$(2) $(planex_mtdlayout),0x52000,0)

define Image/Build/Planex/buildkernel
	[ -e "$(KDIR)/loader-$(2).gz" ]
	$(call MkuImageOKLI,$(2))
	( \
		dd if=$(KDIR)/loader-$(2).gz bs=8128 count=1 conv=sync; \
		dd if=$(KDIR_TMP)/vmlinux-$(2).okli; \
	) > $(KDIR_TMP)/kernel-$(2).bin
	$(call MkuImage,gzip,,$(KDIR_TMP)/kernel-$(2).bin,$(KDIR_TMP)/vmlinux-$(2).uImage)
endef

define Image/Build/Planex
	$(eval fwsize=$(call mtdpartsize,firmware,$(planex_mtdlayout)))
	$(call Sysupgrade/KRuImage,$(1),$(2),0,$$(($(fwsize)-4*64*1024)),64)
	if [ -e "$(call sysupname,$(1),$(2))" ]; then \
		$(STAGING_DIR_HOST)/bin/mkplanexfw \
			-B $(2) \
			-v 2.00.00 \
			-i $(call sysupname,$(1),$(2)) \
			-o $(call factoryname,$(1),$(2)); \
	fi
endef


Image/Build/ALFA/buildkernel=$(call MkuImageLzma,$(2),$(3) $(4))
Image/Build/ALFA/initramfs=$(call MkuImageLzma/initramfs,$(2),$(3) $(4))

define Image/Build/ALFA
	$(call Sysupgrade/RKuImage,$(1),$(2),$(5),$(6))
	if [ -e "$(call sysupname,$(1),$(2))" ]; then \
		rm -rf $(KDIR)/$(1); \
		mkdir -p $(KDIR)/$(1); \
		cd $(KDIR)/$(1); \
		cp $(KDIR_TMP)/vmlinux-$(2).uImage $(KDIR)/$(1)/$(7); \
		cp $(KDIR)/root.$(1) $(KDIR)/$(1)/$(8); \
		$(TAR) c \
			$(if $(SOURCE_DATE_EPOCH),--mtime="@$(SOURCE_DATE_EPOCH)") \
			-C $(KDIR)/$(1) $(7) $(8) \
				| gzip -9nc > $(call factoryname,$(1),$(2)); \
		( \
			echo WRM7222C | dd bs=32 count=1 conv=sync; \
			echo -ne '\xfe'; \
		) >> $(call factoryname,$(1),$(2)); \
	fi
endef


Image/Build/Senao/buildkernel=$(call MkuImageLzma,$(2),$(3) $(4))
Image/Build/Senao/initramfs=$(call MkuImageLzma/initramfs,$(2),$(3) $(4))

define Image/Build/Senao
	mkdir -p $(KDIR_TMP)/$(2)/
	touch $(KDIR_TMP)/$(2)/FWINFO-OpenWrt-$(REVISION)-$(2)
	-$(CP) ./$(2)/* $(KDIR_TMP)/$(2)/
	dd if=$(KDIR_TMP)/vmlinux-$(2).uImage \
		of=$(KDIR_TMP)/$(2)/openwrt-senao-$(2)-uImage-lzma.bin bs=64k conv=sync
	dd if=$(KDIR)/root.$(1) \
		of=$(KDIR_TMP)/$(2)/openwrt-senao-$(2)-root.$(1) bs=64k conv=sync
	( \
		cd $(KDIR_TMP)/$(2)/;  \
		$(TAR) -c \
			$(if $(SOURCE_DATE_EPOCH),--mtime="@$(SOURCE_DATE_EPOCH)") \
			* | gzip -9nc > $(call factoryname,$(1),$(2)) \
	)
	-rm -rf $(KDIR_TMP)/$(2)/
	-sh $(TOPDIR)/scripts/combined-image.sh \
		$(KDIR_TMP)/vmlinux-$(2).uImage \
		$(KDIR)/root.$(1) \
		$(call sysupname,$(1),$(2))
endef

define Image/Build/CyberTAN
	echo -n '' > $(KDIR_TMP)/empty.bin
	-$(STAGING_DIR_HOST)/bin/trx -o $(KDIR)/image.tmp \
		-f $(KDIR_TMP)/vmlinux-$(2).uImage -F $(KDIR_TMP)/empty.bin \
		-x 32 -a 0x10000 -x -32 -f $(KDIR)/root.$(1) && \
	$(STAGING_DIR_HOST)/bin/addpattern -B $(2) -v v$(5) \
		-i $(KDIR)/image.tmp \
		-o $(call sysupname,$(1),$(2))
	-$(STAGING_DIR_HOST)/bin/trx -o $(KDIR)/image.tmp -f $(KDIR_TMP)/vmlinux-$(2).uImage \
		-x 32 -a 0x10000 -x -32 -f $(KDIR)/root.$(1) && \
	$(STAGING_DIR_HOST)/bin/addpattern -B $(2) -v v$(5) -g \
		-i $(KDIR)/image.tmp \
		-o $(call factoryname,$(1),$(2))
	-rm $(KDIR)/image.tmp
endef

Image/Build/CyberTANGZIP/loader=$(call Image/BuildLoader,$(1),gz,$(2),0x80060000)
Image/Build/CyberTANGZIP/buildkernel=$(call MkuImage,gzip,,$(KDIR)/loader-$(2).gz,$(KDIR_TMP)/vmlinux-$(2).uImage)
Image/Build/CyberTANGZIP=$(call Image/Build/CyberTAN,$(1),$(2),$(3),$(4),$(5))

Image/Build/CyberTANLZMA/buildkernel=$(call MkuImageLzma,$(2),$(3) $(4))
Image/Build/CyberTANLZMA=$(call Image/Build/CyberTAN,$(1),$(2),$(3),$(4),$(5))


Image/Build/Netgear/initramfs=$(call MkuImageLzma/initramfs,$(2),$(3) $(4),,-M $(5))

define Image/Build/Netgear/buildkernel
	$(call MkuImageLzma,$(2),$(3) $(4),-d20,,-M $(5))
	-rm -rf $(KDIR_TMP)/$(2)
	mkdir -p $(KDIR_TMP)/$(2)/image
	cat $(KDIR_TMP)/vmlinux-$(2).uImage > $(KDIR_TMP)/$(2)/image/uImage
	$(STAGING_DIR_HOST)/bin/mksquashfs-lzma \
		$(KDIR_TMP)/$(2) $(KDIR_TMP)/vmlinux-$(2).uImage.squashfs.tmp1 \
		-noappend -root-owned -be -b 65536 \
		$(if $(SOURCE_DATE_EPOCH),-fixed-time $(SOURCE_DATE_EPOCH))
	( \
		cat $(KDIR_TMP)/vmlinux-$(2).uImage.squashfs.tmp1; \
		dd if=/dev/zero bs=1k count=1 \
	) > $(KDIR_TMP)/vmlinux-$(2).uImage.squashfs.tmp2
	mkimage -A mips -O linux -T filesystem -C none -M $(5) \
		-a 0xbf070000 -e 0xbf070000 \
		-n 'MIPS $(VERSION_DIST) Linux-$(LINUX_VERSION)' \
		-d $(KDIR_TMP)/vmlinux-$(2).uImage.squashfs.tmp2 \
		$(KDIR_TMP)/vmlinux-$(2).uImage.squashfs
endef

define Image/Build/Netgear
	$(eval fwsize=$(call mtdpartsize,firmware,$(4)))
	$(call CatFiles,$(KDIR_TMP)/vmlinux-$(2).uImage.squashfs,0,$(KDIR)/root.$(1),$(fwsize),$(call sysupname,$(1),$(2)),64)
	if [ -e $(call sysupname,$(1),$(2)) ]; then \
		for r in $(7) ; do \
			[ -n "$$r" ] && dashr="-$$r" || dashr= ; \
			$(STAGING_DIR_HOST)/bin/mkdniimg \
				-B $(6) -v $(VERSION_DIST).$(REVISION) -r "$$r" $(8) \
				-i $(call sysupname,$(1),$(2)) \
				-o $(call imgname,$(1),$(2))-factory$$dashr.img; \
		done; \
	fi
	if [ "$2" = "wnr2000" ]; then \
		dd if=$(KDIR)/root.$(1) \
			of=$(call imgname,$(1),$(2)-rootfs).bin bs=128k conv=sync; \
	fi
endef


Image/Build/NetgearLzma/initramfs=$(call MkuImageLzma/initramfs,$(2),$(3) $(4),,-M $(5))
Image/Build/NetgearLzma/buildkernel=$(call MkuImageLzma,$(2),$(3) $(4),-d20,,-M $(5))

define Image/Build/NetgearLzma
	$(eval fwsize=$(call mtdpartsize,firmware,$(4)))
	$(call CatFiles,$(KDIR_TMP)/vmlinux-$(2).uImage,0,$(KDIR)/root.$(1),$(fwsize),$(call sysupname,$(1),$(2)),64)
endef


Image/Build/NetgearNAND/initramfs=$(call MkuImageLzma/initramfs,$(2),$(3) $(4),,-M $(5))

# $(1): (empty)
# $(2): Board name (small caps)
# $(3): Kernel board specific cmdline
# $(4): Kernel mtdparts definition
# $(5): U-Boot magic
define Image/Build/NetgearNAND/buildkernel
	$(eval kernelsize=$(call mtdpartsize,kernel,$(4)))
	$(call PatchKernelLzma,$(2),$(3) $(4),-d20)
	dd if=$(KDIR_TMP)/vmlinux-$(2).bin.lzma \
		of=$(KDIR_TMP)/vmlinux-$(2).bin.tmp \
		bs=$$(($(kernelsize)-131072-2*64-1)) \
		count=1 conv=sync
	$(call MkuImage,lzma,-M $(5),$(KDIR_TMP)/vmlinux-$(2).bin.tmp,$(KDIR_TMP)/vmlinux-$(2).uImage)
	echo -ne '\xff' >> $(KDIR_TMP)/vmlinux-$(2).uImage
	# create a fake rootfs image
	dd if=/dev/zero of=$(KDIR_TMP)/fakeroot-$(2) bs=131072 count=1
	mkimage -A mips -O linux -T filesystem -C none \
		-a 0xbf070000 -e 0xbf070000 \
		-n 'MIPS $(VERSION_DIST) fakeroot' \
		-d $(KDIR_TMP)/fakeroot-$(2) \
		-M $(5) \
		$(KDIR_TMP)/fakeroot-$(2).uImage
	# append the fake rootfs image to the kernel, it will reside in the last
	# erase block of the kernel partition
	cat $(KDIR_TMP)/fakeroot-$(2).uImage >> $(KDIR_TMP)/vmlinux-$(2).uImage
endef


# $(1): rootfs image suffix
# $(2): Board name (small caps)
# $(3): Kernel board specific cmdline
# $(4): Kernel mtdparts definition
# $(5): U-Boot magic
# $(6): Board name (upper caps)
# $(7): firmware region code (not used yet)
# $(8): DNI Hardware version
# $(9): suffix of the configuration file for ubinize
define Image/Build/NetgearNAND
	$(eval firmwaresize=$(call mtdpartsize,firmware,$(4)))
	$(eval kernelsize=$(call mtdpartsize,kernel,$(4)))
	$(eval imageraw=$(KDIR_TMP)/$(2)-raw.img)
	$(CP) $(KDIR)/root.squashfs-raw $(KDIR_TMP)/root.squashfs
	echo -ne '\xde\xad\xc0\xde' > $(KDIR_TMP)/jffs2.eof
	$(call ubinize,ubinize-$(9).ini,$(KDIR_TMP),$(KDIR_TMP)/$(2)-root.ubi,128KiB,2048,-E 5)
	( \
		dd if=$(KDIR_TMP)/vmlinux-$(2).uImage; \
		dd if=$(KDIR_TMP)/$(2)-root.ubi \
	) > $(imageraw)
	$(STAGING_DIR_HOST)/bin/mkdniimg \
		-B $(6) -v $(VERSION_DIST).$(REVISION) -r "$$r" $(8) \
		-i $(imageraw) \
		-o $(call imgname,ubi,$(2))-factory.img

	$(call Image/Build/SysupgradeNAND,$(2),squashfs,$(KDIR_TMP)/vmlinux-$(2).uImage)
endef

ZYXEL_UBOOT = $(KDIR)/u-boot-nbg460n_550n_550nh.bin
ZYXEL_UBOOT_BIN = $(wildcard $(BIN_DIR)/u-boot-nbg460n_550n_550nh/u-boot.bin)

Image/Build/ZyXEL/buildkernel=$(call MkuImageLzma,$(2),$(3))

define Image/Build/ZyXEL
	$(call Sysupgrade/KRuImage,$(1),$(2),917504,2752512)
	if [ -e "$(call sysupname,$(1),$(2))" ]; then \
		if [ ! -f $(ZYXEL_UBOOT) ]; then \
			echo "Warning: $(ZYXEL_UBOOT) not found" >&2; \
		else \
			$(STAGING_DIR_HOST)/bin/mkzynfw \
				-B $(4) \
				-b $(ZYXEL_UBOOT) \
				-r $(call sysupname,$(1),$(2)):0x10000 \
				-o $(call factoryname,$(1),$(2)); \
	fi; fi
endef

define	Image/Build/ZyXELNAND/buildkernel
	$(eval kernelsize=$(call mtdpartsize,kernel,$(5)))
	$(call MkuImageLzma,$(2),$(3) $(5) $(6))
	mkdir -p $(KDIR_TMP)/$(2)/image/boot
	cp $(KDIR_TMP)/vmlinux-$(2).uImage $(KDIR_TMP)/$(2)/image/boot/vmlinux.lzma.uImage
	$(STAGING_DIR_HOST)/bin/mkfs.jffs2 \
		--pad=$(kernelsize) --big-endian --squash-uids -v -e 128KiB \
		-o $(KDIR_TMP)/$(2)-kernel.jffs2 \
		-d $(KDIR_TMP)/$(2)/image \
		2>&1 1>/dev/null | awk '/^.+$$/'
	-rm -rf $(KDIR_TMP)/$(2)
endef

define Image/Build/ZyXELNAND
	if [ "$(1)" != "squashfs" ]; then \
		echo Only squashfs is supported; \
		return 0; \
	fi
	$(eval firmwaresize=$(call mtdpartsize,firmware,$(4)))
	$(eval kernelsize=$(call mtdpartsize,kernel,$(4)))
	$(eval imageraw=$(KDIR_TMP)/$(2)-raw.img)
	$(CP) $(KDIR)/root.$(1) $(KDIR_TMP)/ubi_root.img
	$(call ubinize,ubinize-$(2).ini,$(KDIR_TMP),$(KDIR_TMP)/$(2)-root.ubi,128KiB,2048,-E 5)
	( \
		dd if=$(KDIR_TMP)/$(2)-kernel.jffs2; \
		dd if=$(KDIR_TMP)/$(2)-root.ubi \
	) > $(imageraw)
	dd if=$(imageraw) of=$(BIN_DIR)/$(IMG_PREFIX)-$(2)-$(1)-factory.bin \
		bs=128k conv=sync
	$(call Image/Build/SysupgradeNAND,$(2),squashfs,$(KDIR_TMP)/$(2)-kernel.jffs2)
endef


Image/Build/OpenMesh/buildkernel=$(call MkuImageLzma,$(2))
Image/Build/OpenMesh/initramfs=$(call MkuImageLzma/initramfs,$(2),)

define Image/Build/OpenMesh
	-sh $(TOPDIR)/scripts/om-fwupgradecfg-gen.sh \
		"$(4)" \
		"$(BUILD_DIR)/fwupgrade.cfg-$(4)" \
		"$(KDIR_TMP)/vmlinux-$(2).uImage" \
		"$(KDIR)/root.$(1)"
	-sh $(TOPDIR)/scripts/combined-ext-image.sh \
		"$(4)" "$(call factoryname,$(1),$(2))" \
		"$(BUILD_DIR)/fwupgrade.cfg-$(4)" "fwupgrade.cfg" \
		"$(KDIR_TMP)/vmlinux-$(2).uImage" "kernel" \
		"$(KDIR)/root.$(1)" "rootfs"
	if [ -e "$(call factoryname,$(1),$(2))" ]; then \
		cp "$(call factoryname,$(1),$(2))" "$(call sysupname,$(1),$(2))"; \
	fi
endef


Image/Build/Zcomax/buildkernel=$(call MkuImageLzma,$(2),$(3) $(4))
Image/Build/Zcomax/initramfs=$(call MkuImageLzma/initramfs,$(2),$(3) $(4))

define Image/Build/Zcomax
	$(call Sysupgrade/RKuImage,$(1),$(2),1507328,6356992)
	if [ -e "$(call sysupname,$(1),$(2))" ]; then \
		$(STAGING_DIR_HOST)/bin/mkzcfw \
			-B $(2) \
			-k $(KDIR_TMP)/vmlinux-$(2).uImage \
			-r $(KDIR)/root.$(1) \
			-o $(call imgname,$(1),$(2))-factory.img; \
	fi
endef


# $(1): template name to be defined.
# $(2): squashfs suffix to be used.
define BuildTemplate
  # $(1)     : name of build method.
  # $(2)     : board name.
  # $(3)     : kernel command line.
  # $(4)~$(8): extra arguments.
  define Image/Build/Template/$(1)/initramfs
    $$(call Image/Build/$$(1)/initramfs,initramfs,$$(2),$$(3),$$(4),$$(5),$$(6),$$(7),$$(8),$$(9),$$(10))
  endef
  define Image/Build/Template/$(1)/loader
    $$(call Image/Build/$$(1)/loader,$$(2),$$(3),$$(4),$$(5),$$(6),$$(7),$$(8),$$(9),$$(10))
  endef
  define Image/Build/Template/$(1)/buildkernel
    $$(call Image/Build/$$(1)/buildkernel,,$$(2),$$(3),$$(4),$$(5),$$(6),$$(7),$$(8),$$(9),$$(10))
  endef
  define Image/Build/Template/$(1)/squashfs
    $$(call Image/Build/$$(1),squashfs$(2),$$(2),$$(3),$$(4),$$(5),$$(6),$$(7),$$(8),$$(9),$$(10))
  endef
endef

$(eval $(call BuildTemplate,squashfs-only))
$(eval $(call BuildTemplate,64k,-64k))
$(eval $(call BuildTemplate,64kraw,-raw))
$(eval $(call BuildTemplate,64kraw-nojffs,-raw))
$(eval $(call BuildTemplate,128k))
$(eval $(call BuildTemplate,128kraw,-raw))
$(eval $(call BuildTemplate,256k))
$(eval $(call BuildTemplate,all))

$(eval $(call SingleProfile,NetgearNAND,64k,WNDR3700V4,wndr3700v4,WNDR3700_V4,ttyS0,115200,$$(wndr4300_mtdlayout),0x33373033,WNDR3700v4,"",-H 29763948+128+128,wndr4300))
$(eval $(call SingleProfile,NetgearNAND,64k,WNDR4300V1,wndr4300,WNDR4300,ttyS0,115200,$$(wndr4300_mtdlayout),0x33373033,WNDR4300,"",-H 29763948+0+128+128+2x2+3x3,wndr4300))
$(eval $(call SingleProfile,NetgearNAND,64k,R6100,r6100,R6100,ttyS0,115200,$$(r6100_mtdlayout),0x36303030,R6100,"",-H 29764434+0+128+128+2x2+2x2,wndr4300))
$(eval $(call SingleProfile,NetgearNAND,64k,WNDR4500V3,wndr4500v3,WNDR4500_V3,ttyS0,115200,$$(wndr4500v3_mtdlayout),0x27051956,WNDR4500series,"",-H 29764821+2+128+128+3x3+3x3+5508012173,wndr4300))

$(eval $(call SingleProfile,NetgearNAND,64k,WNDR4300V2,wndr4300v2,WNDR4300_V2,ttyS0,115200,$$(wndr4500v3_mtdlayout),0x27051956,WNDR4500series,"",-H 29764821+2+128+128+3x3+3x3+5508012173,wndr4300))

define Image/Build/squashfs
	cp $(KDIR)/root.squashfs $(KDIR)/root.squashfs-raw
	cp $(KDIR)/root.squashfs $(KDIR)/root.squashfs-64k
	$(STAGING_DIR_HOST)/bin/padjffs2 $(KDIR)/root.squashfs-64k 64
	$(call prepare_generic_squashfs,$(KDIR)/root.squashfs)
	dd if=$(KDIR)/root.$(1) of=$(BIN_DIR)/$(IMG_PREFIX)-root.$(1) bs=128k conv=sync
endef

define Image/Prepare
	$(if $(wildcard $(ZYXEL_UBOOT_BIN)),cp $(ZYXEL_UBOOT_BIN) $(ZYXEL_UBOOT))
	$(call CompressLzma,$(KDIR)/vmlinux,$(KDIR)/vmlinux.bin.lzma)
ifneq ($(CONFIG_TARGET_ROOTFS_INITRAMFS),)
	$(call CompressLzma,$(KDIR)/vmlinux-initramfs,$(KDIR)/vmlinux-initramfs.bin.lzma)
	$(call Image/BuildLoader,generic,elf,,,-initramfs)
endif
	$(call Image/BuildLoader,generic,elf)
endef

define Image/Prepare/Profile
	$(call Image/Build/Profile/$(1),loader)
endef

define Image/Build/Profile
	$(call Image/Build/Profile/$(1),buildkernel)
	$(if $(CONFIG_TARGET_ROOTFS_INITRAMFS),$(call Image/Build/Profile/$(1),initramfs))
	$(call Image/Build/Profile/$(1),$(2))
endef

# $(1): filesystem type.
define Image/Build
	$(call Image/Build/$(call rootfs_type,$(1)),$(1))
endef
