#!/bin/bash

# Install AppCenter-CLI
mkdir -p /Users/local/Homebrew/Cellar/node-16/16/
curl https://nodejs.org/download/release/latest-gallium/node-v16.15.1-darwin-x64.tar.xz --output node-16.tar.gz
tar -xf node-16.tar.gz -C /Users/local/Homebrew/Cellar/node-16/16/ --strip-components=1
/Users/local/Homebrew/Cellar/node-16/16/bin/npm install appcenter-cli

# Upload symbols to App Center
npm exec appcenter crashes upload-symbols \
    --token "$APPCENTER_API_TOKEN" \
    --app "Swiftcord/Swiftcord" \
    --xcarchive "$CI_ARCHIVE_PATH"