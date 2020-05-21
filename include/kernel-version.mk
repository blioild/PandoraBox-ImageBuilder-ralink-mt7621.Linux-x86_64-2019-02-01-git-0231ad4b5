# Use the default kernel version if the Makefile doesn't override it

LINUX_RELEASE?=1

LINUX_VERSION-3.4 = .110
LINUX_VERSION-3.10 = .102
LINUX_VERSION-3.14 = .79
LINUX_VERSION-3.18 = .43
LINUX_VERSION-4.1 = .34
LINUX_VERSION-4.4 = .120

LINUX_KERNEL_MD5SUM-3.4.110 = 07db4f7ac0eaf629c7415334780161ec
LINUX_KERNEL_MD5SUM-3.10.102 = 7bbfe07d69918f98136cef581e889778
LINUX_KERNEL_MD5SUM-3.14.79 = ec5b09d8ad2ebf92e6f51a727a338559
LINUX_KERNEL_MD5SUM-3.18.43 = b1faeb4a2e1e70ffe061bdbb3452840a
LINUX_KERNEL_MD5SUM-4.1.34 = fba99f0f4765ebf01033e69518740a3c
LINUX_KERNEL_MD5SUM-4.4.120 = 6150fbfcfedc10d786cd23f942ca4ef4

ifdef KERNEL_PATCHVER
  LINUX_VERSION:=$(KERNEL_PATCHVER)$(strip $(LINUX_VERSION-$(KERNEL_PATCHVER)))
endif

split_version=$(subst ., ,$(1))
merge_version=$(subst $(space),.,$(1))
KERNEL_BASE=$(firstword $(subst -, ,$(LINUX_VERSION)))
KERNEL=$(call merge_version,$(wordlist 1,2,$(call split_version,$(KERNEL_BASE))))
KERNEL_PATCHVER ?= $(KERNEL)

# disable the md5sum check for unknown kernel versions
LINUX_KERNEL_MD5SUM:=$(LINUX_KERNEL_MD5SUM-$(strip $(LINUX_VERSION)))
LINUX_KERNEL_MD5SUM?=x
