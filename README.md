<p align="center"><image src="Swiftcord/Assets.xcassets/AppIcon.appiconset/Picture 1.png" width="196px" height="196px" /></p>

<h1 align="center">Swiftcord</h1>
<p align="center">A completely native Discord client for macOS built 100% in Swift and SwiftUI</p>

<image src="README_Resources/heroScreenshot.png" width="100%" alt="Viewing the general-talk channel in the r/MacBookPro server in Swiftcord" />

[![Lines of code](https://img.shields.io/tokei/lines/github/SwiftcordApp/Swiftcord?style=for-the-badge)]()
[![Discord](https://img.shields.io/discord/964741354112577557?color=rgb%2888%2C101%2C242%29&label=discord&style=for-the-badge)](https://discord.gg/he7n6MGDXS)
[![GitHub Repo stars](https://img.shields.io/github/stars/cryptoAlgorithm/Swiftcord?color=%23FECF0F&style=for-the-badge)](https://github.com/SwiftcordApp/Swiftcord/stargazers)
[![GitHub Sponsors](https://img.shields.io/github/sponsors/cryptoAlgorithm?label=Sponsor%20Me!&logo=buymeacoffee&style=for-the-badge)](https://github.com/sponsors/cryptoAlgorithm)
[![Patreon](https://img.shields.io/endpoint.svg?url=https%3A%2F%2Fshieldsio-patreon.vercel.app%2Fapi%3Fusername%3Dcryptoalgo%26type%3Dpatrons&style=for-the-badge)](https://www.patreon.com/cryptoAlgo)
[![Weblate project translated](https://img.shields.io/weblate/progress/swiftcord?style=for-the-badge)](https://hosted.weblate.org/projects/swiftcord/swiftcord/)

---

This project aims to create a fully functional native Discord
client in Swift for macOS from scratch.

I'd also recommend checking out [DiscordKit](https://github.com/SwiftcordApp/DiscordKit),
the Discord API implementation Swiftcord relies on.

**If you like this project, please smash the star button and be one of my stargazers 🌟! It helps motivate
me to continue developing it**

**Consider supporting me and Swiftcord's development by sponsoring me through [GitHub Sponsors](https://github.com/sponsors/cryptoAlgorithm) or [Patreon](https://patreon.com/cryptoAlgo)! It would help ensuring this project has a stable future :)**

## Supporters
Huge thanks to all my supporters! I'm extremely grateful to every single one of them <3
### Red-hot Supporter 🔥
It'll be mind-blowing to get red-hot supporters! Be my first red-hot supporter, and get special privileges that only you'll ever have!
### Amazing Supporter 🤯
Be my first amazing supporter! Support me on [GitHub Sponsors](https://github.com/sponsors/cryptoAlgorithm) or [Patreon](https://patreon.com/cryptoAlgo)!
### Extremely Cool Supporter 🧊
* `selimgr`
* An extremely generous anonymous supporter

## Contents
* [Motivation](#motivation)
* [Releases](#releases)
* [FAQ](#faq)
* [Current State](#current-state)
* [Copyright Notice](#copyright-notice)

---

## Motivation

Swiftcord was created to offer a Discord-like UI and experience while
having the performance and memory benefits of native apps. The idea started
brewing when I was tight on RAM, then noticed Discord using 600+MB of RAM.
I then realized that was the perfect opportunity to explore SwiftUI,
since it was relatively new to me at that time. Hence, Swiftcord was born!

---

## Releases

### Nightly Builds (Latest fixes/features, might be unstable)
[![GitHub Workflow Status](https://img.shields.io/github/workflow/status/SwiftcordApp/Swiftcord/Build%20Canary?style=for-the-badge)](https://nightly.link/SwiftcordApp/Swiftcord/workflows/main/main/Swiftcord_Canary.zip)

For the latest features and fixes, [a pre-built version of the latest commit is available here](https://nightly.link/SwiftcordApp/Swiftcord/workflows/main/main/Swiftcord_Canary.zip)

### Alpha (More stable, less updated)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/cryptoAlgorithm/Swiftcord?style=for-the-badge)](https://github.com/cryptoAlgorithm/Swiftcord/releases/)

Alpha releases are available at [GitHub Releases](https://github.com/cryptoAlgorithm/Swiftcord/releases/)

### Homebrew
[![homebrew cask](https://img.shields.io/homebrew/cask/v/swiftcord?style=for-the-badge)](https://formulae.brew.sh/cask/swiftcord)

Swiftcord is also available on homebrew as a cask: `brew install swiftcord`. Versions are
lock stepped with alpha releases on GitHub releases.

### TestFlight

Coming soon!

<!-- todo: Add building from source -->

### Requirements
* OS: macOS Monterey and above (>= 12.0)
* Arch: Apple Silicon or Intel (Most releases are universal bundles) 

> Note: Note: To open Swiftcord, you may need to right-click on the icon > press open. 
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
  trip selfbot ban detection, and Discord won't change their mind to officially ban
  3rd-party clients. As far as possible, Swiftcord aims to
  use endpoints as similarly to the official client as possible, and I (the developer)
  have not been banned for using Swiftcord with either my main or alt account.
  <i>
    I do not take any responsibility for account bans due to the use of Swiftcord,
    whether direct or indirect, although there's a very low possibility of that occurring. 
    I recommend trying Swiftcord with an alt if possible.
  </i>
</details>
<details>
  <summary><b>Feature <i>x</i> is missing! When will <i>y</i> be implemented?</b></summary>
  Swiftcord currently is in the alpha stage, and hasn't achieved feature
  parity with the official Discord client yet (it's quite far behind). 
  Many features are on the <a href="#roadmap">roadmap</a>, but I do not
  currently have a timeline for them. Development is progressing at a 
  fast pace, but sometimes bugs may take an unexpectedly long time to fix.
  I appreciate contributions, bug reports, and suggestions :)
</details>
<details>
  <summary><b>Swiftcord just crashed!</b></summary>
  Although I'm aiming for 0 crashes (which is made easy by Swift),
  sometimes the unexpected happens xD. If you experience a crash, please
  open an issue with appropriate information like the line the error
  occurs on, relevant logs, and what you were doing that might have caused
  the crash. If you can solve the bug causing the crash, that's even better!
</details>

---

## Current State

Implemented most core message-related features from the official
client, including basic markdown and embeds, stickers (lottie/PNG),
and editing and deleting events. Animated media, like profile images, server icons
and profile banners are supported too! You can now send attachments (both
from the file picker and by dragging and dropping) with your messages too! 
DMs now have first-class support!

More advanced features like voice channels & editing messages etc 
aren't supported yet, refer to the [roadmap](#roadmap) below.

Gateway connection event handling is stable, and reconnection
is rock solid (as far as I can test). If you encounter a reconnection
bug (not reconnecting, reconnection loop, etc), please open an issue
with the relevant logs.

---

## Copyright Notice

Copyright (c) 2022 Vincent Kwok

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

The above copyright notice, this permission notice, and its license shall be included in all copies or substantial portions of the Software.

You can find a copy of the GNU General Public License v3 in LICENSE or https://www.gnu.org/licenses/.

I ❤️ Open Source
