#!/bin/bash
echo This will clone the latest version of the SteamOS Waydroid Installer script and perform an update.
sleep 5
cd ~/
rm -rf ~/steamos-waydroid-installer
git clone --depth=1 https://github.com/ryanrudolfoba/steamos-waydroid-installer
cd ~/steamos-waydroid-installer
chmod +x steamos-waydroid-installer.sh
./steamos-waydroid-installer.sh
