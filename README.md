# SteamOS Android Waydroid Installer

A collection of tools that is packaged into an easy to use script that is streamlined and tested to work with the Steam Deck running on SteamOS.
* The main program that does all the heavy lifting is [Waydroid - a container-based approach to boot a full Android system on a regular GNU/Linux system.](https://github.com/waydroid/waydroid)
* Waydroid Toolbox to easily toggle some configuration settings for Waydroid.
* [waydroid_script](https://github.com/casualsnek/waydroid_script) to easily add the libndk ARM translation layer and widevine.
* ~~[libndk-fixer](https://github.com/Slappy826/libndk-fixer) is a fixed / improved libndk translation layer specific for Roblox [(demo guide here)](https://youtu.be/-czisFuKoTM?si=8EPXyzasi3no70Tl).~~ we don't need libndk-fixer anymore for Roblox - [demo here](https://youtu.be/8lDD7mQYEas)


> **NOTE**\
> If you are going to use this script for a video tutorial, PLEASE reference on your video where you got the script! This will make the support process easier!
> And don't forget to give a shoutout to [@10MinuteSteamDeckGamer](https://www.youtube.com/@10MinuteSteamDeckGamer/) / ryanrudolf from the Philippines!
>

<b> If you like my work please show support by subscribing to my [YouTube channel @10MinuteSteamDeckGamer.](https://www.youtube.com/@10MinuteSteamDeckGamer/) </b> <br>
<b> I'm just passionate about Linux, Windows, how stuff works, and playing retro and modern video games on my Steam Deck! </b>
<p align="center">
<a href="https://www.youtube.com/@10MinuteSteamDeckGamer/"> <img src="https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer/blob/main/10minute.png"/> </a>
</p>

<b>Monetary donations are also encouraged if you find this project helpful. Your donation inspires me to continue research on the Steam Deck! Clover script, 70Hz mod, SteamOS microSD, Secure Boot, etc.</b>

<b>Scan the QR code or click the image below to visit my donation page.</b>

<p align="center">
<a href="https://www.paypal.com/donate/?business=VSMP49KYGADT4&no_recurring=0&item_name=Your+donation+inspires+me+to+continue+research+on+the+Steam+Deck%21%0AClover+script%2C+70Hz+mod%2C+SteamOS+microSD%2C+Secure+Boot%2C+etc.%0A%0A&currency_code=CAD"> <img src="https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer/blob/main/QRCode.png"/> </a>
</p>

# Disclaimer
1. Do this at your own risk!
2. This is for educational and research purposes only!

# [Video Tutorial - SteamOS Android Waydroid Installer](https://youtu.be/8S1RNSqFDu4?si=oCfwYNbs8u9sMKGr)
[Click the image below for a video tutorial and to see the functionalities of the script!](https://youtu.be/06T-h-jPVx8?si=pTWAlmcYyk9fHa38)
</b>
<p align="center">
<a href="https://youtu.be/06T-h-jPVx8?si=pTWAlmcYyk9fHa38"> <img src="https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer/blob/main/android.webp"/> </a>
</p>

# What's New (as of Aug 27 2024)
1. support for SteamOS 3.6.10
2. added experimental waydroid launcher that supports rotation - [demo here](https://youtu.be/OxApPDhZn9I)
3. Waydroid Toolbox - option to uninstall waydroid and retain android user data, or full uninstall of waydroid including android user data
# What's New (as of Aug 09 2024)
1. support for SteamOS 3.6.9
2. waydroid bump from 1.4.2 to 1.4.3
3. lxc bump from 0.2 to 0.3
4. binder kernel môdule re-built using latest May26 commits
5. cleanup the binder kernel folder names so its easier to read
6. remove libndk-fixer (not needed anymore for Roblox)
7. Add sanity check on the waydroid launcher

# What's New (as of May 28 2024)
1. Fix for scoped storage permission issue. Apps can now write to data / obb folder. [FIFA 14 now works because of this!](https://youtu.be/_10oQK-ionY?si=bfIBvHPv_spyLPCy)

# What's New (as of May 05 2024)
1. Minor fix - make minigbm_gbm_mesa as default. This should make [Roblox performance better.](https://youtu.be/-czisFuKoTM?si=8EPXyzasi3no70Tl)
2. Waydroid Toolbox - added option to toggle between gbm or minigbm_gbm_mesa.
3. Added verbose error message when Waydroid initialization fails during install.

**Updated Waydroid Toolbox to easily configure some aspects of Waydroid**
![image](https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer/assets/98122529/3973f218-25a4-4e4b-aba6-b96c45f9a4ef)

# What's New (as of May 01 2024)
1. Roblox now works thanks to slappy826! [demo guide here how to configure Roblox](https://youtu.be/-czisFuKoTM?si=8EPXyzasi3no70Tl)
2. Updated the Waydroid Toolbox script
3. code cleanup / additional logic
4. switch from gbm to minigm_gbm_mesa

# What's New (as of April 25 2024)
1. This works with latest stable SteamOS 3.5.19. There is no kernel change for SteamOS - it still uses 6.1.52-valve16-1 so this works right away no need for new kernel modules.\
SteamOS has been stuck on 6.1.52-valve16-1 for several releases now so I think this will stay and next major bump will be on SteamOS 3.6.x.

# What's New (as of March 09 2024)
1. Updated launcher to easily run APKs in Game Mode. [demo guide here](https://youtu.be/pkRtPHfa_EM?si=broimKF1menbRxGg)
2. Fix minor typo in uninstall - this now removes the Waydroid application entries in the KDE menu.
3. Added Waydroid Toolbox to easily configure some aspects of Waydroid.
![image](https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer/assets/98122529/058c1321-4636-44d7-8b7d-1569f478894b)


# What's New (as of February 11 2024)
1. Added support for latest SteamOS Preview 3.5.15 - kernel 6.1.52-valve16-1-neptune-61

# What's New (as of February 10 2024)
1. [lower audio latency](https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer/issues/22)
2. added more sanity checks

# What's New (as of February 07 2024)
1. removed weston. been testing cage for several weeks now and this is way better than weston.
2. added custom hosts file to block ads

## [Click here to view previous CHANGELOGS](https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer/blob/main/CHANGELOG.md)

# Install Steps
Read the sections below carefully!

## Prerequisites for SteamOS
1. sudo password should already be set by the end user. If sudo password is not yet set, the script will ask to set it up.

## NOTE IF YOU ARE USING AN OLDER VERSION OF MY SCRIPT FROM 2023!
1. [Uninstall first if you are using an older version from 2023.](https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer/tree/main#i-dont-want-this-anymore-i-want-to-uninstall)
2. If you are using my script from 2024 onwards no need to uninstall - just clone the repo to get the latest version and install it.

## How to Use
1. Go into Desktop Mode and open a konsole terminal.
2. Clone the github repo. \
   cd ~/ \
   git clone https://github.com/ryanrudolfoba/steamos-waydroid-installer
3. Execute the script! \
   cd ~/steamos-waydroid-installer \
   chmod +x steamos-waydroid-installer.sh \
   ./steamos-waydroid-installer.sh
4. Script will automatically install Waydroid together with the custom config. Install will roughly take around 5mins depending on the internet connection speed.
5. Once done exit the script and go back to Game Mode.

## Launching Waydroid
1. Go to Game Mode.
2. Run the Android_Waydroid_Cage launcher.

## Steam Deck Controller Layout
[Thanks to DanielLester83!](https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer/issues/134)

Search 'Waydroid' in the community templates or maybe this link would work steam://controllerconfig/3665077347/3304296813

This maps the back buttons to function keys for use with android key remappers like this https://github.com/keymapperorg/KeyMapper

This work around seems to be needed because steaminput does not seem to pass the Search/OS/Windows/Meta Key to Android.

This layout also tweaks the trackpad inputs.


## I dont want this anymore! I want to uninstall!
1. Go to Desktop Mode.
2. There will be an icon called Waydroid Toolbox on the desktop.
3. Launch that icon and select UNINSTALL.
![image](https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer/assets/98122529/afdf9e95-7ccf-4bc8-9400-4b8332c5afe9)


# Troubleshooting / Filing Bug Reports
1. If you encounter an issue with the script, try to [uninstall](https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer/tree/main#i-dont-want-this-anymore-i-want-to-uninstall), clone the repo again and perform an install.\
Reason for that - you might be using an older version of my script and a new version might have already fixed your issue.
2. If uninstall / reinstall didn't help, open an issue and please be descriptive as possible. \
At the minimum include this when filing an issue - \
SteamOS version - \
Error message encountered - \
Screenshot of error - \
Do you have any scripts / tweaks that might be causing issues?
3. Downloads are slow when acquiring the waydroid image. This is similar to this [issue](https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer/issues/26). \
Answer - You might have connected to a slow sourceforge mirror. Press CTRL-C to cancel the download and re-run the script again.
4. No shortcuts in Game Mode after running the script / Unsupported File Type when adding shortcuts. This is similar to this [issue](https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer/issues/25). \
Answer - This issue happens if Steam client cant be run because the script was called from an ssh or virtual tty session. Make sure to run the script on Desktop Mode via konsole.

# A Note on SteamOS Updates
When there is a SteamOS update the waydroid will be wiped. This is normal behavior due to how SteamOS applies updates. \
Re-run the script again but if the SteamOS update contains a new kernel version the script will exit immediately. \
Please file an issue report when this happens so I can compile a binder kernel module to match the SteamOS update.

# Geekbench Benchmark Result Between OLED and LCD on SteamOS Android Waydroid
[Geekbench Result](https://youtu.be/56YGZsU5j74) - Feb 11 2024

# List of Games Tested Working with Demo Gameplay
This is a Work in Progress - list will be updated accordingly. \
If you wish to contribute, please check the [google sheets](https://docs.google.com/spreadsheets/d/1pyqQw2XKJZBtGYBV0i7C510dyjVSU2YndhaTOEDavdU/edit?usp=sharing) and include the game name, how it runs etc etc.

## Games Tested By Me on Android Waydroid Steam Deck
[Plants vs Zombies](https://youtu.be/rnb0z1LtDN8) - Feb 04 2024 \
[Honkai Star Rail](https://youtu.be/M1Y9DMG9rbM) - Feb 06 2024 \
[Asphalt 8 Airborne](https://youtu.be/OCaatZdZR1I) - Feb 08 2024 \
[Honkai Impact 3rd](https://youtu.be/6YdNOJ0u2KM) - Feb 10 2024 \
[Mobile Legends](https://youtu.be/PlPRNn92NDI) - Feb 13 2024 \
[T3 Arena](https://youtu.be/wq87nd3MCrQ?si=h4A7NEwEFGujF7hH) - Feb 16 2024 \
[Warcraft Rumble](https://youtu.be/rnb0z1LtDN8) - Feb 19 2024 \
[Diablo Immortal](https://youtu.be/4lJOnGnEJjw) - Feb 21 2024 \
[Oceanhorn](https://youtu.be/vKPJZeyw0DI) - Feb 23 2024 \
[Candy Crush Saga](https://youtu.be/XEcIYBDoOZk) - Mar 11 2024 \
[BombSquad](https://youtu.be/vatf5uY_Eak) - Mar 16 2024 \
[Project BloodStrike](https://youtu.be/pRwvZBMDpY0) - Mar 18 2024 \
[NBA Infinite](https://youtu.be/LLw4GnWL58I) - Mar 23 2024 \
[Roblox](https://youtu.be/-czisFuKoTM?si=8EPXyzasi3no70Tl) - May 01 2024 \
[Plants vs Zombies 2 - Reflourished](https://youtu.be/RurH-XTTSDQ) - May 17 2024 \
[Wuthering Waves](https://youtu.be/KfQVCTtpiNI) - May 23 2024 \
[FIFA 14](https://youtu.be/_10oQK-ionY?si=bfIBvHPv_spyLPCy) - May 28 2024 \
[KOF Arena / King of Fighters Arena](https://youtu.be/XlIB9MwyQdw?si=zLa5AAPyrAXiKct8) - June 18 2024 \
[Injustice](https://youtu.be/fMG4OMhcpz8) - July 12 2024 \
[Wuthering Waves using patched LIBNDK](https://youtu.be/vBRFzg14Sp4) - Aug 01 2024 \
[Roblox x86 APK](https://youtu.be/8lDD7mQYEas) - Aug 03 2024 \
[Blue Archive using patched LIBNDK](https://youtu.be/WtUluvNznpA) - Aug 27 2024


## Games Tested by Other Users
Please check this [google sheets](https://docs.google.com/spreadsheets/d/1pyqQw2XKJZBtGYBV0i7C510dyjVSU2YndhaTOEDavdU/edit?usp=sharing) for games tested by other users. \
Please feel free to add your game testing in there too! Thank you!

# Mini-guides for Steam Deck Android Waydroid
This mini guides are tailor-fitted for the Steam Deck that uses the script provided in this repo. \
[How to Sideload APKs](https://youtu.be/LglEbSdRc0M) \
[How to Upgrade the Android Image](https://youtu.be/lfwoZZxXh7I) \
[How to Configure Fake Wi-Fi](https://youtu.be/LtMGmSSB52g) \
[How to Configure Fake Touchscreen / Configure Mouse Clicks as Touchscreen Input](https://youtu.be/Xt2ceq8ZUJ8) \
[How to Launch APKs Directly in Game Mode](https://youtu.be/pkRtPHfa_EM?si=broimKF1menbRxGg) \
[Configure for 1080p When in Docked Mode](https://youtu.be/D9ODCpjDK30) \
[Configure sdcard as Main Storage for Waydroid](https://youtu.be/Q4QzzjkfZeI) \
[Activate and Configure Mantis Gamepad Pro](https://youtu.be/icVOh7IIfE0) \
[How to Configure Roblox](https://youtu.be/-czisFuKoTM?si=8EPXyzasi3no70Tl) \
[How to Access the OBB Folder / How to Root](https://youtu.be/RurH-XTTSDQ) \
[How to Rotate Waydroid](https://youtu.be/OxApPDhZn9I)
