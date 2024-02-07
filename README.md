# SteamOS Android Waydroid Installer

A shell script to easily install / uninstall Android ([via Waydroid](https://waydro.id/)) on the Steam Deck running on SteamOS.

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

# What's New (as of February 07 2024)
1. removed weston. been testing cage for several weeks now and this is way better than weston.
2. added custom hosts file to block ads

# What's New (as of February 05 2024)
1. merged PR - [Add fixed key layout file for Steam Deck controller](https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer/pull/19)
2. SteamOS 3.5.14 works. No need to recompile kernel module as it uses the same kernel from 3.5.13

## [Click here to view previous CHANGELOGS](https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer/blob/main/CHANGELOG.md)

# Install Steps
Read the sections below carefuly!

## Prerequisites for SteamOS
1. sudo password should already be set by the end user. If sudo password is not yet set, the script will ask to set it up.

## NOTE IF YOU ARE USING AN OLDER VERSION OF MY SCRIPT
1. [Uninstall first if you are using an older version.](https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer/tree/main#i-dont-want-this-anymore-i-want-to-uninstall)

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

## I dont want this anymore! I want to uninstall!
1. Go to Desktop Mode.
2. Open konsole terminal and type the commands - \
   cd ~/Android_Waydroid \
   ./uninstall.sh
3. Enter the sudo password when prompted.
4. Waydroid and the custom configs will be uninstalled.
5. Delete the Android_Waydroid_Cage and Android_Waydroid_Weston shortuct in Game Mode.
6. OPTIONAL - Delete the steamos-nested-desktop shortcut in Game Mode.

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

# List of Games Tested Working with Demo Gameplay
This is a Work in Progress - list will be updated accordingly. \
If you wish to contribute, please open an issue and include the game name, how it runs etc etc.

## Games Tested By Me on Android Waydroid Steam Deck
[Plants vs Zombies](https://youtu.be/rnb0z1LtDN8) - Feb 04 2024 \
[Honkai Star Rail](https://youtu.be/M1Y9DMG9rbM) - Feb 06 2024

## Games Tested by Other Users
Thanks to [The-MAZZter](https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer/issues/29) for testing and feedback! Once I have spare time I might do a demo gameplay on this. \
Godville - works \
Clicker Hero - works \
Pokemon Go - does not work \
Pokemon TCG Live - does not work \
Pokemonn Masters EX - does not work
