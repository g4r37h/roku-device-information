#!/bin/bash
set -e

[ -d ./out ] && rm -r ./out

npm install

source .buildConfig
[ -f .env ] && source .env

[ -n "$1" ] && DEVELOPMENT_ROKU_IP_1="$1"
[ -n "$2" ] && DEVELOPMENT_ROKU_PASSWORD="$2"

# TDD BSConfig template e.g. bsconfig.rooibos.json
bsconfig_string='{
    "out": "out/roku-deploy.zip",
    "sourceMap": true,
    "stagingDir": "build",
    "retainStagingDir": true,
    "createPackage": false,
    "watch": false,
    "diagnosticFilters": [
        "components/bs-render-thread-app-components/debug/TrackerTask.xml"
    ],
    "files": [
        "./manifest",
        "components/**/*",
        "source/**/*",
        {
            "src": {TEST_PATHS_REPLACEMENT},
            "dest": "source/tests"
        },
        {
            "src": "tests/components/**/*",
            "dest": "components/tests"
        },
        "!assets/**/*",
        "!source/common/main.brs"
    ],
    "plugins": [
        "rooibos-roku"
    ],
    "rooibos": {
        "testSceneName": "TestAppScene",
        "keepAppOpen": false,
        "showFailuresOnly": true,
        "throwOnFailedAssertion": false,
        "catchCrashes": true,
        "allowNonExistingMethods": true,
        "isGlobalMethodMockingEnabled": true
    }
}'

# Run everything
all_tests_path_glob='tests/source/**/*'
bsconfig_string="${bsconfig_string//\{TEST_PATHS_REPLACEMENT\}/[\"$all_tests_path_glob\"]}"

# Generate the bsconfig.rooibos.json
echo "$bsconfig_string"> bsconfig.rooibos.json

make \
    USE_PRODUCTION_VARS=false \
    DEVELOPMENT_ROKU_IP_1="$DEVELOPMENT_ROKU_IP_1" \
    DEVELOPMENT_ROKU_PASSWORD="$DEVELOPMENT_ROKU_PASSWORD" \
    install-tests

tempOutputLog="./tests/.tempOutput.log"
if [ -f $tempOutputLog ]; then
    rm -f "$tempOutputLog"
fi

resultSuccess='RESULT:Success'
endReport='[ENDTESTREPORT]'
testSuccess=false
readingReport=true

while [ "$readingReport" = true ]; do
    sleep 5 | telnet "$DEVELOPMENT_ROKU_IP_1" 8085 | tee -a "$tempOutputLog"
    echo "Processing test results..."

    while IFS= read -r line
    do
        lineNoWhiteSpace="$(echo -e "${line}" | tr -d '[:space:]')"
        if [ "$lineNoWhiteSpace" == "$resultSuccess" ]; then
            testSuccess=true
        fi
        if [ "$lineNoWhiteSpace" == "$endReport" ]; then
            readingReport=false
        fi
    done < "$tempOutputLog"
done

rm -f "$tempOutputLog"

if [ "$testSuccess" = false ]; then
    echo "Tests Failed"
    exit -1
else
    echo "Tests Succeeded"
fi
