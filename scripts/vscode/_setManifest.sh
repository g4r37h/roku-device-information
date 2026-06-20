#!/bin/bash

set -e

source .buildConfig
[ -f .env ] && source .env

# Set sed arguments based on OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    SED_ARGS=("-i" "")
else
    SED_ARGS="-i"
fi

# Optionally update manifest debug values
if [ "${USE_PRODUCTION_VARS}" != "true" ]; then
    sed "${SED_ARGS[@]}" \
        -e "s/^ads_logging_enabled=.*/ads_logging_enabled=${BUILD_ADS_LOGGING_ENABLED}/g" \
        -e "s/^ads_test_mode_enabled=.*/ads_test_mode_enabled=${BUILD_ADS_TEST}/g" \
        -e "s/^analytics_logging_enabled=.*/analytics_logging_enabled=${BUILD_ANALYTICS_LOGGING_ENABLED}/g" \
        -e "s/^app_debug_banner_enabled=.*/app_debug_banner_enabled=${BUILD_APP_DEBUG_BANNER_ENABLED}/g" \
        -e "s/^app_logging_enabled=.*/app_logging_enabled=${BUILD_APP_LOGGING_ENABLED}/g" \
        -e "s/^app_logging_overlay_startup_enabled=.*/app_logging_overlay_startup_enabled=${BUILD_APP_LOGGING_OVERLAY_STARTUP_ENABLED}/g" \
        -e "s/^network_logging_enabled=.*/network_logging_enabled=${BUILD_NETWORK_LOGGING_ENABLED}/g" \
        -e "s/^override_is_low_memory_hardware=.*/override_is_low_memory_hardware=${BUILD_OVERRIDE_IS_LOW_MEMORY_HARDWARE}/g" \
        -e "s/^override_locale=.*/override_locale=${BUILD_OVERRIDE_LOCALE}/g" \
        -e "s/^override_supports_opengl=.*/override_supports_opengl=${BUILD_OVERRIDE_SUPPORTS_OPENGL}/g" \
        -e "s/^proxy_ip=.*/proxy_ip=${BUILD_PROXY_IP}/g" \
        -e "s/^proxy_port=.*/proxy_port=${BUILD_PROXY_PORT}/g" \
        -e "s/^rale_enabled=.*/rale_enabled=${BUILD_RALE_ENABLED}/g" \
    ./build/manifest

    # Optionally update manifest private debug values
    if [ "${USE_PRIVATE_VARS}" = "true" ]; then
        sed "${SED_ARGS[@]}" \
            -e "s/^debug_account_password=.*/debug_account_password=${BUILD_ACCOUNT_PASSWORD}/g" \
            -e "s/^debug_account_username=.*/debug_account_username=${BUILD_ACCOUNT_USERNAME}/g" \
        ./build/manifest
    fi
fi

# Update manifest public values
sed "${SED_ARGS[@]}" \
   -e "s/^ads_enabled=.*/ads_enabled=${BUILD_ADS_ENABLED}/g" \
   -e "s/^analytics_enabled=.*/analytics_enabled=${BUILD_ANALYTICS_ENABLED}/g" \
   -e "s/^analytics_ga4_measurement_id=.*/analytics_ga4_measurement_id=${BUILD_ANALYTICS_GA4_MEASUREMENT_ID}/g" \
   -e "s|^analytics_rudderstack_data_plane_url=.*|analytics_rudderstack_data_plane_url=${BUILD_ANALYTICS_RUDDERSTACK_DATA_PLANE_URL}|g" \
   -e "s/^analytics_rudderstack_write_key=.*/analytics_rudderstack_write_key=${BUILD_ANALYTICS_RUDDERSTACK_WRITE_KEY}/g" \
   -e "s|^analytics_sentry_dsn=.*|analytics_sentry_dsn=${BUILD_ANALYTICS_SENTRY_DSN}|g" \
   -e "s/^bs_const=.*/bs_const=${BUILD_CONDITIONAL_COMPILATION_FLAGS}/g" \
   -e "s/^environment=.*/environment=${BUILD_ENVIRONMENT}/g" \
   -e "s/^title=.*/title=${BUILD_APP_NAME}/g" \
   -e "s/^major_version=.*/major_version=${BUILD_VERSION_MAJOR}/g" \
   -e "s/^minor_version=.*/minor_version=${BUILD_VERSION_MINOR}/g" \
   -e "s/^build_version=.*/build_version=${BUILD_VERSION_BUILD}/g" \
   -e "s/^build_repo_hash=.*/build_repo_hash=${BUILD_REPO_HASH}/g" \
   ./build/manifest
