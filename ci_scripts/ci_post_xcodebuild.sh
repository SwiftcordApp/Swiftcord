#!/bin/bash

# Upload symbols to App Center

appcenter crashes upload-symbols \
    --token $APPCENTER_API_TOKEN \
    --app "Swiftcord/Swiftcord" \
    --xcarchive "Swiftcord.xcarchive"