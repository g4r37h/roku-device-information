include .buildConfig
-include .env

DEV_TARGET := $(DEVELOPMENT_ROKU_IP_1)
DEV_PASSWORD := $(DEVELOPMENT_ROKU_PASSWORD)

BUILD_APP_NAME ?= ANONYMOUS
BUILD_APP_FILE_NAME ?= ANONYMOUS

# Set defaults FIRST, before including environment files
BUILD_ENVIRONMENT ?= prod
BUILD_VERSION_MAJOR ?= 0
BUILD_VERSION_MINOR ?= 0
BUILD_VERSION_BUILD ?= 0
BUILD_REPO_HASH ?=

ifeq ($(USE_PRODUCTION_VARS),false)
    include make/environment_debug.mk
else
    include make/environment_release.mk
endif

BUILD_VERSION := $(BUILD_VERSION_MAJOR).$(BUILD_VERSION_MINOR).$(BUILD_VERSION_BUILD)

# Export build variables
$(foreach var,$(BUILD_VARS),$(eval export $(var)))

# Export additional variables not in BUILD_VARS
export BUILD_REPO_HASH
export BUILD_ENVIRONMENT
export USE_PRODUCTION_VARS
export USE_PRIVATE_VARS

# Package configuration
ZIP_EXCLUDE := -x \*\_test\*
APP_KEY_PASS := My//eJuFr3XKEg4fGpfOOg==
APP_KEY_FILE := "package_scripts/rekey.pkg"

include ./app.mk
