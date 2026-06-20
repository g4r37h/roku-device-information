# Platform detection and base config
HOST_OS ?= $(shell uname -s | tr A-Z a-z)
ABSOLUTE_ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# Directory structure
BUILD_DIR := $(ABSOLUTE_ROOT_DIR)/build
DIST_DIR := $(ABSOLUTE_ROOT_DIR)/dist
ARCHIVE_DIR := $(DIST_DIR)/apps
PACKAGE_DIR := $(DIST_DIR)/packages

# Build artifacts
ARCHIVE_FILE := $(ARCHIVE_DIR)/$(APP_PACKAGE_NAME)$(if $(BUILD_VERSION),-$(BUILD_VERSION),)$(if $(BUILD_REPO_HASH),_$(BUILD_REPO_HASH),).zip
PACKAGE_FILE := $(PACKAGE_DIR)/$(APP_PACKAGE_NAME)-$(BUILD_VERSION).pkg

# Development settings
DEV_SERVER_TMP := /tmp/dev_server_out
USERPASS := rokudev$(if $(DEV_PASSWORD),:$(DEV_PASSWORD),)

# Platform-specific settings
include $(ABSOLUTE_ROOT_DIR)/make/platform_$(HOST_OS).mk

# Utility functions
define check_roku_device
	@if [ -z "$(DEV_TARGET)" ]; then echo "ERROR: DEV_TARGET not set"; exit 1; fi
	@echo "Checking $(DEV_TARGET)..."
	@ping $(PING_ARGS) $(DEV_TARGET) >/dev/null || (echo "ERROR: Device not responding"; exit 1)
	@curl -sf http://$(DEV_TARGET):8060 >/dev/null || (echo "ERROR: Not a Roku device"; exit 1)
	@curl -sf --user $(USERPASS) --digest http://$(DEV_TARGET) >/dev/null || (echo "ERROR: Developer mode not enabled or wrong password"; exit 1)
endef

define build_app
	@echo "Building $(APP_PACKAGE_NAME)..."
	@mkdir -p $(BUILD_DIR)
	@cp $(ABSOLUTE_ROOT_DIR)/manifest $(BUILD_DIR)/
	@sed -i '' 's/^bs_const=.*/bs_const='"$(BUILD_CONDITIONAL_COMPILATION_FLAGS)"'/' "$(BUILD_DIR)/manifest"
	@mv ./manifest manifest.orig
	@mv $(BUILD_DIR)/manifest ./manifest
	@trap 'mv manifest.orig manifest' EXIT; \
	npm run build:transpileBrighterscript$(1)
	@./scripts/vscode/_setManifest.sh
	@if [ "$(USE_PRODUCTION_VARS)" = "true" ]; then \
		rm -rf $(BUILD_DIR)/components/bs-render-thread-app-components/debug; \
	fi
	@find $(BUILD_DIR) -name "*.md" -delete
	@find $(BUILD_DIR) -name "*.map" -delete
	@cd $(BUILD_DIR) && zip -0rq "$(ARCHIVE_FILE)" . -i "*.png" $(ZIP_EXCLUDE)
	@cd $(BUILD_DIR) && zip -9rq "$(ARCHIVE_FILE)" . -x "*~" -x "*.png" -x "makefile" $(ZIP_EXCLUDE)
endef

# Clean targets
.PHONY: clean build-clean dist-clean
clean: build-clean dist-clean
build-clean:
	rm -rf $(BUILD_DIR)
dist-clean:
	rm -rf $(DIST_DIR)

# Build targets
.PHONY: build build-test
build: build-clean
	@mkdir -p $(ARCHIVE_DIR)
	@chmod 755 $(ARCHIVE_DIR)
	$(call build_app,)
	@echo "Build complete"

.PHONY: build-dev
build-dev: build-clean
	$(call build_app_dev,)
	@echo "Dev build complete"

.PHONY: build-dev-zip
build-dev-zip: build-clean
	@mkdir -p $(ARCHIVE_DIR)
	@chmod 755 $(ARCHIVE_DIR)
	$(call build_app_dev,)
	@cd $(BUILD_DIR) && zip -0rq "$(ARCHIVE_FILE)" . -i "*.png" $(ZIP_EXCLUDE)
	@cd $(BUILD_DIR) && zip -9rq "$(ARCHIVE_FILE)" . -x "*~" -x "*.png" -x "makefile" $(ZIP_EXCLUDE)
	@echo "Dev build complete"

define build_app_dev
	@echo "Building $(APP_PACKAGE_NAME) (dev)..."
	@mkdir -p $(BUILD_DIR)
	@cp $(ABSOLUTE_ROOT_DIR)/manifest $(BUILD_DIR)/
	@sed -i '' 's/^bs_const=.*/bs_const='"$(BUILD_CONDITIONAL_COMPILATION_FLAGS)"'/' "$(BUILD_DIR)/manifest"
	@mv ./manifest manifest.orig
	@mv $(BUILD_DIR)/manifest ./manifest
	@trap 'mv manifest.orig manifest' EXIT; \
	npm run build:transpileBrighterscript$(1)
	@./scripts/vscode/_setManifest.sh
	@find $(BUILD_DIR) -name "*.md" -delete
endef

build-test: build-clean
	@mkdir -p $(ARCHIVE_DIR)
	@chmod 755 $(ARCHIVE_DIR)
	$(call build_app, -- bsconfig.rooibos.json)
	@echo "Test build complete"

.PHONY: check-roku-device
check-roku-device:
	$(call check_roku_device)

# Deployment targets
.PHONY: install install-to-device install-tests remove run
install: build install-to-device

install-to-device: check-roku-device
	@echo "Installing $(APP_PACKAGE_NAME)..."
	@curl --user $(USERPASS) --digest -F "mysubmit=Install" -F "archive=@$(ARCHIVE_FILE)" \
		http://$(DEV_TARGET)/plugin_install | grep -q "Success" || \
		(echo "Install failed"; exit 1)
	@echo "Install complete"

install-tests: build-test install-to-device

remove: check-roku-device
	@echo "Removing dev app..."
	@curl --user $(USERPASS) --digest -F "mysubmit=Delete" -F "archive=" \
		http://$(DEV_TARGET)/plugin_install | grep -q "Success" || \
		(echo "Remove failed"; exit 1)
	@echo "Remove complete"

run: remove install

# Package targets
.PHONY: package rekey package_and_rekey
package: install
	@mkdir -p $(PACKAGE_DIR)
	@./package_scripts/package.sh $(DEV_TARGET) $(DEV_PASSWORD) $(APP_KEY_PASS) $(BUILD_VERSION) $(PACKAGE_FILE)
	@curl -d "" "http://$(DEV_TARGET):8060/keypress/home"

rekey:
	@./package_scripts/rekey.sh $(DEV_TARGET) $(DEV_PASSWORD) $(APP_KEY_PASS) $(ABSOLUTE_ROOT_DIR)/$(APP_KEY_FILE)

package_and_rekey: install rekey package

# OS-specific settings (replace the make/platform_*.mk targets at the bottom)
ifeq ($(HOST_OS),linux)
PING_ARGS := -c 1
CP_ARGS := --preserve=ownership,timestamps --no-preserve=mode
endif

ifeq ($(HOST_OS),darwin)
PING_ARGS := -c 1
CP_ARGS :=
endif

ifeq ($(HOST_OS),cygwin)
PING_ARGS := -n 1
CP_ARGS := --preserve=ownership,timestamps --no-preserve=mode
endif
