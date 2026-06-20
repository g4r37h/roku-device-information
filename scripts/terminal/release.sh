#!/bin/bash

source .env

set -e

# Environments
PROD_ENVIRONMENT=prod
STAGING_ENVIRONMENT=stage

# ──────────────────────────────────────────────────────────────────────────────

# Constants
TAG_PATTERN="release/*.*.*"

# Get version tags
LATEST_TAG=$(git describe --tags --match="$TAG_PATTERN" --abbrev=0)
CURRENT_TAG=$(git describe --tags --match="$TAG_PATTERN")
LATEST_VERSION="${LATEST_TAG#release/}"
CURRENT_VERSION="${CURRENT_TAG#release/}"

# Validation
if [ -z "$CURRENT_VERSION" ] || [ -z "$LATEST_VERSION" ]; then
    echo "Error: No release tag ($TAG_PATTERN) found. Please checkout a release tag."
    exit 1
fi

if [ "$LATEST_VERSION" != "$CURRENT_VERSION" ]; then
    echo "Error: Current branch ($CURRENT_VERSION) is not the latest tag ($LATEST_VERSION)"
    exit 1
fi

# Get the current commit hash
BUILD_REPO_HASH=$(git rev-parse --short HEAD)

# Get changelog
PREVIOUS_TAG=$(git describe --tags --match="$TAG_PATTERN" --abbrev=0 "${LATEST_TAG}^")
APP_LOG=$(git log --pretty=format:"%s" "${PREVIOUS_TAG}..HEAD" -- .)

# Set version variables
IFS='.' read -r BUILD_VERSION_MAJOR BUILD_VERSION_MINOR BUILD_VERSION_BUILD <<< "$CURRENT_VERSION"

export BUILD_VERSION_MAJOR BUILD_VERSION_MINOR BUILD_VERSION_BUILD BUILD_REPO_HASH

# Cleanup
find . \( -name "._*" -o -name ".DS_Store" -o -name "Thumbs.db" -o -name "desktop.ini" \) -delete
find . -name "__MACOSX" -exec rm -rf {} +
git restore .
git clean -df
make clean

# Install dependencies
npm install

# Load configs
source .buildConfig
[ -f .env ] && source .env

# Apply argument overrides
[ -n "$1" ] && DEVELOPMENT_ROKU_IP_1="$1"
[ -n "$2" ] && DEVELOPMENT_ROKU_PASSWORD="$2"

# ── Build helper ───────────────────────────────────────────────────────────────

_build_dev_public() {
    local env=$1
    make \
        USE_PRODUCTION_VARS=false \
        BUILD_ACCOUNT_PASSWORD= \
        BUILD_ACCOUNT_USERNAME= \
        BUILD_ENVIRONMENT=$env \
        DEVELOPMENT_ROKU_IP_1="$DEVELOPMENT_ROKU_IP_1" \
        DEVELOPMENT_ROKU_PASSWORD="$DEVELOPMENT_ROKU_PASSWORD" \
        APP_PACKAGE_NAME="${BUILD_APP_FILE_NAME}_DEBUG_PUBLIC_${env}" \
        package_and_rekey
}

# ── Build 1: Production release ───────────────────────────────────────────────

make \
    USE_PRODUCTION_VARS=true \
    BUILD_ACCOUNT_PASSWORD= \
    BUILD_ACCOUNT_USERNAME= \
    BUILD_ENVIRONMENT=$PROD_ENVIRONMENT \
    DEVELOPMENT_ROKU_IP_1="$DEVELOPMENT_ROKU_IP_1" \
    DEVELOPMENT_ROKU_PASSWORD="$DEVELOPMENT_ROKU_PASSWORD" \
    APP_PACKAGE_NAME="${BUILD_APP_FILE_NAME}_RELEASE" \
    package_and_rekey

# ── Build 2: Dev public — production environment ──────────────────────────────

_build_dev_public $PROD_ENVIRONMENT

# ── Build 3: Dev public — staging environment ─────────────────────────────────

_build_dev_public $STAGING_ENVIRONMENT

# ── Changelog ─────────────────────────────────────────────────────────────────

cat > dist/changelog.txt << EOL
============================================================
Changelog v${CURRENT_VERSION}
============================================================

${APP_LOG}
EOL
