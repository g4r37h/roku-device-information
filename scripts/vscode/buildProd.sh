#!/bin/bash

source .env
source .buildConfig

export USE_PRIVATE_VARS=false
export USE_PRODUCTION_VARS=true

if [ -d ./out ]; then
    rm -r ./out
fi

export BUILD_VERSION_MAJOR=${DEBUG_VERSION_MAJOR}
export BUILD_VERSION_MINOR=${DEBUG_VERSION_MINOR}
export BUILD_VERSION_BUILD=${DEBUG_VERSION_BUILD}
export BUILD_REPO_HASH=

make clean
make build
