#
# Copyright (C) 2019 PandoraBox Team
#

SUBTARGET:=generic
BOARDNAME:=QCA MIPS 24kc SoC

FEATURES+= 

CPU_TYPE:=24kc

# CFLAGS:=-Os -pipe -mips32r2 -mtune=24kec -mdsp -mabi=32 -funit-at-a-time -fno-caller-saves

DEFAULT_PACKAGES += 
		    
define Target/Description
	Build firmware images for QCA MIPS 24kc SoC.
endef

