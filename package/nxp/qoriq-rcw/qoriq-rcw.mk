################################################################################
#
# qoriq-rcw
#
################################################################################

QORIQ_RCW_VERSION = $(call qstrip,$(BR2_PACKAGE_HOST_QORIQ_RCW_VERSION))
QORIQ_RCW_SITE = https://github.com/nxp-qoriq/rcw
QORIQ_RCW_SITE_METHOD = git
QORIQ_RCW_LICENSE = BSD-3-Clause
QORIQ_RCW_LICENSE_FILES = LICENSE

RCW_FILES = $(call qstrip,$(BR2_PACKAGE_HOST_QORIQ_RCW_CUSTOM_PATH))

ifneq ($(RCW_FILES),)
RCW_INCLUDES = $(filter-out %.rcw,$(RCW_FILES))
# Get the name of the custom rcw file from the custom list
RCW_PROJECT = $(notdir $(filter %.rcw,$(RCW_FILES)))

# Error if there are no or more than one .rcw file
ifeq ($(BR_BUILDING),y)
ifneq ($(words $(RCW_PROJECT)),1)
$(error BR2_PACKAGE_HOST_QORIQ_RCW_CUSTOM_PATH must have exactly one .rcw file)
endif
endif

ifneq ($(RCW_INCLUDES),)
define HOST_QORIQ_RCW_ADD_CUSTOM_RCW_INCLUDES
	mkdir -p $(@D)/custom_board
	cp -f $(RCW_INCLUDES) $(@D)/custom_board
endef
HOST_QORIQ_RCW_POST_PATCH_HOOKS += HOST_QORIQ_RCW_ADD_CUSTOM_RCW_INCLUDES
endif

define HOST_QORIQ_RCW_ADD_CUSTOM_RCW_FILES
	mkdir -p $(@D)/custom_board/rcw
	cp -f $(filter %.rcw,$(RCW_FILES)) $(@D)/custom_board/rcw
endef
HOST_QORIQ_RCW_POST_PATCH_HOOKS += HOST_QORIQ_RCW_ADD_CUSTOM_RCW_FILES

define HOST_QORIQ_RCW_BUILD_CMDS
	python $(@D)/rcw.py -i $(@D)/custom_board/rcw/$(RCW_PROJECT) -I $(@D)/custom_board -o $(@D)/PBL.bin
endef

define HOST_QORIQ_RCW_INSTALL_DELIVERY_FILE
	$(INSTALL) -D -m 0644 $(@D)/PBL.bin $(BINARIES_DIR)/PBL.bin
endef
else
QORIQ_RCW_PATH_FILE_BIN = $(call qstrip,$(BR2_PACKAGE_HOST_QORIQ_RCW_BIN))

ifneq ($(QORIQ_RCW_PATH_FILE_BIN),)
QORIQ_RCW_PLATFORM = $(firstword $(subst /, ,$(QORIQ_RCW_PATH_FILE_BIN)))
QORIQ_RCW_FILE_BIN = $(lastword $(subst /, ,$(QORIQ_RCW_PATH_FILE_BIN)))

define HOST_QORIQ_RCW_BUILD_CMDS
	$(MAKE) -C $(@D)/$(QORIQ_RCW_PLATFORM)
endef

define HOST_QORIQ_RCW_INSTALL_DELIVERY_FILE
	$(INSTALL) -D -m 0644 $(@D)/$(QORIQ_RCW_PATH_FILE_BIN) $(BINARIES_DIR)/$(QORIQ_RCW_FILE_BIN)
endef
endif
endif

# Copy source files and script into $(HOST_DIR)/share/rcw/ so a developer
# could use a post image or SDK to build/install PBL files.
define HOST_QORIQ_RCW_INSTALL_CMDS
	mkdir -p  $(HOST_DIR)/share/rcw
	cp -a $(@D)/* $(HOST_DIR)/share/rcw
	$(HOST_QORIQ_RCW_INSTALL_DELIVERY_FILE)
endef

$(eval $(host-generic-package))
