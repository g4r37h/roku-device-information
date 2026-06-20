#!/bin/bash

source .env

set -e

# ── Build configuration ────────────────────────────────────────────────────────
# Edit this section to control what the QA builds contain.

# Environments
PROD_ENVIRONMENT=prod
STAGING_ENVIRONMENT=stage

# ──────────────────────────────────────────────────────────────────────────────

# Clean output directory if it exists
[ -d ./out ] && rm -r ./out

# Get the current commit hash
BUILD_REPO_HASH=$(git rev-parse --short HEAD)
export BUILD_REPO_HASH

# Install dependencies
npm install

# Load configs
source .buildConfig
[ -f .env ] && source .env

make clean

# ── Build helper ───────────────────────────────────────────────────────────────

_build_dev_public() {
    local env=$1
    local overlay=$2
    local extra_suffix=$3

    local suffix="${BUILD_APP_FILE_NAME}_DEV_PUBLIC_${env}"
    [ "$overlay" = "true" ] && suffix="${suffix}_OVERLAY"
    [ -n "$extra_suffix" ] && suffix="${suffix}_${extra_suffix}"

    make \
        USE_PRODUCTION_VARS=false \
        BUILD_APP_LOGGING_OVERLAY_STARTUP_ENABLED=$overlay \
        BUILD_ENVIRONMENT=$env \
        APP_PACKAGE_NAME="$suffix" \
        BUILD_VERSION= \
        build-dev-zip
}

_build_dev_http() {
    local env=$1
    local overlay=$2
    local config1="source/app/config/Configuration.bs"
    local config2="source/bs-core-source/config/Configuration.bs"

    cp "$config1" "${config1}.bak"
    cp "$config2" "${config2}.bak"
    trap "mv '${config1}.bak' '$config1'; mv '${config2}.bak' '$config2'" EXIT

    sed -i '' 's|https://|http://|g' "$config1"
    sed -i '' 's|https://|http://|g' "$config2"

    _build_dev_public $env $overlay HTTP

    mv "${config1}.bak" "$config1"
    mv "${config2}.bak" "$config2"
    trap - EXIT
}

# ── Build 1: Dev public — production environment ──────────────────────────────

_build_dev_public $PROD_ENVIRONMENT false

# ── Build 2: Dev public — staging environment ─────────────────────────────────

# _build_dev_public $STAGING_ENVIRONMENT false

# ── Build 3: Dev public — production environment, logging overlay ─────────────

_build_dev_public $PROD_ENVIRONMENT true

# ── Build 4: Dev public — staging environment, logging overlay ───────────────

# _build_dev_public $STAGING_ENVIRONMENT true

# ── Build 5: Dev public — production environment, http ───────────────────────

_build_dev_http $PROD_ENVIRONMENT false

# ── Build 6: Dev public — staging environment, http ──────────────────────────

# _build_dev_http $STAGING_ENVIRONMENT false

# ── Build 7: Dev public — production environment, logging overlay, http ───────

_build_dev_http $PROD_ENVIRONMENT true

# ── Build 8: Dev public — staging environment, logging overlay, http ──────────

# _build_dev_http $STAGING_ENVIRONMENT true
