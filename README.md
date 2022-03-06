# Swiftcord

> A completely native Discord client for macOS built 100% in
> Swift and SwiftUI

This project aims to create a fully functional native Discord
client in Swift for macOS from scratch. Look below for a bunch
of screenshots!

## Client Feature Parity

Feature parity with the following Discord client is targeted:

| Version         | `0.0.283`|
| --------------- | -------- |
| Build #         | `115689` |
| Release Channel | `canary` |

## Current State

Implemented most core message-related features from the official
client, including basic markdown and embeds, stickers (lottie/PNG),
editing and deleting events. Token retrival from Discord login 
page is reliable and storing + retrival from keychain works.

Gateway connection and event handling is stable, but reconnection
is not. Reconnection/resuming might not be successful when internet
connection is unstable or macOS has been sleeping for a very long time.

## Milestones/Roadmap

- [x] Gateway/REST API Implementation
- [x] Load server list, channels and message
- [x] Basic message, channel and server rendering
- [x] Rich message rendering (stickers, embeds, markdown, media)
- [x] Message replies
- [x] Load and display full user profile (bio + roles)
- [x] Save last server and last channel viewed in servers (QoL)
- [x] Better loading screen
- [x] Find and request most optimised photo size from CDN
- [ ] Partial user and app settings
- [ ] DM loading and groups support
- [ ] User roles + overwrites
- [ ] Message notifications
- [ ] Full list of users in a server, especially for larger servers (1000+ members)
- [ ] Ordering of channels, servers and categories
- [ ] Threads support
- [ ] Full user settings
- [ ] Server creation
- [ ] Server discovery
- [ ] Server banner, boost widget and other misc. boosted features
- [ ] Voice channels (ambitious)
- [ ] Video channels (very ambitious)

## Screenshots

![General messages and replies in a channel](README_Resources/generalMessages.png)
![Rich embeds and webhook messages](README_Resources/webhookEmbeds.png)
![Welcome messages with stickers](README_Resources/stickers.png)
![A user's profile](README_Resources/userProfile.png)
![Loading screen](README_Resources/loadingChannels.png)
<video src="README_Resources/loginFlow.mov" alt="Login flow"></video>

## Contributions

Thank you for popping by! If you know the Discord API well, 
have Swift knowledge and feel like contributing, feel free to
make a pull request! Any (positive) contribution is welcome,
no matter how small!

## License

Made with ❤️ by Vincent Kwok

Copyright © 2022 Vincent Kwok

This program is free software: you can redistribute it and/or
modify it under the terms of the GNU General Public License as
published by the Free Software Foundation, either version 3 of
the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

See <https://www.gnu.org/licenses/> or LICENSE for a copy of
the GNU General Public License.
