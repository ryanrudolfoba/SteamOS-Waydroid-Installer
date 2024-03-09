### Changelog

## What's New (as of March 09 2024)
1. Updated launcher to easily run APKs in Game Mode. [demo guide here](https://youtu.be/pkRtPHfa_EM?si=broimKF1menbRxGg)
2. Fix minor typo in uninstall - this now removes the Waydroid application entries in the KDE menu.
3. Added Waydroid Toolbox to easily configure some aspects of Waydroid.
![image](https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer/assets/98122529/058c1321-4636-44d7-8b7d-1569f478894b)

## What's New (as of February 11 2024)
1. Added support for latest SteamOS Preview 3.5.15 - kernel 6.1.52-valve16-1-neptune-61

## What's New (as of February 10 2024)
1. [lower audio latency](https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer/issues/22)
2. added more sanity checks

## What's New (as of February 07 2024)
1. removed weston. been testing cage for several weeks now and this is way better than weston.
2. added custom hosts file to block ads

## What's New (as of February 05 2024)
1. merged PR - [Add fixed key layout file for Steam Deck controller](https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer/pull/19)
2. SteamOS 3.5.14 works. No need to recompile kernel module as it uses the same kernel from 3.5.13

## What's New (as of February 02 2024)
1. added cage launcher for multi-touch support
2. rewrite the script - instead of building from source this now installs prebuilt binaries
3. easier and quicker to install
4. added support for SteamOS 3.5.13 Preview

## What's New (as of December 07 2023)
1. this now works with [casualsnek script!](https://github.com/casualsnek/waydroid_script)
2. added libndk arm translation layer (via casualsnek script)
3. added widevine (via casualsnek script). This is needed for Netflix and Disney+
4. waydroid fingerprint identifies as a [Pixel 5 redfin.](https://github.com/Quackdoc/waydroid-scripts) This is needed for Netflix
5. new method for detecting controller [via Saren method](https://gist.github.com/Saren-Arterius/c5bc39199552a5c244449b0ce467d6b6)

## What's New (as of November 26 2023)
1. cleanup and removed support for SteamOS 3.4.x due to SteamOS 3.5.x already went to stable
2. removed PlasmaNested.sh as this is already included in SteamOS 3.5.x
3. removed the bundled weston binary (only useful when on SteamOS 3.4.x)

## What's New (as of November 15 2023)
1. initial release

### [Go back to the main README](https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer)
