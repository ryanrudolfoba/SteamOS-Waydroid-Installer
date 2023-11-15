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

## Disclaimer
1. Do this at your own risk!
2. This is for educational and research purposes only!

## [Video Tutorial - SteamOS Waydroid Installer](https://youtu.be/ZKROup0Jnjg?si=DYmFFOeXmlNVUv_a)
[Click the image below for a video tutorial and to see the functionalities of the script!](https://youtu.be/ZKROup0Jnjg?si=DYmFFOeXmlNVUv_a)
</b>
<p align="center">
<a href="https://youtu.be/ZKROup0Jnjg?si=DYmFFOeXmlNVUv_a"> <img src="https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer/blob/main/android.jpg"/> </a>
</p>

## What's New (as of November 15 2023)
1. initial release

## Prerequisites for SteamOS
1. sudo password should already be set by the end user. If sudo password is not yet set, the script will ask to set it up.

## How to Use
1. Go into Desktop Mode and open a konsole terminal.
2. Clone the github repo. \
   cd ~/ \
   git clone https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer
3. Execute the script! \
   cd ~/SteamOS-Waydroid-Installer \
   chmod +x steamos-waydroid-installer.sh \
   ./steamos-waydroid-installer.sh
4. Script will automatically install Waydroid together with the custom config. Install will roughly take around 5mins depending on the internet connection.
5. Once done exit the script and go back to Game Mode.

## Initial Config
1. Go to Game Mode and open PlasmaNested.sh launcher.
2. Once inside the nested desktop environment, open konsole terminal and enter the commands - \
   sudo /usr/bin/waydroid-container-start \
   waydroid session start
3. Wait until it shows Anroid user 0 is ready.
4. Open Firefox browser and go to - https://docs.waydro.id/faq/google-play-certification
5. Copy the code below -
   ![image](https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer/assets/98122529/032f52e6-8637-4770-b11f-9e06085f2fee)
6. Open another konsole terminal and enter the command - \
   sudo waydroid shell
7. Enter the sudo password when prompted. Paste the item that was copied from step 6 and press enter.
8. It will show result android_id:xxxxxxxxxxxxxxxxxxxxxxxx
9. Copy the digits after android_id.
10. Go to https://www.google.com/android/uncertified and login as needed.
11. Enter the copied android_id from step 9 and press register.
12. Once done close Firefox.
13. On the konsole terminal type the commands - \
    waydroid session stop \
    exit
14. Press STEAM button and select EXIT GAME to close the nested desktop.
15. Initial config is done! Use Android_Waydroid.sh in Game Mode to launch Android!

## Launching Waydroid
1. Go to Game Mode.
2. Run the Android_Waydroid.sh launcher.

## Tips and Troubleshooting
1. Install Game Controller Tester in the Playstore to check controller status. The custom config / scripts will automatically detect the controller.
2. If the controller is not detected, press STEAM button and change the controller to MOUSE ONLY. Apply the changes, then press STEAM button again and change the controller back to Gamepad then apply changes.
3. Only native x86 applications will show on the Playstore. If you want arm applications need to use the casualsnek script.

## Running ARM Applications
To run ARM applications it needs the casualsnek scrit to easily install the libndk translation layer. I can't make it work on SteamOS 3.5.x, so the script is only bundled on SteamOS 3.4.x.

1. Go to Desktop Mode.
2. Open konsole terminal and type the commands - \
   cd ~/AUR/weaydroid_script \
   python3 -m venv venv \
   venv/bin/pip install -r requirements.txt \
   sudo venv/bin/python3 main.py install libndk \
   exit
4. Go back to Game Mode and open Android_Waydroid.sh launcher.

## I dont want this anymore! I want to uninstall!
1. Go to Desktop Mode.
2. Open konsole terminal and type the commands - \
   cd ~/Android_Waydroid \
   ./uninstall.sh
3. Enter the sudo password when prompted.
4. Waydroid and the custom configs will be uninstalled.
