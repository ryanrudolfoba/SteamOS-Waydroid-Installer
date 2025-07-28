# SteamOS Android Waydroid Installer

A collection of tools that is packaged into an easy to use script that is streamlined and tested to work with the Steam Deck running on SteamOS.
* The main program that does all the heavy lifting is [Waydroid - a container-based approach to boot a full Android system on a regular GNU/Linux system.](https://github.com/waydroid/waydroid)
* Waydroid Toolbox to easily toggle some configuration settings for Waydroid.
* [waydroid_script](https://github.com/casualsnek/waydroid_script) to easily add the libndk ARM translation layer and widevine.

**NOTE - this repository uses `main` and `testing` branches.**

**`testing`** - this is where new updates / features are pushed and sits for 1-2 weeks to make sure that bugs are squashed and eliminated. You can access it via this command -
```
git clone --depth=1 -b testing https://github.com/ryanrudolfoba/steamos-waydroid-installer
```

**`main`** this is updated after 1-2 weeks in `testing` branch. You can access it via this command -
```
git clone --depth=1 https://github.com/ryanrudolfoba/steamos-waydroid-installer
```

**Script has gone through several updates - this now allows you to install Android 11 / Android 13 and their TV counterparts - Android 11 TV / Android 13 TV!**

| [SteamOS Waydroid Android Install Guide](https://www.youtube.com/watch?v=06T-h-jPVx8) | [SteamOS Waydroid Android Upgrade Guide](https://youtu.be/CJAMwIb_oI0) |
| ------------- | ------------- |
| [![image](https://github.com/user-attachments/assets/2f531480-2786-4ca7-9505-51a5b7443ff3)](https://youtu.be/06T-h-jPVx8)  | [![image](https://github.com/user-attachments/assets/88bb1e93-2f80-4ed0-82f1-1cbe78e04a2f)](https://youtu.be/CJAMwIb_oI0)  |

| [Android TV demo](https://youtu.be/gNFxrojouiM) | [Android 13 demo](https://youtu.be/5BZz8YynaUA) |
| ------------- | ------------- |
| [![image](https://github.com/user-attachments/assets/093bf362-10da-4ff6-ab3d-a3e50ea3c9f7)](https://youtu.be/gNFxrojouiM)  | [![image](https://github.com/user-attachments/assets/cdb47289-4ac6-4625-9fed-0903d624958a)](https://youtu.be/5BZz8YynaUA)  |


![image](https://github.com/user-attachments/assets/a9bc05cc-87ea-43f3-a628-56b0250ae88d)

**Android 13**
![image](https://github.com/user-attachments/assets/cc9d408b-b4af-4d39-8dd3-0507e15ef8a7)
![image](https://github.com/user-attachments/assets/a3ac44b6-68bf-4a1f-bf1a-e880b320dcf0)

**Android 13 TV**
![image](https://github.com/user-attachments/assets/141c2ec6-9918-40e8-bf87-2e199fbbb3f9)

> [!NOTE]
> If you are going to use this script for a video tutorial, PLEASE reference on your video where you got the script! This will make the support process easier!
> And don't forget to give a shoutout to [@10MinuteSteamDeckGamer](https://www.youtube.com/@10MinuteSteamDeckGamer/) / ryanrudolf from the Philippines!

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

# What's New (as of July 28 2025)
1. Sanity check updated - instead of kernel version check it will check if running on SteamOS stable / SteamOS beta
2. Auto build the binder kernel module
3. Cleanup and remove traces of A11. Available options to choose - A13 GAPPS, A13 NO_GAPPS, ATV13 NO_GAPPS

# What's New (as of July 02 2025)
1. Support for SteamOS stable 3.7.13 (this is same kernel used as 3.7.10 so really nothing changed here)

# What's New (as of June 19 2025)
1. Support for SteamOS beta 3.7.10

# What's New (as of June 03 2025)
1. `testing` branch works on latest SteamOS stable 3.7.8 and latest SteamOS beta 3.7.9.
2. Updated waydroid from 1.4.3 to 1.5.1
3. Updated official Android 13 GAPPS / NOGAPPS image. This uses latest build as of May 31 2025

# What's New (as of May 16 2025)
1. Official Android 13 images (GAPPS and NOGAPPS)
2. Working LIBNDK ARM translation layer for Android 13

# What's New (as of Feb 28 2025)
1. Spoof Android TV to Philips TV

# What's New (as of Jan 21 2025)
1. Initial support for Android 13 - NOGAPPS

# What's New (as of Jan 20 2025)
1. Initial support for Android 13 TV

# What's New (as of Jan 16 2025)
1. Initial support for Android 11 TV

<details>
<summary><b>Old Changelog - Click here for more details</b></summary>

**What's New (as of Dec 27 2024)**
1. Support for SteamOS Beta 3.6.21
2. Uploaded initial Waydroid Android 11 TV image in the [release section](https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer/releases/tag/Android11TV)

**What's New (as of Oct 28 2024)**
1. Support for latest SteamOS Stable 3.6.19
2. fixed binder kernel module parameters
3. enhancement - ability to choose with / without Google Playstore on a fresh install
4. enhancement - automatically activate mantis gamepad pro and shizuku
5. enhancement - disable root detection (some apps might still detect root)
6. enhancement - disable first time setup wizard
7. enhancement - Waydroid Toolbox - added NETWORK option
8. enhanceement - Waydroid Toolbox - updated ADBLOCK option

**What's New (as of Oct 10 2024)**
1. add support for latest SteamOS Beta 3.6.16 / 3.6.17
2. add sanity check for home and var partition - make sure home has at least 5GB free space, and var has at least 100MB free space
3. add / fix verbose messages
4. trim output of steamos-add-to-steam

**What's New (as of Sep 07 2024)**
1. support for SteamOS 3.6.12

**What's New (as of Aug 27 2024)**
1. support for SteamOS 3.6.10
2. added experimental waydroid launcher that supports rotation - [demo here](https://youtu.be/OxApPDhZn9I)
3. Waydroid Toolbox - option to uninstall waydroid and retain android user data, or full uninstall of waydroid including android user data

**What's New (as of Aug 09 2024)**
1. support for SteamOS 3.6.9
2. waydroid bump from 1.4.2 to 1.4.3
3. lxc bump from 0.2 to 0.3
4. binder kernel môdule re-built using latest May26 commits
5. cleanup the binder kernel folder names so its easier to read
6. remove libndk-fixer (not needed anymore for Roblox)
7. Add sanity check on the waydroid launcher

**What's New (as of May 28 2024)**
1. Fix for scoped storage permission issue. Apps can now write to data / obb folder. [FIFA 14 now works because of this!](https://youtu.be/_10oQK-ionY?si=bfIBvHPv_spyLPCy)

**What's New (as of May 05 2024)**
1. Minor fix - make minigbm_gbm_mesa as default. This should make [Roblox performance better.](https://youtu.be/-czisFuKoTM?si=8EPXyzasi3no70Tl)
2. Waydroid Toolbox - added option to toggle between gbm or minigbm_gbm_mesa.
3. Added verbose error message when Waydroid initialization fails during install.

**Updated Waydroid Toolbox to easily configure some aspects of Waydroid**
![image](https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer/assets/98122529/3973f218-25a4-4e4b-aba6-b96c45f9a4ef)

**What's New (as of May 01 2024)**
1. Roblox now works thanks to slappy826! [demo guide here how to configure Roblox](https://youtu.be/-czisFuKoTM?si=8EPXyzasi3no70Tl)
2. Updated the Waydroid Toolbox script
3. code cleanup / additional logic
4. switch from gbm to minigm_gbm_mesa

**What's New (as of April 25 2024)**
1. This works with latest stable SteamOS 3.5.19. There is no kernel change for SteamOS - it still uses 6.1.52-valve16-1 so this works right away no need for new kernel modules.\
SteamOS has been stuck on 6.1.52-valve16-1 for several releases now so I think this will stay and next major bump will be on SteamOS 3.6.x.

**What's New (as of March 09 2024)**
1. Updated launcher to easily run APKs in Game Mode. [demo guide here](https://youtu.be/pkRtPHfa_EM?si=broimKF1menbRxGg)
2. Fix minor typo in uninstall - this now removes the Waydroid application entries in the KDE menu.
3. Added Waydroid Toolbox to easily configure some aspects of Waydroid.
![image](https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer/assets/98122529/058c1321-4636-44d7-8b7d-1569f478894b)

**What's New (as of February 11 2024)**
1. Added support for latest SteamOS Preview 3.5.15 - kernel 6.1.52-valve16-1-neptune-61

**What's New (as of February 10 2024)**
1. [lower audio latency](https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer/issues/22)
2. added more sanity checks

**What's New (as of February 07 2024)**
1. removed weston. been testing cage for several weeks now and this is way better than weston.
2. added custom hosts file to block ads

**What's New (as of February 05 2024)**
1. merged PR - [Add fixed key layout file for Steam Deck controller](https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer/pull/19)
2. SteamOS 3.5.14 works. No need to recompile kernel module as it uses the same kernel from 3.5.13

**What's New (as of February 02 2024)**
1. added cage launcher for multi-touch support
2. rewrite the script - instead of building from source this now installs prebuilt binaries
3. easier and quicker to install
4. added support for SteamOS 3.5.13 Preview

**What's New (as of December 07 2023)**
1. this now works with [casualsnek script!](https://github.com/casualsnek/waydroid_script)
2. added libndk arm translation layer (via casualsnek script)
3. added widevine (via casualsnek script). This is needed for Netflix and Disney+
4. waydroid fingerprint identifies as a [Pixel 5 redfin.](https://github.com/Quackdoc/waydroid-scripts) This is needed for Netflix
5. new method for detecting controller [via Saren method](https://gist.github.com/Saren-Arterius/c5bc39199552a5c244449b0ce467d6b6)

**What's New (as of November 26 2023)**
1. cleanup and removed support for SteamOS 3.4.x due to SteamOS 3.5.x already went to stable
2. removed PlasmaNested.sh as this is already included in SteamOS 3.5.x
3. removed the bundled weston binary (only useful when on SteamOS 3.4.x)

**What's New (as of November 15 2023)**
1. initial release
</details>

# Install Steps
<details>
<summary><b>Click here - Read the sections below carefully for steps on how to install and use this script!</b></summary>

**Prerequisites for SteamOS**
1. `sudo` password should already be set by the end user. If `sudo` password is not yet set, the script will ask to set it up.

**How to Use and Install the Script**
1. Go into Desktop Mode and open a `konsole` terminal.
2. Clone the github repo.
	To clone the `main` branch -
   ```sh
   cd ~/
   git clone --depth=1 https://github.com/ryanrudolfoba/steamos-waydroid-installer
   ```

	To clone the `testing` branch where new features / updates are being tested before it goes to `main` -
	```sh
   cd ~/
   git clone --depth=1 -b testing https://github.com/ryanrudolfoba/steamos-waydroid-installer
   ```

3. Execute the script! \

   ```sh
   cd ~/steamos-waydroid-installer
   chmod +x steamos-waydroid-installer.sh
   ./steamos-waydroid-installer.sh
   ```

4. Script will automatically install Waydroid together with the custom config. Install will roughly take around 5mins depending on the internet connection speed.
5. Once done exit the script and go back to Game Mode.

**Launching Waydroid**
1. Go to Game Mode.
2. Run the Android_Waydroid_Cage launcher.
</details>

# Additional Considerations
<details>
<summary><b>Click here - Read the sections below carefully. This are purely OPTIONAL.</b></summary>

**Steam Deck Controller Layout**
[Thanks to DanielLester83!](https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer/issues/134)

Search 'Waydroid' in the community templates or maybe this link would work steam://controllerconfig/3665077347/3304296813

This maps the back buttons to function keys for use with android key remappers like this https://github.com/keymapperorg/KeyMapper

This work around seems to be needed because steaminput does not seem to pass the Search/OS/Windows/Meta Key to Android.

This layout also tweaks the trackpad inputs.

**Configure Android Start Menu Shortcuts to Work in Desktop Mode** \
NOTE: This is purely optional and doesn't affect the functionality of Waydroid if you don't do the steps.\
Personally I don't need it but for those that do then [this is what you need.](https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer/issues/144) Thanks to DanielLester83 for the instructions!

**Controller Not Being Detected** \
The script has been updated so that the controller detection will get triggered once Android has completed the boot process. This makes the controller detection more accurate and the boot sequence to be faster.

However if you use Bluetooth headphones it will interfere with controller detection. Use the workaround mentioned [here](https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer/issues/91#issuecomment-2497139748) and [here](https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer/issues/91#issuecomment-2530544096)
</details>

# I dont want this anymore! I want to uninstall!
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

# Mini-guides for Steam Deck Android Waydroid
This mini guides are tailor-fitted for the Steam Deck that uses the script provided in this repo.

| [How to Sideload APKs](https://youtu.be/LglEbSdRc0M) | [How to Upgrade the Android Image](https://youtu.be/lfwoZZxXh7I) |
| ------------- | ------------- |
| [![image](https://github.com/user-attachments/assets/e50286c3-391e-4189-ac86-47428a9577d2)](https://youtu.be/LglEbSdRc0M) | [![image](https://github.com/user-attachments/assets/4fe9d79d-0ac9-4ac4-983a-ba1fc66e820c)](https://youtu.be/lfwoZZxXh7I) |

| [How to Configure Fake Touchscreen](https://youtu.be/Xt2ceq8ZUJ8) | [How to Configure Fake Wi-Fi](https://youtu.be/LtMGmSSB52g) |
| ------------- | ------------- |
| [![image](https://github.com/user-attachments/assets/19bdadf4-2c3c-4cec-a247-715eccd91529)](https://youtu.be/Xt2ceq8ZUJ8) | [![image](https://github.com/user-attachments/assets/9f07c032-8814-448d-a782-a7ff5185b136)](https://youtu.be/LtMGmSSB52g) |

| [How to Launch APKs Directly in Game Mode](https://youtu.be/pkRtPHfa_EM) | [Configure sdcard as Main Storage for Waydroid](https://youtu.be/Q4QzzjkfZeI) |
| ------------- | ------------- |
| [![image](https://github.com/user-attachments/assets/932154be-89a2-4c04-8587-2e6f363c5337)](https://youtu.be/pkRtPHfa_EM) | [![image](https://github.com/user-attachments/assets/a0075785-528b-4d62-8ba1-9e36483d86f7)](https://youtu.be/Q4QzzjkfZeI) |

| [How to Configure Roblox](https://youtu.be/-czisFuKoTM) | [How to Access the OBB Folder / How to Root](https://youtu.be/RurH-XTTSDQ) |
| ------------- | ------------- |
| [![image](https://github.com/user-attachments/assets/4c188006-a0f1-44cb-8104-0c553e3eb944)](https://youtu.be/-czisFuKoTM) | [![image](https://github.com/user-attachments/assets/5e3e358f-a0f8-45fc-a92e-7348262a7d4a)](https://youtu.be/RurH-XTTSDQ) |

| [How to Rotate Waydroid](https://youtu.be/OxApPDhZn9I) |
| ------------- |
| [![image](https://github.com/user-attachments/assets/87d2f8bc-0ea7-4a11-8e57-76bac5237aff)](https://youtu.be/OxApPDhZn9I) |

# Games Tested By Me on Android Waydroid Steam Deck
[Geekbench Benchmark Result Between Steam Deck OLED and Steam Deck LCD on SteamOS Android Waydroid](https://youtu.be/56YGZsU5j74) - Feb 11 2024 \
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

# Games Tested by Other Users
Please check this [google sheets](https://docs.google.com/spreadsheets/d/1pyqQw2XKJZBtGYBV0i7C510dyjVSU2YndhaTOEDavdU/edit?usp=sharing) for games tested by other users. \
If you wish to contribute, please include the game name, how it runs etc etc. \
Please feel free to add your game testing in there too! Thank you!
