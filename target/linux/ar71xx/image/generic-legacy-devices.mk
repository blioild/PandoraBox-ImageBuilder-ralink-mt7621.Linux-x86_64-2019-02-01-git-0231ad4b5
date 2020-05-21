
define LegacyDevice/AP96
  DEVICE_TITLE := Atheros AP96 reference board
  DEVICE_PACKAGES := kmod-usb-core kmod-usb2
endef
LEGACY_DEVICES += AP96

define LegacyDevice/WNDAP360
  DEVICE_TITLE := NETGEAR WNDAP360
endef
LEGACY_DEVICES += WNDAP360

define LegacyDevice/AP121_8M
  DEVICE_TITLE := Atheros AP121 reference board (8MB flash)
  DEVICE_PACKAGES := kmod-usb-core kmod-usb2
endef
LEGACY_DEVICES += AP121_8M

define LegacyDevice/AP121_16M
  DEVICE_TITLE := Atheros AP121 reference board (16MB flash)
  DEVICE_PACKAGES := kmod-usb-core kmod-usb2
endef
LEGACY_DEVICES += AP121_16M

define LegacyDevice/AP132
  DEVICE_TITLE := Atheros AP132 reference board
  DEVICE_PACKAGES := kmod-usb-core kmod-usb2 kmod-usb-storage
endef
LEGACY_DEVICES += AP132

define LegacyDevice/AP135
  DEVICE_TITLE := Atheros AP135 reference board
  DEVICE_PACKAGES := kmod-usb-core kmod-usb2 kmod-usb-storage
endef
LEGACY_DEVICES += AP135

define LegacyDevice/AP136_010
  DEVICE_TITLE := Atheros AP136-010 reference board
  DEVICE_PACKAGES := kmod-usb-core kmod-usb2 kmod-usb-storage
endef
LEGACY_DEVICES += AP136_010

define LegacyDevice/AP136_020
  DEVICE_TITLE := Atheros AP136-020 reference board
  DEVICE_PACKAGES := kmod-usb-core kmod-usb2 kmod-usb-storage
endef
LEGACY_DEVICES += AP136_020

define LegacyDevice/AP143_8M
  DEVICE_TITLE := Qualcomm Atheros AP143 reference board (8MB flash)
  DEVICE_PACKAGES := kmod-usb-core kmod-usb2 kmod-usb-storage
endef
LEGACY_DEVICES += AP143_8M

define LegacyDevice/AP143_16M
  DEVICE_TITLE := Qualcomm Atheros AP143 reference board (16MB flash)
  DEVICE_PACKAGES := kmod-usb-core kmod-usb2 kmod-usb-storage
endef
LEGACY_DEVICES += AP143_16M

define LegacyDevice/AP147_010
  DEVICE_TITLE := Qualcomm Atheros AP147-010 reference board
  DEVICE_PACKAGES := kmod-usb-core kmod-usb2 kmod-usb-storage
endef
LEGACY_DEVICES += AP147_010

define LegacyDevice/AP152_16M
  DEVICE_TITLE := Qualcomm Atheros AP152 reference board (16MB flash)
  DEVICE_PACKAGES := kmod-usb-core kmod-usb2 kmod-usb-storage
endef
LEGACY_DEVICES += AP152_16M

define LegacyDevice/WNR2200
  DEVICE_TITLE := NETGEAR WNR2200
  DEVICE_PACKAGES := kmod-usb-core kmod-usb2 kmod-usb-ledtrig-usbport
endef
LEGACY_DEVICES += WNR2200

define LegacyDevice/PB42
  DEVICE_TITLE := Atheros PB42 reference board
  DEVICE_PACKAGES := kmod-usb-core kmod-usb-ohci kmod-usb2
endef
LEGACY_DEVICES += PB42

define LegacyDevice/PB44
  DEVICE_TITLE := Atheros PB44 reference board
  DEVICE_PACKAGES := kmod-usb-core kmod-usb-ohci kmod-usb2 \
	  vsc7385-ucode-pb44 vsc7395-ucode-pb44
endef
LEGACY_DEVICES += PB44

define LegacyDevice/MZKW04NU
  DEVICE_TITLE := Planex MZK-W04NU
  DEVICE_PACKAGES := kmod-usb-core kmod-usb2 kmod-usb-ledtrig-usbport
endef
LEGACY_DEVICES += MZKW04NU

define LegacyDevice/WRT400N
  DEVICE_TITLE := Linksys WRT400N
endef
LEGACY_DEVICES += WRT400N

define LegacyDevice/WZRHPG300NH
  DEVICE_TITLE := Buffalo WZR-HP-G300NH
  DEVICE_PACKAGES := kmod-usb-core kmod-usb2 kmod-usb-ledtrig-usbport
endef
LEGACY_DEVICES += WZRHPG300NH

define LegacyDevice/WZRHPG300NH2
  DEVICE_TITLE := Buffalo WZR-HP-G300NH2
  DEVICE_PACKAGES := kmod-usb-core kmod-usb2 kmod-usb-ledtrig-usbport
endef
LEGACY_DEVICES += WZRHPG300NH2

define LegacyDevice/WZRHPAG300H
  DEVICE_TITLE := Buffalo WZR-HP-AG300H
  DEVICE_PACKAGES := kmod-usb-ohci kmod-usb-core kmod-usb2 kmod-usb-ledtrig-usbport
endef
LEGACY_DEVICES += WZRHPAG300H

define LegacyDevice/WZRHPG450H
  DEVICE_TITLE := Buffalo WZR-HP-G450H
  DEVICE_PACKAGES := kmod-usb-core kmod-usb2 kmod-usb-ledtrig-usbport
endef
LEGACY_DEVICES += WZRHPG450H

define LegacyDevice/WZR600DHP
  DEVICE_TITLE := Buffalo WZR-600DHP
  DEVICE_PACKAGES := kmod-usb-core kmod-usb2 kmod-usb-ledtrig-usbport
endef
LEGACY_DEVICES += WZR600DHP

define LegacyDevice/WZR450HP2
  DEVICE_TITLE := Buffalo WZR-450HP2
  DEVICE_PACKAGES := kmod-usb-core kmod-usb2 kmod-usb-ledtrig-usbport
endef
LEGACY_DEVICES += WZR450HP2
