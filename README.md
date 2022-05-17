<image src="Swiftcord/Assets.xcassets/AppIcon.appiconset/app-256.png" width="128px" height="128px" align="left" />

# Swiftcord
A completely native Discord client for macOS built 100% in Swift and SwiftUI

![Viewing the general-talk channel in the r/MacBookPro server in Swiftcord](README_Resources/heroScreenshot.png)

This project aims to create a fully functional native Discord
client in Swift for macOS from scratch. Look [below](#screenshots) for
a bunch of screenshots!

I'd also recommend checking out [DiscordKit](https://github.com/SwiftcordApp/DiscordKit),
the Discord API implementation Swiftcord relies on.

**If you like this project, please give it a ⭐ star! It helps motivate
me to continue developing it**

### Join the Swiftcord Discord server [here](https://discord.gg/he7n6MGDXS)!

## Contents
* [Motivation](#motivation)
* [Releases](#releases)
* [FAQ](#faq)
* [Current State](#current-state)
* [Roadmap](#roadmap)
* [Screenshots](#screenshots) (Might be outdated)
* [Contributions](#contributions) - Read this before contributing
* [Copyright Notice](#copyright-notice)

---

## Motivation

Swiftcord was created to offer a Discord-like UI and experience while
having the performance and memory benefits of native apps. The idea started
brewing when I was tight on RAM, then noticed Discord using 600+MB of RAM.
I then realised that that was the perfect opportunity to explore SwiftUI,
since it was relatively new to me at that time. Hence, Swiftcord was born!

---

## Releases
For the latest features and fixes, [a pre-built version of the latest commit is available here](https://nightly.link/SwiftcordApp/Swiftcord/workflows/main/main/Swiftcord_Canary.zip).

Alpha releases are available at [GitHub Releases](https://github.com/cryptoAlgorithm/Swiftcord/releases/).
However, it is recommended to download the nightly version or build Swiftcord from source 
for the latest features and fixes.

### Requirements
* OS: macOS Monterey and above (>= 12.0)
* Arch: Apple Silicon or Intel (Most releases are universal bundles)

> Note: Note: To open Swiftcord, you may need to right click on the icon > press open. 
> Some older releases were not signed or notarized with an Apple developer account.

---

## FAQ

Covers a few common questions I have encountered, click on the question
to expand the answer

<details>
  <summary><b>Will I get banned for using Swiftcord/Is using Swiftcord illegal?</b></summary>
  Using Swiftcord <i>isn't illegal</i>. Contrary to what many people say
  on various platforms, 3rd party clients (i.e. Swiftcord) <b>aren't against</b>
  the Discord ToS. You can read the section in Discord's ToS regarding their software
  <a href="https://discord.com/terms#software-in-discord’s-services">here</a>. 
  However, I <b>cannot guarantee</b> Swiftcord's use of Discord's endpoints won't
  trip selfbot ban detection. As far as possible, Swiftcord aims to
  use endpoints as similarly to the official client as possible, and I (the developer)
  have not been banned for using Swiftcord with either my main or alt account.
  <i>
    I do not take any responsibility for account bans due to the use of Swiftcord,
    whether direct or indirect, although there's a very low possibility of that occuring. 
    I recommend trying Swiftcord with an alt if possible.
  </i>
</details>
<details>
  <summary><b>Feature <i>x</i> is missing! When will <i>y</i> be implemented?</b></summary>
  Swiftcord currently is in the alpha stage, and hasn't achieved feature
  parity with the official Discord client yet (its quite far behind). 
  Many features are on the <a href="#roadmap">roadmap</a>, but I do not
  currently have a timeline for them. Development is progressing at a 
  fast pace, but sometimes bugs may take an unexpectedly long time to fix.
  I appreciate contributions, bug reports and suggestions :)
</details>
<details>
  <summary><b>Swiftcord just crashed!</b></summary>
  Although I'm aiming for 0 crashes (which is made easy by Swift),
  sometimes the unexpected happens xD. If you experience a crash, please
  open an issue with appropriete infomation like the line the error
  occurs on, relevent logs and what you were doing that might have casued
  the crash. If you can solve the bug causing the crash, that's even better!
</details>

---

## Current State

Implemented most core message-related features from the official
client, including basic markdown and embeds, stickers (lottie/PNG),
editing and deleting events. Token retrival from Discord login 
page is reliable and storing + retrival from keychain works. You can
now send attachments with your messages too! 

More advanced features like voice channels, DMs, editing messages etc 
aren't supported yet, refer to the [roadmap](#roadmap) below.

Gateway connection event handling is stable, and reconnection
is rock solid (as far as I can test). If you encounter a reconnection
bug (not reconnecting, reconnection loop etc), please open an issue
with the relevant logs.

---

## Roadmap

I do not have a definite timeline for when a feature would be implemented,
and they may not neccessarily be implemented in sequence. 

- ✅ Gateway/REST API Implementation
- ✅ Load server list, channels and message
- ✅ Basic message, channel and server rendering
- ✅ Rich message rendering (stickers, embeds, markdown, media)
- ✅ Message replies
- ✅ Load and display full user profile (bio + roles)
- ✅ Save last server and last channel viewed in servers (QoL)
- ✅ Better loading screen
- ✅ Find and request most optimised photo size from CDN
- ⏱ Partial user and app settings
- ✅ DM and group loading
- ⏱ Display DMs properly in UI
- ⏱ Send DM messages
- ✅ Send attachments
- ❌ User roles + overwrites
- ❌ Message notifications
- ❌ Full list of users in a server, especially for larger servers (1000+ members)
- ✅ Ordering of channels, servers and categories
- ❌ Threads support
- ❌ Full user settings
- ❌ Server creation
- ❌ Server discovery
- ❌ Server banner, boost widget and other misc. boosted features
- ❌ Voice channels (ambitious)
- ❌ Video channels (very ambitious)

#### Legend: 
* ✅ -> Complete
* ⏱ -> Implementation in progress
* ❌ -> Not started

---

## Screenshots

#### General messages with replies
![General messages and replies in a channel](README_Resources/generalMessages.png)

#### Rich embeds sent by a webhook
![Rich embeds and webhook messages](README_Resources/webhookEmbeds.png)

#### Channel with welcome message and animated stickers
![Welcome messages with stickers](README_Resources/stickers.png)

#### User profile popover
![A user's profile](README_Resources/userProfile.png)

#### Loading screen
![Loading screen](README_Resources/loadingChannels.png)

#### Login flow (video)
![Login flow](README_Resources/loginFlow.mp4)

---

## Contributions

Thank you for popping by! If you know the Discord API well, 
have Swift knowledge and feel like contributing, feel free to
make a pull request! Any (positive) contribution is welcome,
no matter how small! You can also join the Swiftcord Discord server
to discuss improvements and bugfixes!

Found an issue? Ensure it isn't a duplicate, then open a new issue
with the appropriate template and fill in the placeholders as
clearly as you can. Responding promptly to follow up comments
is appreciated, as debugging is hard without any further input
from the OP.

---

## Copyright Notice

Copyright (c) 2022 Vincent Kwok

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

The above copyright notice, this permission notice and its license shall be included in all copies or substantial portions of the Software.

You can find a copy of the GNU General Public License v3 in LICENSE, or https://www.gnu.org/licenses/.

I ❤️ Open Source
