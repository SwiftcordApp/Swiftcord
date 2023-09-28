<p align=center><image src="https://raw.githubusercontent.com/SwiftcordApp/.github/main/res/swiftcord_new_icon.png" height="256" /></p>

<h1 align="center">Swiftcord</h1>

<p align="center">
  <a aria-label="Join the community on Discord" href="https://discord.gg/he7n6MGDXS" target="_blank">
    <img alt="" src="https://img.shields.io/discord/964741354112577557?style=for-the-badge&labelColor=black&label=Join%20Server&logo=Discord">
  </a>

  <!-- Self-hosted tokei_rs instance, only works for repos in the SwiftcordApp org -->
  <img alt="" src="http://vinkwok.mywire.org/tokei/github/SwiftcordApp/Swiftcord?style=for-the-badge&category=code">
  
  <a aria-label="Download" href="https://github.com/SwiftcordApp/Swiftcord/releases/latest">
    <img alt="" src="https://img.shields.io/github/v/release/cryptoAlgorithm/Swiftcord?style=for-the-badge&labelColor=black&color=eb563c&label=Download">
  </a>
</p>

<p align="center">Native Discord client for macOS built in Swift</p>

[![](https://github.com/SwiftcordApp/.github/blob/main/res/hero.webp?raw=true)](https://github.com/SwiftcordApp/.github/blob/main/res/swiftcord-promo.mov?raw=true)
###### This image doesn't animate properly in Safari, unfortunately. Click on it to view the original video.

[![Weblate project translated](https://img.shields.io/weblate/progress/swiftcord?style=for-the-badge)](https://hosted.weblate.org/projects/swiftcord/swiftcord/)

---

Swiftcord is beautiful, follows design principals of the official client while keeping the macOS look and feel that you love, and most importantly, its (really) fast!

Powered by [DiscordKit](https://github.com/SwiftcordApp/DiscordKit), a Swift Discord implementation built
from the ground up.

**If you like this project, please smash the star button and be one of my stargazers 🌟! It motivates
me to continue investing time into Swiftcord.**

## Supporters
Supporters get feature releases 2 weeks before they are made public! 

**Be a supporter to support me and this project's future! Perfect if you'd like to contribute but don't 
have the skills or time required! It's a great way of thanking me for my work. I'll be eternally grateful!**

[![GitHub Sponsors](https://img.shields.io/github/sponsors/cryptoAlgorithm?label=Sponsor%20Me!&logo=buymeacoffee&style=for-the-badge)](https://github.com/sponsors/cryptoAlgorithm)
[![Patreon](https://img.shields.io/endpoint.svg?url=https%3A%2F%2Fshieldsio-patreon.vercel.app%2Fapi%3Fusername%3Dcryptoalgo%26type%3Dpatrons&style=for-the-badge)](https://www.patreon.com/cryptoAlgo)

<!--<table>
  <tr>
    <td>
      <img src="" width=100 height=100/>
    </td>
    <td>
      <strong></strong>
      <br>
      <a href=""></a>
      <br><br>
      <i></i>
    </td>
  </tr>
</table>-->

<!--### Amazing Supporter 🤯-->
<!--<table>
  <tr>
    <td>
      <img src="" width=36 height=36/>
    </td>
    <td>
      <code><strong></strong></code> - First amazing supporter!
    </td>
  </tr>
</table>-->

<!--### Extremely Cool Supporter 🧊-->

## Contents
* [Motivation](#motivation)
* [Releases](#releases)
* [FAQ](#faq)
* [Roadmap](#roadmap)
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

You'll need **macOS Monterey and above (>= 12.0)** to run Swiftcord.
Releases from the channels below are universal bundles, and run natively on
both Apple Silicon and Intel.

### Nightly Builds (Latest fixes/features, built from the latest commit on `main`, might be unstable)
[![Download latest nightly build](https://img.shields.io/github/actions/workflow/status/SwiftcordApp/Swiftcord/build.yaml.svg?style=for-the-badge)](https://nightly.link/SwiftcordApp/Swiftcord/workflows/build.yaml/main/swiftcord-canary.zip)

For the latest features and fixes, [a pre-built version of the latest commit is available here](https://nightly.link/SwiftcordApp/Swiftcord/workflows/main/main/Swiftcord_Canary.zip)

### Alpha (More stable, less updated)
[![Download latest GitHub release](https://img.shields.io/github/v/release/cryptoAlgorithm/Swiftcord?style=for-the-badge)](https://github.com/cryptoAlgorithm/Swiftcord/releases/)

Alpha releases are available at [GitHub Releases](https://github.com/cryptoAlgorithm/Swiftcord/releases/)

### Homebrew
[![homebrew cask](https://img.shields.io/homebrew/cask/v/swiftcord?style=for-the-badge)](https://formulae.brew.sh/cask/swiftcord)

Swiftcord is also available on homebrew as a cask: `brew install swiftcord`. Versions are
lock stepped with GitHub releases.

### TestFlight

Coming soon!

<!-- todo: Add building from source -->

---

## FAQ

Covers a few common questions I have encountered, click on the question
to expand the answer

<details>
  <summary><b>Will I get banned for using Swiftcord/Is using Swiftcord illegal?</b></summary>
    Nobody really knows what Discord's official stance on unofficial clients is. 
    However, hundreds of people and I have been using Swiftcord for quite a while, 
    and nobody has been banned to date.
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
  Many features are planned, but I do not currently have a timeline for them. 
  Development is progressing at a fast pace, but sometimes bugs may take an unexpectedly long time to fix.
  I appreciate contributions, bug reports, and suggestions :)
</details>
<details>
  <summary><b>Swiftcord just crashed!</b></summary>
  Although I'm aiming for 0 crashes (which is made easier by Swift),
  sometimes the unexpected happens xD. If you experience a crash, please
  open an issue with appropriate information like the line the error
  occurs on, relevant logs, and what you were doing that might have caused
  the crash. If you can solve the bug causing the crash, that's even better!
</details>

---

## Roadmap
Take a look at Swiftcord's [GitHub Projects board](https://github.com/orgs/SwiftcordApp/projects/1)
to get a rough idea of what's brewing!

---

## Copyright Notice

Copyright (c) 2023 Vincent Kwok & Swiftcord Contributors

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
