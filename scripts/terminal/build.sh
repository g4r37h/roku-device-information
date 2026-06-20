#!/bin/bash
set -e

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

# Apply argument overrides
[ -n "$2" ] && DEVELOPMENT_ROKU_IP_1="$2"
[ -n "$3" ] && DEVELOPMENT_ROKU_PASSWORD="$3"

# Clean and install
make clean
env="${1:-prod}"

make \
    USE_PRODUCTION_VARS=false \
    BUILD_ENVIRONMENT="$env" \
    DEVELOPMENT_ROKU_IP_1="$DEVELOPMENT_ROKU_IP_1" \
    DEVELOPMENT_ROKU_PASSWORD="$DEVELOPMENT_ROKU_PASSWORD" \
    install
