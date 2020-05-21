#
# Copyright (C) 2006-2008 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/toolchain/go/go-static-values.mk
include $(TOPDIR)/toolchain/go/go-compile-flags.mk

# GO package installation path (GOPATH)
ifneq ($(call qstrip,$(CONFIG_GO_PACKAGES_GOPATH)),)
	go_gopath_packages:=$(CONFIG_GO_PACKAGES_GOPATH)
else
	go_gopath_packages:=/usr/lib/golang-packages
endif

# general settings
GO_PACKAGES_GOPATH:=$(go_gopath_packages)
GO_PACKAGES_ARCHITECTURE:=$(GO_GOOS)_$(GO_GOARCH)

# special default subdir used for pkg gopath
go_pkg_gopath_subdir:=PKG_GOPATH

# Compiler flags
ifneq ($(PKG_GO_DEBUG_SYM),)
  GO_GCFLAGS="-I '$(STAGING_DIR)$(GO_PACKAGES_GOPATH)/pkg/$(GO_PACKAGES_ARCHITECTURE)' -N -l"
else
  GO_GCFLAGS=-"I '$(STAGING_DIR)$(GO_PACKAGES_GOPATH)/pkg/$(GO_PACKAGES_ARCHITECTURE)'"
endif
# Linker flags
GO_LDFLAGS="-L '$(STAGING_DIR)$(GO_PACKAGES_GOPATH)/pkg/$(GO_PACKAGES_ARCHITECTURE)'"

# Support variables
go_pkg_lastword=$(lastword $(subst -, ,$(PKG_NAME)))
ifneq ($(PKG_GO_IMPORT_PATH),)
	go_pkg_import_path:=$(PKG_GO_IMPORT_PATH)
else
	go_pkg_import_path:=$(subst -,/,$(PKG_NAME:golang-%=%))
endif

ifdef PKG_GOPATH
  ifneq ($(call qstrip,$(PKG_GOPATH)),)
	go_pkg_GOpath:=$(PKG_GOPATH)
	go_pkg_host_GOpath:=$(PKG_GOPATH)
  else
	go_pkg_GOpath:=$(PKG_BUILD_DIR)
	go_pkg_host_GOpath:=$(HOST_BUILD_DIR)
  endif
else
	go_pkg_GOpath:=$(PKG_BUILD_DIR)/$(go_pkg_gopath_subdir)
	go_pkg_host_GOpath:=$(HOST_BUILD_DIR)/$(go_pkg_gopath_subdir)
endif

# default vaule for cross compile
ifneq ($(strip $(GO_GOARCH)),$(strip $(GOHOSTARCH)))
	go_pkg_cross_compile:=1
else
	go_pkg_cross_compile:=
endif

# default package installation paths
ifneq ($(strip $(go_pkg_cross_compile)),)
	go_pkg_bin_path:=bin/$(GO_GOOS)_$(GO_GOARCH)
	go_pkg_pkg_path:=pkg/$(GO_GOOS)_$(GO_GOARCH)
else
	go_pkg_bin_path:=bin
	go_pkg_pkg_path:=pkg
endif
go_pkg_src_path:=src

# override defaults for host
host host-%: override go_pkg_GOpath:=$(go_pkg_host_GOpath)
host host-%: override go_pkg_bin_path:=bin
host host-%: override go_pkg_pkg_path:=pkg
host host-%: override go_pkg_src_path:=src
host host-%: override go_pkg_cross_compile:=

# setup for install - default vaules
export GO_PKG_GOPATH=$$(go_pkg_GOpath)
export GO_PKG_BIN_PATH=$$(go_pkg_bin_path)
export GO_PKG_PKG_PATH=$$(go_pkg_pkg_path)
export GO_PKG_SRC_PATH=$$(go_pkg_src_path)
# cross compile flag
export GO_PKG_CROSS_COMPILE=$$(go_pkg_cross_compile)
# pkg build directory
export GO_PKG_BUILD_PATH=$(if $(filter host host-%,$(MAKECMDGOALS)),$(HOST_BUILD_DIR),$(PKG_BUILD_DIR))
# pkg compile directory
export GO_PKG_COMPILE_PATH=$(GO_PKG_GOPATH)/src/$(go_pkg_import_path)

# Exports for go compiling - defaults
export GOROOT=$(GOROOT_TOOLCHAIN_FINAL)
export GOARCH=$(if $(filter host host-%,$(MAKECMDGOALS)),$(GOHOSTARCH),$(GO_GOARCH))
export GOPATH=$(if $(filter host host-%,$(MAKECMDGOALS)),$(go_pkg_host_GOpath),$(go_pkg_GOpath))
export GOOS=$(GO_GOOS)
export GOMIPS=$(GO_GOMIPS)
export GOHOSTARCH=$(GO_GOHOSTARCH)

# helper 'function' if needed
#define create_additional_go_packages_paths
#	$(INSTALL_DIR) $(1)$(GO_PACKAGES_GOPATH)/bin
#	$(INSTALL_DIR) $(1)$(GO_PACKAGES_GOPATH)/pkg/$(GO_PACKAGES_ARCHITECTURE)
#	$(INSTALL_DIR) $(1)$(GO_PACKAGES_GOPATH)/src
#endef

# helper function - copy package contents in special directory "PKG_GOPATH"
# note: build dir for all packages if needed - host: BUILD_DIR_HOST / target: BUILD_DIR
# note 2: "copy_go_source_pkg_build_dir" could be replaced by e.g. global "GO_PKG_BUILD_DIR"
# => but we already have PKG_BUILD_DIR and HOST_BUILD_DIR 
define copy_go_source
	mkdir -p $(GO_PKG_COMPILE_PATH)
	# copy package contents in special "PKG_GOPATH" directory
	(for copy_content in $$(sort $$(shell find $(GO_PKG_BUILD_PATH) -maxdepth 1 \
		-not -path "*/$(go_pkg_gopath_subdir)*" \
		-and -not -path "*/$(PKG_NAME)-$(PKG_VERSION)" \
		-and -not -regex '.*/\.\(built.*\|prepared.*\|configured.*\|pkgdir\)' \
		-print)); do \
		( cp -ar $$$$copy_content $(GO_PKG_COMPILE_PATH)/); \
	done; )
endef

#define Build/GO/Prepare/Default
#	$(call Build/Prepare/Default)
#endef

define Build/GO/Compile/Default
	$(call copy_go_source)
	# Secondary expansion seems to be enabled, therefore four dollar signs = dollar,
	# otherwise two dollar signs = dollar
	for go_module in $(sort $(GO_PKG_MODULES)); do \
		( $(TARGET_GO) install -x -v -work -gcflags $(GO_GCFLAGS) -ldflags $(GO_LDFLAGS) $$$$go_module ); \
	done;
endef

# install binaries
define Build/GO/Install/Binary
	if [ -n "$(2)" ]; then \
		if [ "$(2)" != "none" ]; then \
			$(INSTALL_DIR) $(1)$(GO_PACKAGES_GOPATH)/bin; \
			for go_pkg_binary in $(sort $(2)); do \
				$(CP) $(GO_PKG_GOPATH)/$(GO_PKG_BIN_PATH)/$$$$go_pkg_binary \
					$(1)$(GO_PACKAGES_GOPATH)/bin/; \
				echo $$$$go_pkg_binary; \
			done; \
		fi; \
	elif [ -d "$(GO_PKG_GOPATH)/$(GO_PKG_BIN_PATH)" ] && \
		[ -n "$$$$(ls -A '$$(go_pkg_GOpath)/$$(go_pkg_bin_path)')" ]; then \
		echo "Install all binaries"; \
		$(INSTALL_DIR) $(1)$(GO_PACKAGES_GOPATH)/bin; \
		$(CP) $(GO_PKG_GOPATH)/$(GO_PKG_BIN_PATH)/* $(1)$(GO_PACKAGES_GOPATH)/bin/; \
	else \
		echo "No binary for installtion"; \
	fi;
endef

# install package "pkg's"
define Build/GO/Install/Pkg
	if [ -n "$(2)" ]; then \
		if [ "$(2)" != "none" ]; then \
			$(INSTALL_DIR) $(1)$(GO_PACKAGES_GOPATH)/$(GO_PKG_PKG_PATH); \
			for go_pkg_pkg in $(sort $(2)); do \
				$(CP) $(GO_PKG_GOPATH)/$(GO_PKG_PKG_PATH)/$$$$go_pkg_pkg \
					$(1)$(GO_PACKAGES_GOPATH)/$(GO_PKG_PKG_PATH)/; \
				echo $$$$go_pkg_pkg; \
			done; \
		fi; \
	elif [ -d "$(GO_PKG_GOPATH)/$(GO_PKG_PKG_PATH)" ] && \
		[ -n "$$$$(ls -A '$$(go_pkg_GOpath)/$$(go_pkg_pkg_path)')" ]; then \
		echo "Install all pkgs"; \
		$(INSTALL_DIR) $(1)$(GO_PACKAGES_GOPATH)/$(GO_PKG_PKG_PATH); \
		$(CP) $(GO_PKG_GOPATH)/$(GO_PKG_PKG_PATH)/* $(1)$(GO_PACKAGES_GOPATH)/$(GO_PKG_PKG_PATH)/; \
	else \
		echo "No pkg for installtion"; \
	fi;
endef

# install package sources
define Build/GO/Install/Source
	if [ -n "$(2)" ]; then \
		if [ "$(2)" != "none" ]; then \
			$(INSTALL_DIR) $(1)$(GO_PACKAGES_GOPATH)/$(GO_PKG_SRC_PATH); \
			for go_pkg_src in $(sort $(2)); do \
				$(CP) $(GO_PKG_GOPATH)/$(GO_PKG_SRC_PATH)/$$$$go_pkg_src \
					$(1)$(GO_PACKAGES_GOPATH)/$(GO_PKG_SRC_PATH)/; \
				echo $$$$go_pkg_src; \
			done; \
		fi; \
	elif [ -d "$(GO_PKG_GOPATH)/$(GO_PKG_SRC_PATH)" ] && \
		[ -n "$$$$(ls -A '$$(go_pkg_GOpath)/$$(go_pkg_src_path)')" ]; then \
		echo "Install all src"; \
		$(INSTALL_DIR) $(1)$(GO_PACKAGES_GOPATH)/$(GO_PKG_SRC_PATH); \
		$(CP) $(GO_PKG_GOPATH)/$(GO_PKG_SRC_PATH)/* $(1)$(GO_PACKAGES_GOPATH)/$(GO_PKG_SRC_PATH)/; \
	else \
		echo "No src for installtion"; \
	fi;
endef

# install package on host
define Build/GO/Host/Install/Default
	@echo "Build/GO/Host/Install/Default"
	@echo "-----------------------------"

	$(INSTALL_DIR) $(1)$(GO_PACKAGES_GOPATH)
	$(call Build/GO/Install/Binary,$(1),$(strip $(2)))
	$(call Build/GO/Install/Pkg,$(1),$(strip $(3)))
	$(call Build/GO/Install/Source,$(1),$(strip $(4)))
	ln -sf $(1)$(GO_PACKAGES_GOPATH)/bin/* $(1)/bin/
endef

# install package in staging
define Build/GO/InstallDev/Default
	@echo "Build/GO/InstallDev/Default"
	@echo "---------------------------"

	$(INSTALL_DIR) $(1)$(GO_PACKAGES_GOPATH)
	$(call Build/GO/Install/Binary,$(1),$(strip $(2)))
	$(call Build/GO/Install/Pkg,$(1),$(strip $(3)))
	$(call Build/GO/Install/Source,$(1),$(strip $(4)))
endef

# install package
define Package/GO/Install/Default
	@echo "Package/GO/Install/Default"
	@echo "--------------------------"

	$(INSTALL_DIR) $(1)$(GO_PACKAGES_GOPATH)
	$(call Build/GO/Install/Binary,$(1),$(strip $(2)))
	$(call Build/GO/Install/Pkg,$(1),$(strip $(3)))
	$(call Build/GO/Install/Source,$(1),$(strip $(4)))
endef

