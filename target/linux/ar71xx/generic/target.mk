#
# Copyright (C) 2019 PandoraBox Team
#

SUBTARGET:=generic
BOARDNAME:=QCA MIPS 74kc SoC

FEATURES+= nand ubifs rtc

CPU_TYPE:=74kc
CPU_SUBTYPE:=dsp2

DEFAULT_PACKAGES +=  
		    
define Target/Description
	Build firmware images for QCA MIPS 74kc SoC
endef

