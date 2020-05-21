# BASE Components
USB3_PACKAGES := kmod-usb3

USB_STORAGE_BASE_PACKAGES := kmod-usb-core kmod-usb2 kmod-usb-ohci kmod-usb-storage kmod-usb-storage-extras kmod-scsi-core  \
		kmod-ledtrig-usbport block-mount
		
SATA_AHCI_STORAGE_BASE := kmod-ata-core kmod-ata-ahci 

STORAGE_UTILS_PACKAGES_LITE := $(SD_STORAGE_BASE_PACKAGES) $(USB_STORAGE_BASE_PACKAGES) kmod-nls-cp437 kmod-nls-cp936 kmod-nls-iso8859-1 kmod-nls-utf8 \
			kmod-fs-vfat kmod-fs-ext4 kmod-fs-exfat \
			samba4-server
			
STORAGE_UTILS_PACKAGES_FULL := $(STORAGE_UTILS_PACKAGES_LITE)  kmod-fs-isofs kmod-fs-udf \
			fdisk hdparm  mkdosfs dosfsck exfat-utils libext2fs e2fsprogs cfdisk parted \
			vsftpd ip6tables-mod-nat kmod-scsi-cdrom ntfs-3g
			
USB_3G_DONGLE_PACKAGES := luci-proto-3g comgt kmod-usb-net  kmod-usb-net-rndis kmod-usb-net-sierrawireless kmod-usb-net-qmi-wwan \
		kmod-usb-serial kmod-usb-serial-option kmod-usb-serial-wwan chat
		
PBR_OPTIMIZER_PACKAGES:=pbr-optimizer luci-app-optimizer luci-i18n-optimizer-zh-cn

USB_SOUND_PACKAGES:= kmod-sound-core kmod-usb-audio kmod-usb-cm109 kmod-usb-hid

SOUND_PACKAGES := kmod-sound-core alsa-utils madplay-alsa 

SOUND_PACKAGES_DLNA_GMA := $(SOUND_PACKAGES) gst1-mod-autodetect \
gst1-mod-souphttpsrc gst1-plugins-base  gst1-mod-playback   \
gst1-mod-flac gst1-mod-ogg gst1-mod-wavparse gst1-mod-mad gst1-mod-id3demux \
gst1-plugins-good \
gstreamer1 gmediarender

SOUND_PACKAGES_DLNA_UPMPC := gst1-mod-autodetect \
gst1-mod-souphttpsrc gst1-plugins-base  gst1-mod-playback \
gst1-mod-flac gst1-mod-ogg gst1-mod-wavparse gst1-mod-mad  \
gst1-mod-id3demux gst1-plugins-good \
mpd-full upmpdcli

SOUND_PACKAGES_SHAIPORT:= $(SOUND_PACKAGES) shairport luci-app-shairport

HWNAT_PACKAGES:= 

NAND_PACKAGES:= pb_ubisplit

PRINTER_PACKAGES := luci-app-usb-printer luci-i18n-usb-printer-zh-cn kmod-usb-printer p910nd 

MS_KMS_PACKAGES:= luci-app-vlmcsd luci-i18n-vlmcsd-zh-cn

SYNCDIAL_PACKAGES := luci-app-syncdial luci-app-mwan3 luci-i18n-mwan3-zh-cn

NTFS_3G_PACKAGES := ntfs-3g-low ntfsprogs_ntfs-3g

NFS_SERVER_PACKAGES := nfs-utils nfs-kernel-server-pandorabox

WIFI_SCHEDULE_PACKAGES := luci-app-wifischedule luci-i18n-wifischedule-zh-cn

PPPOE_SERVER_PACKAGES:= luci-app-pppoeserver rp-pppoe-server luci-i18n-rp-pppoe-server-zh-cn
WOL_PACKAGES:= luci-app-wol etherwake wol  luci-i18n-wol-zh-cn
PEAR_SHADOWFOG_PACKAGES:= luci-app-shadowfog shadowfog
SHADOWSOCKS_PACKAGES:= luci-app-shadowsocks shadowsocks-libev luci-app-chinadns

LXC_PACKAGES:= luci-app-lxc kmod-ikconfig lxc-attach lxc-auto lxc-autostart lxc-cgroup lxc-checkconfig lxc-common \
lxc-config lxc-configs lxc-console lxc-copy lxc-create lxc-destroy lxc-device lxc-execute lxc-freeze lxc-hooks \
lxc-info lxc-init lxc-ls lxc-lua lxc-monitor lxc-monitord lxc-snapshot lxc-start lxc-stop lxc-templates \
lxc-top lxc-unfreeze lxc-unshare lxc-user-nic lxc-usernsexec lxc-wait 

TRANSMISSION_PACKAGES :=luci-app-transmission luci-i18n-transmission-zh-cn  transmission-cli-openssl  \
transmission-daemon-openssl transmission-web-full

HD_IDLE_PACKAGES :=luci-app-hd-idle luci-i18n-hd-idle-zh-cn hd-idle \

DEBUG_PACKAGES :=perf-pandorabox memtester usbreset usbutils strace pciutils  gdbserver gdb

DNSMASQ_LITE_PACKAGES:= dnsmasq-dhcpv6 
DNSMASQ_FULL_PACKAGES:= dnsmasq-full kmod-ipt-ipset kmod-ipt-tproxy kmod-tun iptables-mod-tproxy 

PANDORABOX_BASE_PACKAGES := pbfw-fwcheck kmod-gpio-button-pandorabox \
swconfig  wireless-tools iwinfo maccalc logd gpioctl kmod-gpio-dev \
fkmod-leds-gpio kmod-ledtrig-gpio kmod-ledtrig-timer kmod-ledtrig-netdev \
kmod-gre wan-discovery http_hook detect_internet 8021xd
		    
########################### Webs ######################################
WEB_PACKAGES_LUCI_BASE := uhttpd luci luci-app-uhttpd luci-mod-admin-full luci-i18n-base-zh-cn \
luci-i18n-uhttpd-zh-cn luci-proto-ppp luci-theme-material luci-theme-xeye luci-theme-bootstrap \
luci-app-bandwidth luci-i18n-bandwidth-zh-cn luci-app-firewall luci-i18n-firewall-zh-cn \
luci-app-ddns luci-i18n-ddns-zh-cn  luci-app-upnp luci-i18n-upnp-zh-cn \
luci-app-arpbind luci-i18n-arpbind-zh-cn luci-app-update luci-i18n-update-zh-cn iwinfo 

WEB_PACKAGES_LUCI_FULL := $(WEB_PACKAGES_LUCI_BASE) luci-app-vsftpd luci-i18n-vsftpd-zh-cn \
luci-app-samba luci-i18n-samba-zh-cn

WEB_PANDORABOX_PACKAGES:= $(DNSMASQ_FULL_PACKAGES) luci-pandorabox-simple iwinfo
	
PANDORABOX_NAS_PACKAGES := $(TRANSMISSION_PACKAGES) $(HD_IDLE_PACKAGES) ttyd luci-app-filemanager
