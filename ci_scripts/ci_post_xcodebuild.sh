#!/bin/bash

npm install appcenter-cli

# Upload symbols to App Center
npm exec -- appcenter crashes upload-symbols \
    --token "$APPCENTER_API_TOKEN" \
    --app "Swiftcord/Swiftcord" \
    --xcarchive "$CI_ARCHIVE_PATH"