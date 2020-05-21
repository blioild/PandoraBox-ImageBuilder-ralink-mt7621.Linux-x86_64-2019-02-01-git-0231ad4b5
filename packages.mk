#  
#  _______________________________________________________________ 
# |    ____                 _                 ____               |
# |   |  _ \ __ _ _ __   __| | ___  _ __ __ _| __ )  _____  __   |
# |   | |_) / _` | '_ \ / _` |/ _ \| '__/ _` |  _ \ / _ \ \/ /   |
# |   |  __/ (_| | | | | (_| | (_) | | | (_| | |_) | (_) >  <    |
# |   |_|   \__,_|_| |_|\__,_|\___/|_|  \__,_|____/ \___/_/\_\   |
# |                                                              |
# |                  PandoraBox SDK Platform                     |
# |                  The Core of SmartRouter                     |
# |             Copyright 2013-2018 PandoraBox-Team              |
# |                http://www.pandorabox.com.cn                  |
# |______________________________________________________________|
#
#

###########################kernel-drivers###############################
USB3_CORE_SUPPORT := kmod-usb-core kmod-usb3
USB2_CORE_SUPPORT := kmod-usb-core kmod-usb2
USB1_CORE_SUPPORT := kmod-usb-core kmod-usb-ohci
		
GPIO_CTRL_SUPPORT := gpioctl kmod-gpio-dev
GPIO_LED_SUPPORT :=kmod-leds-gpio kmod-ledtrig-gpio kmod-ledtrig-timer kmod-ledtrig-netdev kmod-ledtrig-usbport kmod-ledtrig-heartbeat kmod-ledtrig-lightflow
GPIO_BUTTON_SUPPORT := kmod-gpio-button-pandorabox

I2C_CORE_SUPPORT := kmod-i2c-core

NAND_CORE_SUPPORT := ubi-utils uboot-envtools

NAND_UBIFS_SUPPORT := uboot-envtools  \
	mtd-utils-ubinfo mtd-utils-ubinize \
	mtd-utils-ubirmvol  mtd-utils-ubirsvol  \
	mtd-utils-ubiupdatevol mtd-utils-ubimkvol \
	mtd-utils-ubiattach mtd-utils-ubidetach \
	mtd-utils-nandwrite mtd-utils-nanddump 

#I2S_CORE_PACKAGES := kmod-i2s-core

CRYPTO_CORE_SUPPORT :=kmod-crypto-core kmod-crypto-cbc kmod-crypto-ecb kmod-crypto-hmac kmod-crypto-md5 kmod-crypto-aes kmod-crypto-ccm kmod-crypto-sha256 \
	kmod-crypto-sha1  kmod-crypto-user kmod-cryptodev 
	
##########################WiFi-driver##########################################
#qca-thermald-10.4
QCA_HOSTAPD := qca-hostap-10.4  qca-hostapd-cli-10.4 qca-wpa-supplicant-10.4 qca-wpa-cli-10.4

QCAWIFI_BASE_SUPPORT := $(QCA_HOSTAPD) ethtool 

ifneq ($(findstring $(SUBTARGET),ipq40xx ipq806x),)
QCAWIFI_BASE_SUPPORT += kmod-qca-wifi-10.4-unified-profile
else
QCAWIFI_BASE_SUPPORT += kmod-qca-wifi-10.4-unified-perf
endif

#for  IPQ40xx
QCAWIFI_IPQ40XX_SUPPORT := $(QCAWIFI_BASE_SUPPORT) qca-wifi-fw-hw5-10.4-asic 
#for  QCA9984
# qca-wifi-fw-hw9-10.4-asic is QCA9984 fw?
QCAWIFI_QCA9984_SUPPORT := $(QCAWIFI_BASE_SUPPORT) qca-wifi-fw-hw4-10.4-asic
#for QCA9980
QCAWIFI_QCA9980_SUPPORT := $(QCAWIFI_BASE_SUPPORT)  qca-wifi-fw-hw2-10.4-asic 
#for QCA9880
QCAWIFI_QCA9880_SUPPORT := $(QCAWIFI_BASE_SUPPORT) qca-wifi-fw-hw6-10.4-asic 
#for QCA9882
QCAWIFI_QCA9882_SUPPORT := $(QCAWIFI_BASE_SUPPORT) qca-wifi-fw-hw6-10.4-asic 
#for QCA9887
QCAWIFI_QCA9887_SUPPORT := $(QCAWIFI_BASE_SUPPORT) qca-wifi-fw-hw3-10.4-asic 
#for QCA9886
QCAWIFI_QCA9888_SUPPORT := $(QCAWIFI_BASE_SUPPORT) qca-wifi-fw-hw11-10.4-asic 

QCAWIFI_FACTORY_SUPPORT := $(QCAWIFI_BASE_SUPPORT) qcmbr-10.4 athdiag kmod-art2

#MTK-WiFi driver
MTKWIFI_BASE_SUPPORT := 8021xd bndstrg  mtkiappd ralink-apctrl
MTKWIFI_RT2860V2_SUPPORT := $(MTKWIFI_BASE_SUPPORT) kmod-rt2860v2
MTKWIFI_MT7628_SUPPORT  := $(MTKWIFI_BASE_SUPPORT) kmod-mt7628
MTKWIFI_MT7603E_SUPPORT := $(MTKWIFI_BASE_SUPPORT) kmod-mt7603e
MTKWIFI_MT76X2E_SUPPORT := $(MTKWIFI_BASE_SUPPORT) kmod-mt76x2e
MTKWIFI_MT7610E_SUPPORT := $(MTKWIFI_BASE_SUPPORT) kmod-mt7610e
MTKWIFI_MT7615N_SUPPORT := $(MTKWIFI_BASE_SUPPORT) kmod-mt7615
MTKWIFI_MT7615D_SUPPORT := $(MTKWIFI_BASE_SUPPORT) kmod-mt7615-dbdc
MTKWIFI_RT5592_SUPPORT := $(MTKWIFI_BASE_SUPPORT) kmod-rt5592

#Realtek-WiFi driver
RTKWiFi_BASE_SUPPORT := hostapd wpad hostapd-utils  kmod-cfg80211 kmod-mac80211 
RTKWiFi_RTL8192_AP  := $(RTKWiFi_BASE_SUPPORT) kmod-rtl8192
RTKWiFi_RTL8812_SUPPORT := $(RTKWiFi_BASE_SUPPORT) kmod-rtl8812
RTKWiFi_RTL8814_SUPPORT := $(RTKWiFi_BASE_SUPPORT) kmod-rtl8814
RTKWiFi_RTL8197_SUPPORT := $(RTKWiFi_BASE_SUPPORT) kmod-rtl8197

#Lantiq  WiFi driver
LANTIQ_BASE_SUPPORT := lantiq-hostapd lantiq-hostapd-cli lantiq-wpad
LANTIQ_WAVE300_SUPPORT := kmod-lantiq-wave300 kmod-lantiq-fw 
LANTIQ_WAVE500_SUPPORT :=
LANTIQ_WAVE600_SUPPORT :=  

#Celeno WiFi driver
CELENO_BASE_SUPPORT := celeno-hostapd celeno-hostapd-cli celeno-wpa-wpad
CELENO_CL2400_SUPPORT := kmod-cl-atm kmod-cl2400 


#MAC80211 driver
MAC80211_HOSTPAD :=  hostapd wpad hostapd-utils 
MAC80211_BASE_SUPPORT := kmod-cfg80211 kmod-mac80211 $(MAC80211_HOSTPAD)

MAC80211_ATH10K := $(MAC80211_BASE_SUPPORT) kmod-ath10k
MAC80211_ATH10K_CT := $(MAC80211_BASE_SUPPORT) kmod-ath10k-ct
MAC80211_ATH9K := $(MAC80211_BASE_SUPPORT) kmod-ath9k
MAC80211_ATH5K := $(MAC80211_BASE_SUPPORT) kmod-ath5k

MAC80211_ATH9K_SUPPORT := $(MAC80211_ATH9K)
MAC80211_ATH10K_QCA988X_SUPPORT := $(MAC80211_ATH10K) ath10k-firmware-qca988x 
MAC80211_ATH10K_QCA998X_SUPPORT := $(MAC80211_ATH10K) ath10k-firmware-qca9984
MAC80211_ATH10K_QCA99X0_SUPPORT := $(MAC80211_ATH10K) ath10k-firmware-qca99x0
MAC80211_ATH10K_QCA9887_SUPPORT := $(MAC80211_ATH10K) ath10k-firmware-qca9887
MAC80211_ATH10K_QCA6174_SUPPORT := $(MAC80211_ATH10K) ath10k-firmware-qca6174
		 

########################Network##################################
	
HWNAT_SUPPORT:= luci-app-hwacc luci-i18n-hwacc-zh-cn 

SFE_SUPPORT:= kmod-shortcut-fe kmod-shortcut-fe-cm kmod-shortcut-fe-drv luci-app-sfe  luci-i18n-sfe-zh-cn

NETWORK_BASE_SUPPORT := wireless-tools iwinfo firewall netifd rpcd ubusd logd \
	kmod-ppp ppp \
	kmod-pptp ppp-mod-pptp  \
	kmod-pppol2tp ppp-mod-pppol2tp \
	kmod-ipt-fullconenat iptables-mod-fullconenat \
	kmod-gre iptables-mod-nat-extra \
	dnsmasq-full \
	kmod-nf-nat6  kmod-nf-conntrack6 \
	ip6tables ip6tables-mod-nat \
	ip6tables-extra kmod-nf-nathelper-extra 


########################Storage##################################	
STORAGE_BASE_SUPPORT := kmod-nls-cp437 kmod-nls-cp936 kmod-nls-iso8859-1 kmod-nls-utf8 \
	kmod-fs-vfat kmod-fs-ext4 kmod-fs-exfat fstools block-mount
	
ifneq ($(findstring $(SUBTARGET),generic),)
STORAGE_BASE_SUPPORT += kmod-fs-ufsd
endif

ifneq ($(findstring $(SUBTARGET),mt7620 mt7621 mt7628),)
STORAGE_BASE_SUPPORT += kmod-fs-ufsd
endif

ifneq ($(findstring $(SUBTARGET),ipq40xx ipq806x),)
STORAGE_BASE_SUPPORT += kmod-fs-ufsd kmod-fs-ufsd-jnl
endif

STORAGE_EXT_SUPPORT := $(STORAGE_BASE_SUPPORT)  \
			fdisk hdparm ufsd-tools mkdosfs dosfsck exfat-utils libext2fs e2fsprogs parted \
			
SATA_AHCI_STORAGE_BASE := $(STORAGE_BASE_SUPPORT) kmod-ata-core kmod-ata-ahci 

USB_STORAGE_BASE_SUPPORT := $(STORAGE_BASE_SUPPORT) kmod-usb-storage kmod-usb-storage-extras kmod-scsi-core  \
		kmod-ledtrig-usbport fdisk
		
SD_STORAGE_SUPPORT := $(STORAGE_BASE_SUPPORT) kmod-mmc

NTFS_3G_SUPPORT := ntfs-3g-low ntfsprogs_ntfs-3g
HD_SLEEP_SUPPORT :=luci-app-hd-idle luci-i18n-hd-idle-zh-cn hd-idle
NFS_SERVER_PACKAGES := nfs-utils nfs-kernel-server-pandorabox

#########################Sound#################################
SOUND_BASE_SUPPORT := kmod-sound-core alsa-utils madplay-alsa 
USB_SOUND_SUPPORT:= kmod-sound-core kmod-usb-audio kmod-usb-cm109 kmod-usb-hid

SOUND_PACKAGES_SHAIPORT:= $(SOUND_BASE_SUPPORT) shairport luci-app-shairport

SOUND_PACKAGES_DLNA_GMA := $(SOUND_BASE_SUPPORT) gst1-mod-autodetect \
	gst1-mod-souphttpsrc gst1-plugins-base  gst1-mod-playback   \
	gst1-mod-flac gst1-mod-ogg gst1-mod-wavparse gst1-mod-mad gst1-mod-id3demux \
	gst1-plugins-good \
	gstreamer1 gmediarender
	
SOUND_PACKAGES_DLNA_UPMPC := $(SOUND_BASE_SUPPORT) gst1-mod-autodetect \
	gst1-mod-souphttpsrc gst1-plugins-base  gst1-mod-playback \
	gst1-mod-flac gst1-mod-ogg gst1-mod-wavparse gst1-mod-mad  \
	gst1-mod-id3demux gst1-plugins-good \
	mpd-full upmpdcli

########################4G LTE Modem####################################
4G_CELLULAR_MODEMS_SUPPORT :=kmod-usb-net  kmod-usb-net-rndis kmod-usb-net-sierrawireless kmod-usb-net-qmi-wwan \
		kmod-usb-net-cdc-mbim kmod-usb-net-cdc-ncm  kmod-usb-net-cdc-eem kmod-usb-serial-sierrawireless \
		kmod-usb-serial kmod-usb-serial-option kmod-usb-serial-wwan chat usbutils minicom usbreset ext-cellular-basic ext-sms

#########################Ohters###########################################

LXC_SUPPORT := xz-utils lxc luci-app-lxc luci-i18n-lxc-zh-cn kmod-ikconfig lxc-attach lxc-autostart lxc-cgroup lxc-checkconfig lxc-common \
	lxc-config lxc-configs lxc-console lxc-copy lxc-create lxc-destroy lxc-device lxc-execute lxc-freeze lxc-hooks \
	lxc-info lxc-init lxc-ls lxc-lua lxc-monitor lxc-monitord lxc-snapshot lxc-start lxc-stop lxc-templates \
	lxc-top lxc-unfreeze lxc-unshare lxc-user-nic lxc-usernsexec lxc-wait lxcfs\
	htop debootstrap bash lscpu tar gnupg \
	fuse-utils kmod-fuse kmod-veth kmod-macvlan kmod-tulip \
	kmod-nf-nat6  kmod-nf-conntrack6 kmod-gre6 kmod-tun kmod-sit

DNSMASQ_FULL_PACKAGES:= dnsmasq-full kmod-ipt-ipset kmod-ipt-tproxy kmod-tun iptables-mod-tproxy 

FTP_SERVER_SUPPORT := luci-app-vsftpd luci-i18n-vsftpd-zh-cn vsftpd

#SAMBA3_SERVER_SUPPORT :=luci-app-samba luci-i18n-samba-zh-cn samba3-pandorabox

SAMBA4_SERVER_SUPPORT :=luci-app-samba luci-i18n-samba-zh-cn samba4-server

PRINTER_SERVER_SUPPORT := luci-app-usb-printer luci-i18n-usb-printer-zh-cn kmod-usb-printer p910nd 

MS_KMS_SUPPORT:= luci-app-vlmcsd luci-i18n-vlmcsd-zh-cn

SYNCDIAL_SUPPORT := luci-app-syncdial luci-app-mwan3 luci-i18n-mwan3-zh-cn

WIFI_SCHEDULE_SUPPORT := luci-app-wifischedule luci-i18n-wifischedule-zh-cn

PPPOE_SERVER_SUPPORT:= luci-app-pppoeserver rp-pppoe-server luci-i18n-rp-pppoe-server-zh-cn

PPTP_SERVER_SUPPORT:= luci-app-pptp-server luci-i18n-pptp-server-zh-cn

WOL_CLIENT_SUPPORT := luci-app-wol etherwake wol  luci-i18n-wol-zh-cn

PEAR_SHADOWFOG_SUPPORT:= luci-app-shadowfog shadowfog

MJPEG_STEAM_SUPPORT :=luci-app-mjpg-streamer luci-i18n-mjpg-streamer-zh-cn

PEAR_FOGVDN_SUPPORT:= pear_cdn 

PEAR_OTA_SUPPORT:= pear_ota 

SHADOWSOCKS_SUPPORT:= luci-app-shadowsocks shadowsocks-libev luci-app-chinadns

TRANSMISSION_DOWNLOAD_SUPPORT :=luci-app-transmission luci-i18n-transmission-zh-cn  transmission-cli-openssl  \
	transmission-daemon-openssl transmission-web-full

ARIA2_DOWNLOAD_SUPPORT :=luci-app-aria2 luci-i18n-aria2-zh-cn

AMULE_DOWNLOAD_SUPPORT := luci-app-amule luci-i18n-amule-zh-cn

FILEMANAGER_SUPPORT := luci-app-filemanager

ORAY_PHDDNS2_SUPPORT :=luci-app-phddns2 luci-i18n-phddns2-zh-cn

HDD_SMART_SUPPORT :=  luci-app-smartinfo luci-i18n-smartinfo-zh-cn

SER2NET_SUPPORT :=luci-app-ser2net luci-i18n-ser2net-zh-cn ser2net

SSR_PRO_SUPPORT := luci-app-ssr-pro luci-i18n-ssr-pro-zh-cn

SSR_PLUS_SUPPORT := luci-app-ssr-plus luci-i18n-ssr-plus-zh-cn

TTYD_SUPPORT := luci-app-ttyd luci-i18n-ttyd-zh-cn

V2RAY_PRO_SUPPORT :=luci-app-v2ray-pro luci-i18n-v2ray-pro-zh-cn

ADABYBY_PLUS_SUPPORT :=luci-app-adbyby-plus luci-i18n-adbyby-plus-zh-cn

PANDORABOX_DEBUG_SUPPORT :=perf-pandorabox memtester usbreset usbutils strace pciutils gdbserver gdb

LINKSYS_DUALBOOT_SUPPORT := luci-app-advanced-reboot luci-i18n-advanced-reboot-zh-cn

TARGET_BASE_SUPPORT :=  maccalc 
I2C_SUPPORT  := $(I2C_CORE_SUPPORT)
I2S_SUPPORT  := $(SOUND_BASE_SUPPORT)
MMC_SUPPORT  := $(SD_STORAGE_SUPPORT)
SATA_SUPPORT := $(SATA_AHCI_STORAGE_BASE)
USB2_SUPPORT := $(USB_STORAGE_BASE_SUPPORT) $(USB2_CORE_SUPPORT) $(USB1_CORE_SUPPORT)
USB3_SUPPORT := $(USB2_SUPPORT) $(USB3_CORE_SUPPORT)
HW_CRYPTO_SUPPORT:= $(CRYPTO_CORE_SUPPORT)
RTC_SUPPORT := $(I2C_CORE_SUPPORT)  kmod-rtc-pcf8563 kmod-gpio-pcf857x
USB_VIDEO_SUPPORT :=  kmod-video-core kmod-video-gspca-core kmod-video-uvc kmod-video-gspca-zc3xx \
	kmod-video-gspca-sunplus  kmod-video-gspca-sn9c20x kmod-video-gspca-ov519 \
	kmod-video-gspca-ov534  kmod-video-gspca-ov534-9

###########################TARGET PACAKGE#######################################
#MT762x
ifneq ($(findstring $(SUBTARGET),mt7620 mt7621 mt7628),)
TARGET_BASE_SUPPORT += swconfig ralink-utils kmod-gre nvram-ralink
TARGET_BASE_SUPPORT += $(if $(CONFIG_TARGET_ralink_mt7620)$(CONFIG_TARGET_ralink_mt7621),hwnat)

I2C_SUPPORT += kmod-ralink-i2c
I2S_SUPPORT += $(I2C_SUPPORT) kmod-sound-core kmod-sound-soc-core kmod-sound-mt762x
MMC_SUPPORT += kmod-mt762x-mmc
endif

#AR71XX
ifneq ($(findstring $(SUBTARGET),generic),)
#STORAGE_BASE_SUPPORT += kmod-fs-ufsd
TARGET_BASE_SUPPORT += swconfig
endif

#IPQ40xx
ifeq ($(SUBTARGET),ipq40xx)
TARGET_BASE_SUPPORT += swconfig uboot-envtools qca-ssdk-shell \
		kmod-qca-ssdk-hnat kmod-qca-rfs kmod-qca-edma ethtool \
		$(QCA_HW_CRYPTO)
USB3_SUPPORT += kmod-usb-dwc3 kmod-usb-dwc3-ipq40xx kmod-usb-phy-dwc3-ipq40xx
HW_CRYPTO_SUPPORT += kmod-crypto-qcrypto 
endif

#IPQ806X
IPQ806x_NSS_CRYPTO:= kmod-qca-nss-crypto kmod-qca-nss-cfi kmod-qca-nss-drv-ipsecmgr 
IPQ806x_NSS_ACC:= kmod-qca-nss-drv-capwapmgr  \
kmod-qca-nss-drv-l2tpv2 kmod-qca-nss-drv-lag-mgr \
kmod-qca-nss-drv-map-t  kmod-qca-nss-drv-pptp \
kmod-qca-nss-drv-profile kmod-qca-nss-drv-tun6rd \
kmod-qca-nss-drv-tunipip6 kmod-qca-nss-drv-vlan-mgr 

IPQ806x_NSS_SUPPORT:= kmod-qca-nss-drv

ifeq ($(SUBTARGET),ipq806x)
TARGET_BASE_SUPPORT += swconfig uboot-envtools kmod-qca-ssdk-hnat kmod-qca_85xx_sw qca-ssdk-shell  \
		ethtool kmod-qca-nss-gmac  kmod-qca-rfs  $(IPQ806x_NSS_SUPPORT) \
		
USB3_SUPPORT +=  kmod-usb-dwc3 kmod-usb-dwc3-qcom 

SATA_SUPPORT += kmod-ata-core  kmod-ata-ahci kmod-achi-ipq806x

HW_CRYPTO_SUPPORT += $(IPQ806x_NSS_CRYPTO)
HWNAT_SUPPORT := $(IPQ806x_NSS_ACC) kmod-qca-nss-ecm
endif

PANDORABOX_BASE_SUPPORT :=  pb_ubisplit pbfw-fwcheck \
	$(GPIO_CTRL_SUPPORT) $(GPIO_LED_SUPPORT) $(GPIO_BUTTON_SUPPORT) \
	$(NETWORK_BASE_SUPPORT) \
	pbr-optimizer \
	wan-discovery http_hook detect_internet \
	$(TARGET_BASE_SUPPORT)
		    
########################### Luci界面######################################
WEB_PACKAGES_LUCI_BASE := uhttpd luci luci-app-uhttpd luci-i18n-uhttpd-zh-cn luci-proto-ppp luci-proto-ipv6 luci-mod-admin-full luci-i18n-base-zh-cn  \
	luci-app-update luci-i18n-update-zh-cn \
	luci-theme-darkmatter  \
	luci-app-bandwidth luci-i18n-bandwidth-zh-cn \
	luci-app-firewall luci-i18n-firewall-zh-cn \
	luci-app-ddns luci-i18n-ddns-zh-cn  \
	luci-app-upnp luci-i18n-upnp-zh-cn \
	luci-app-arpbind luci-i18n-arpbind-zh-cn \
	luci-app-optimizer luci-i18n-optimizer-zh-cn 

WEB_PANDORABOX_PACKAGES:= $(DNSMASQ_FULL_PACKAGES) luci-pandorabox-simple

##############################最终产品(Demo)#######################################
#标准AP，带AP认证, PGB-AP01
PANDORABOX_AP_GENERIC := $(PANDORABOX_BASE_SUPPORT) $(WEB_PACKAGES_LUCI_BASE)

#标准AP，带AC认证, PGB-AC01
PANDORABOX_AC_GENERIC := $(PANDORABOX_BASE_SUPPORT) $(WEB_PACKAGES_LUCI_BASE)

#NAS存储服务器，PGB-N1
PANDORABOX_NAS_GENERIC := $(PANDORABOX_BASE_SUPPORT) $(WEB_PACKAGES_LUCI_BASE) $(SAMBA4_SERVER_SUPPORT) \
	$(TRANSMISSION_DOWNLOAD_SUPPORT) $(ARIA2_DOWNLOAD_SUPPORT) $(STORAGE_EXT_SUPPORT) \
	$(FILEMANAGER_SUPPORT) $(FTP_SERVER_SUPPORT) $(ORAY_PHDDNS2_SUPPORT) \
	$(HDD_SMART_SUPPORT)

#标准无线路由器,PGB-RB1
PANDORABOX_ROUTER_GENERIC := $(PANDORABOX_BASE_SUPPORT) $(WEB_PACKAGES_LUCI_BASE) $(HWNAT_SUPPORT) $(SFE_SUPPORT) $(SYNCDIAL_SUPPORT)

#XXX路由器,PGB-X1
PANDORABOX_ROUTER_XXNET := $(PANDORABOX_BASE_SUPPORT) $(WEB_PACKAGES_LUCI_BASE) $(V2RAY_PRO_SUPPORT) $(SSR_PLUS_SUPPORT) $(ADABYBY_PLUS_SUPPORT)

#媒体播放器,PBG-MP1
PANDORABOX_MEDIA_PLAYER_GENERIC := $(PANDORABOX_BASE_SUPPORT) $(WEB_PACKAGES_LUCI_BASE)

#4G路由器,PGB-LTE1
PANDORABOX_4G_ROUTER_GENERIC := $(PANDORABOX_ROUTER_GENERIC) $(FTP_SERVER_SUPPORT) \
				$(TTYD_SUPPORT) $(SER2NET_SUPPORT) \
				$(4G_CELLULAR_MODEMS_SUPPORT) 

#打印服务器,PGB-PT1
PANDORABOX_PRINTER_SERVER_GENERIC := $(PANDORABOX_BASE_SUPPORT) $(WEB_PACKAGES_LUCI_BASE) $(PRINTER_SERVER_SUPPORT)

#网络摄像头,PGB-CM1
#FIXEME:Broken the qcawifi if qualcomm target
PANDORABOX_WEBCAMERA_GENERIC := $(PANDORABOX_BASE_SUPPORT) $(WEB_PACKAGES_LUCI_BASE) $(USB_VIDEO_SUPPORT) $(MJPEG_STEAM_SUPPORT)

#路由器——简易存储,PGB-N1C
PANDORABOX_ROUTER_NAS_LITE := $(PANDORABOX_ROUTER_GENERIC) $(SAMBA4_SERVER_SUPPORT) $(FTP_SERVER_SUPPORT)

#路由器+NAS,PGB-RN1
PANDORABOX_ROUTER_NAS_GENERIC := $(PANDORABOX_ROUTER_GENERIC) $(PANDORABOX_NAS_GENERIC)

#完整功能,PGB-RF1
PANDORABOX_ALL_FULL := $(PANDORABOX_NAS_GENERIC) $(PANDORABOX_ROUTER_GENERIC) $(PANDORABOX_PRINTER_SERVER_GENERIC) $(PANDORABOX_WEBCAMERA_GENERIC) $(PANDORABOX_ROUTER_XXNET)

#CDN功能,PGB-PE1
PANDORABOX_ROTER_4_PEAR :=  $(PANDORABOX_ROUTER_GENERIC) $(STORAGE_EXT_SUPPORT) $(SAMBA4_SERVER_SUPPORT) $(FTP_SERVER_SUPPORT) \
		$(SYNCDIAL_SUPPORT) $(DNSMASQ_FULL_PACKAGES) $(MS_KMS_SUPPORT) \
		$(PEAR_SHADOWFOG_SUPPORT) $(PEAR_FOGVDN_SUPPORT) $(PEAR_OTA_SUPPORT) \
		$(LXC_SUPPORT)


