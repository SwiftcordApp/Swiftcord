#!/bin/bash

set -o errexit
set -o nounset

export PATH=${PATH}:/usr/local/bin
export LC_ALL="en_US.UTF-8"

BUILD_SETTINGS_SWIFT_SOURCE_PATH="${BUILD_SETTINGS_SWIFT_SOURCE_PATH?error: Build settings Swift output path is not available via the 'BUILD_SETTINGS_SWIFT_SOURCE_PATH' environment variable}"

echo "Writing build settings to ${BUILD_SETTINGS_SWIFT_SOURCE_PATH}"

# Write the file contents out - if you want to export more build settings, this is the place to do it.
cat >"${BUILD_SETTINGS_SWIFT_SOURCE_PATH}" <<EOS
//  #### YOUR CHANGES WILL BE OVERWRITTEN! ####
//
//  Please do not make changes to this file - it is updated during and ignored by source control as a result of the build process.

enum BuildSettings {
    static let appcenterAppSecret = "${APPCENTER_APP_SECRET:-}"
}
EOS
