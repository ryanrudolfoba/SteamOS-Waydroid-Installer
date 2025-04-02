#!/bin/bash

clear

echo SteamOS Waydroid Installer Script by ryanrudolf
echo https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer
echo YT - 10MinuteSteamDeckGamer
sleep 2

# define variables here
script_version_sha=$(git rev-parse --short HEAD)
steamos_version=$(cat /etc/os-release | grep -i version_id | cut -d "=" -f2)
kernel_version=$(uname -r | cut -d "-" -f 1-5 )
stable_kernel1=6.1.52-valve16-1-neptune-61
stable_kernel2=6.5.0-valve22-1-neptune-65
beta_kernel1=6.5.0-valve23-1-neptune-65
ANDROID11_TV_IMG=https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer/releases/download/Android11TV/lineage-18.1-20241220-UNOFFICIAL-10MinuteSteamDeckGamer-WaydroidATV.zip
ANDROID11_TV_IMG_HASH=680971aaeb9edc64d9d79de628bff0300c91e86134f8daea1bbc636a2476e2a7
ANDROID13_TV_IMG=https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer/releases/download/Android13TV/lineage-20-20250117-UNOFFICIAL-10MinuteSteamDeckGamer-WaydroidATV.zip
ANDROID13_TV_IMG_HASH=2ac5d660c3e32b8298f5c12c93b1821bc7ccefbd7cfbf5fee862e169aa744f4c
ANDROID13_IMG=https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer/releases/download/Android13/lineage-20-20250121-UNOFFICIAL-10MinuteSteamDeckGamer-Waydroid.zip
ANDROID13_IMG_HASH=833be8279a605285cc2b9c85425511a100320102c7ff8897f254fcfdf3929bb1
AUR_CASUALSNEK=https://github.com/casualsnek/waydroid_script.git
AUR_CASUALSNEK2=https://github.com/ryanrudolfoba/waydroid_script.git
DIR_CASUALSNEK=~/AUR/waydroid/waydroid_script
FREE_HOME=$(df /home --output=avail | tail -n1)
FREE_VAR=$(df /var --output=avail | tail -n1)
PLUGIN_LOADER=/home/deck/homebrew/services/PluginLoader

# define functions here
cleanup_exit () {
	# call this function to perform cleanup when a sanity check fails
	
	# remove binder kernel module
	echo Something went wrong! Performing cleanup. Run the script again to install waydroid.
	echo -e "$current_password\n" | sudo -S rm /lib/modules/$(uname -r)/binder_linux.ko.zst &> /dev/null
	
	# remove installed packages
	echo -e "$current_password\n" | sudo -S pacman -R --noconfirm libglibutil libgbinder python-gbinder waydroid wlroots dnsmasq lxc &> /dev/null
	
	# delete the waydroid directories
	echo -e "$current_password\n" | sudo -S rm -rf ~/waydroid /var/lib/waydroid ~/AUR &> /dev/null
	
	# delete waydroid config and scripts
	echo -e "$current_password\n" | sudo -S rm /etc/sudoers.d/zzzzzzzz-waydroid /etc/modules-load.d/waydroid.conf /usr/bin/waydroid* &> /dev/null
	
	# delete cage binaries
	echo -e "$current_password\n" | sudo -S rm /usr/bin/cage /usr/bin/wlr-randr &> /dev/null
	echo -e "$current_password\n" | sudo -S rm -rf ~/Android_Waydroid &> /dev/null
	echo -e "$current_password\n" | sudo -S steamos-readonly enable &> /dev/null
	
	# re-enable Decky Loader Plugin Loader service
	if [ -f $PLUGIN_LOADER ]
	then
		echo Re-enabling the Decky Loader plugin loader service.
		echo -e "$current_password\n" | sudo -S systemctl start plugin_loader.service
	fi
	
	echo Cleanup completed. Please open an issue on the GitHub repo or leave a comment on the YT channel - 10MinuteSteamDeckGamer.
	exit
}

prepare_custom_image_location () {
# call this function when deploying a custom Android image
# custom Android images needs to be placed in /etc/waydroid-extra/images
# this will create a symlink to /etc/waydroid-extra/images
echo -e "$current_password\n" | sudo mkdir /etc/waydroid-extra &> /dev/null
echo -e "$current_password\n" | sudo -S ln -s ~/waydroid/custom /etc/waydroid-extra/images &> /dev/null
}

download_image () {
	local src=$1
	local src_hash=$2
	local dest=$3
	local dest_zip="$dest.zip"
	local name=$4
	local hash

	echo Downloading $name image
	echo -e "$current_password\n" | sudo -S curl -o $dest_zip $src -L
	hash=$(sha256sum "$dest_zip" | awk '{print $1}')
	# Verify the hash
	if [[ "$hash" != "$src_hash" ]]; then
		echo sha256 hash mismatch for $name image, indicating a corrupted download. This might be due to a network error, you can try again.
		cleanup_exit
	fi

	echo Extracting Archive
	echo -e "$current_password\n" | sudo -S unzip -o $dest -d ~/waydroid/custom
	echo -e "$current_password\n" | sudo -S rm $dest_zip
}

install_android_extras () {
	# casualsnek script
	python3 -m venv $DIR_CASUALSNEK/venv
	$DIR_CASUALSNEK/venv/bin/pip install -r $DIR_CASUALSNEK/requirements.txt &> /dev/null
	echo -e "$current_password\n" | sudo -S $DIR_CASUALSNEK/venv/bin/python3 $DIR_CASUALSNEK/main.py install {libndk,widevine}
	if [ $? -eq 0 ]
	then
		echo Casualsnek script done.
		echo -e "$current_password\n" | sudo -S rm -rf ~/AUR
	else
		echo Error with casualsnek script. Run the script again.
		cleanup_exit
	fi
}

install_android_spoof () {
	# waydroid_base.prop - controller config and disable root
	cat extras/waydroid_base.prop | sudo tee -a /var/lib/waydroid/waydroid_base.prop > /dev/null

	# check if A11 or A13 and apply the spoof accordingly
	if [ "$Choice" == "A11_NO_GAPPS" ] || [ "$Choice" == "A11_GAPPS" ] || [ "$Choice" == "A13_NO_GAPPS" ]
	then
		cat extras/android_spoof.prop | sudo tee -a /var/lib/waydroid/waydroid_base.prop > /dev/null

	elif [ "$Choice" == "TV11_NO_GAPPS" ] || [ "$Choice" == "TV13_NO_GAPPS" ]
	then
		cat extras/androidtv_spoof.prop | sudo tee -a /var/lib/waydroid/waydroid_base.prop > /dev/null
	fi
}

check_waydroid_init () {
	# check if waydroid initialization completed without errors
	if [ $? -eq 0 ]
	then
		echo Waydroid initialization completed without errors!

	else
		echo Waydroid did not initialize correctly.
		echo This could be a hash mismatch / corrupted download.
		echo This could also be a python issue. Attach this screenshot when filing a bug report!
		echo Output of whereis python - $(whereis python)
		echo Output of which python - $(which python)
		echo Output of python version - $(python -V)

		cleanup_exit
	fi
}

# disable the SteamOS readonly and initialize the keyring using the older method
devmode_fallback () {
	echo Using the older method to unlock the readonly and initialize the keyring.
	echo -e "$current_password\n" | sudo -S steamos-readonly disable && \
	echo -e "$current_password\n" | sudo -S pacman-key --init && \
	echo -e "$current_password\n" | sudo -S pacman-key --populate
}

echo script version: $script_version_sha

# sanity check - are you running this in Desktop Mode or ssh / virtual tty session?
xdpyinfo &> /dev/null
if [ $? -eq 0 ]
then
	echo Script is running in Desktop Mode.
else
 	echo Script is NOT running in Desktop Mode.
	echo Please run the script in Desktop Mode as mentioned in the README. Goodbye!
	exit
fi

# sanity check - make sure kernel version is supported. exit immediately if not on the supported kernel
echo Checking if kernel is supported.
if [ $kernel_version = $stable_kernel1 ] || [ $kernel_version = $stable_kernel2 ] || [ $kernel_version = $beta_kernel1 ]
then
	echo SteamOS $steamos_version - kernel version $kernel_version is supported. Proceed to next step.
else
	echo SteamOS $steamos_version - kernel version $kernel_version is NOT supported. Exiting immediately.
	exit
fi

# sanity check - make sure there is enough free space in the home partition (at least 5GB)
echo Checking if home partition has enough free space
echo home partition has $FREE_HOME free space.
if [ $FREE_HOME -ge 5000000 ]
then
	echo home partition has enough free space.
else
	echo Not enough space on the home partition!
	echo Make sure that there is at least 5GB free space on the home partition!
	exit
fi

# sanity check - is this a reinstall?
# this sanity check will go away once the var trick is completed
grep redfin /var/lib/waydroid/waydroid_base.prop || grep PH7M_EU_5596 /var/lib/waydroid/waydroid_base.prop &> /dev/null
if [ $? -eq 0 ]
then
	echo This seems to be a reinstall. var sanity check not needed.
else
	# sanity check - make sure there is enough free space in the var partition (at least 100MB)
	echo Checking if var partition has enough free space
	echo var partition has $FREE_VAR free space.
	if [ $FREE_VAR -ge 100000 ]
	then
		echo var partition has enough free space.
	else
		echo Not enough space on the var partition!
		echo Make sure that there is at least 100MB free space on the var partition!
		exit
	fi
fi

# sanity check - make sure sudo password is already set
if [ "$(passwd --status $(whoami) | tr -s " " | cut -d " " -f 2)" == "P" ]
then
	read -s -p "Please enter current sudo password: " current_password ; echo
	echo Checking if the sudo password is correct.
	echo -e "$current_password\n" | sudo -S -k ls &> /dev/null

	if [ $? -eq 0 ]
	then
		echo Sudo password is good!
	else
		echo Sudo password is wrong! Re-run the script and make sure to enter the correct sudo password!
		exit
	fi
else
	echo Sudo password is blank! Setup a sudo password first and then re-run script!
	passwd
	exit
fi

# sanity check - is Decky Loader installed?
if [ -f $PLUGIN_LOADER ]
then
	echo Decky Loader detected! This may cause issues with the SteamOS Waydroid installer script!
	echo Temporary disabling the Decky Loader plugin loader service.
	echo -e "$current_password\n" | sudo -S systemctl stop plugin_loader.service

	if [ $? -eq 0 ]
	then
		echo Decky Loader Plugin Loader service successfully disabled.
		echo Once the script has finished installing Waydroid, the Decky Loader Plugin Loader service will be re-enabled.
	  echo You can also reboot the Steam Deck to re-activate the Decky Loader Plugin Loader service.
	else
		echo Error ecountered when stopping the Decky Loader Plugin Loader service.
		echo Exiting immediately.
		exit
	fi
fi

# sanity checks are all good. lets go!
# create AUR directory where casualsnek script will be saved
mkdir -p ~/AUR/waydroid &> /dev/null

# perform git clone but lets cleanup first in case the directory is not empty
echo Cloning casualsnek repo.
echo This can take a few minutes depending on the speed of the internet connection and if github is having issues.
echo If the git clone is slow - cancel the script \(CTL-C\) and run it again.

echo -e "$current_password\n" | sudo -S rm -rf ~/AUR/waydroid*  &> /dev/null && git clone --depth=1 $AUR_CASUALSNEK $DIR_CASUALSNEK &> /dev/null

if [ $? -eq 0 ]
then
	echo Casualsnek repo has been successfully cloned!
else
	echo Error cloning Casualsnek repo! Trying to clone again using backup repo.
	echo -e "$current_password\n" | sudo -S rm -rf ~/AUR/waydroid*  &> /dev/null && git clone --depth=1 $AUR_CASUALSNEK2 $DIR_CASUALSNEK &> /dev/null

	if [ $? -eq 0 ]
	then
		echo Casualsnek repo has been successfully cloned!
	else
		echo Error cloning Casualsnek repo! This failed twice already! Maybe your internet connection is the problem?
		cleanup_exit
	fi
fi

# check if steamos-devmode command exists
devmode_exists=$(which steamos-devmode &> /dev/null; echo $?)
if [ "$devmode_exists" -eq 0 ]
then
	# disable the SteamOS readonly and initialize the keyring using the steamos-devmode command
	echo steamos-devmode command exists. Using steamos-devmode to unlock the readonly and initialize the keyring
	echo -e "$current_password\n" | sudo -S steamos-devmode enable --no-prompt > /dev/null
else
	echo steamos-devmode command does not exist. Trying fallback.
	devmode_fallback
fi

if [ $? -eq 0 ]
then
	echo pacman keyring has been initialized!
elif [ "$devmode_exists" -eq 0 ]
then
	echo Error initializing keyring!
	devmode_fallback
	if [ $? -eq 0 ]
	then
		echo Error initializing keyring with fallback!
		cleanup_exit
	fi
else
	echo Error initializing keyring with fallback!
	cleanup_exit
fi

# lets install and enable the binder module so we can start waydroid right away
binder_loaded=$(lsmod | grep -q binder; echo $?)
binder_differs=$(cmp -s binder/$kernel_version/binder_linux.ko.zst /lib/modules/$(uname -r)/binder_linux.ko.zst; echo $?)
if [ "$binder_loaded" -ne 0 ] || [ "$binder_differs" -ne 0 ]
then
	echo Binder kernel module not found or not up to date! Installing binder!
	echo -e "$current_password\n" | sudo -S cp binder/$kernel_version/binder_linux.ko.zst /lib/modules/$(uname -r) && \
	echo -e "$current_password\n" | sudo -S depmod -a && \
	echo -e "$current_password\n" | sudo -S modprobe binder-linux device=binder,hwbinder,vndbinder

	if [ $? -eq 0 ]
	then
		echo Binder kernel module has been installed!
	else
		echo Error installing binder kernel module. Run the script again to install waydroid.
		cleanup_exit
	fi
else
	echo Binder kernel module already loaded and up to date! No need to reinstall binder!
fi

# ok lets install waydroid and cage
echo -e "$current_password\n" | sudo -S pacman -U cage/wlroots-0.16.2-1-x86_64.pkg.tar.zst waydroid/dnsmasq-2.89-1-x86_64.pkg.tar.zst \
	waydroid/lxc-1\:5.0.3-1-x86_64.pkg.tar.zst waydroid/libglibutil-1.0.74-1-x86_64.pkg.tar.zst waydroid/libgbinder-1.1.35-1-x86_64.pkg.tar.zst \
	waydroid/python-gbinder-1.1.2-1-x86_64.pkg.tar.zst waydroid/waydroid-1.4.3-1-any.pkg.tar.zst --noconfirm --overwrite "*" &> /dev/null

if [ $? -eq 0 ]
then
	echo waydroid and cage has been installed!
	echo -e "$current_password\n" | sudo -S systemctl disable waydroid-container.service
else
	echo Error installing waydroid and cage. Run the script again to install waydroid.
	cleanup_exit
fi

# firewall config for waydroid0 interface to forward packets for internet to work
echo -e "$current_password\n" | sudo -S firewall-cmd --zone=trusted --add-interface=waydroid0 &> /dev/null
echo -e "$current_password\n" | sudo -S firewall-cmd --zone=trusted --add-port=53/udp &> /dev/null
echo -e "$current_password\n" | sudo -S firewall-cmd --zone=trusted --add-port=67/udp &> /dev/null
echo -e "$current_password\n" | sudo -S firewall-cmd --zone=trusted --add-forward &> /dev/null
echo -e "$current_password\n" | sudo -S firewall-cmd --runtime-to-permanent &> /dev/null

# lets install the custom config files
mkdir ~/Android_Waydroid &> /dev/null

# waydroid start service
echo -e "$current_password\n" | sudo -S cp extras/waydroid-container-start /usr/bin/waydroid-container-start
echo -e "$current_password\n" | sudo -S chmod +x /usr/bin/waydroid-container-start

# waydroid stop service
echo -e "$current_password\n" | sudo -S cp extras/waydroid-container-stop /usr/bin/waydroid-container-stop
echo -e "$current_password\n" | sudo -S chmod +x /usr/bin/waydroid-container-stop

# waydroid startup scripts
echo -e "$current_password\n" | sudo -S cp extras/waydroid-startup-scripts /usr/bin/waydroid-startup-scripts
echo -e "$current_password\n" | sudo -S chmod +x /usr/bin/waydroid-startup-scripts

# custom sudoers file do not ask for sudo for the custom waydroid scripts
echo -e "$current_password\n" | sudo -S cp extras/zzzzzzzz-waydroid /etc/sudoers.d/zzzzzzzz-waydroid
echo -e "$current_password\n" | sudo -S chown root:root /etc/sudoers.d/zzzzzzzz-waydroid

# custom configs done. lets move them to the correct location
cp extras/Android_Waydroid_Cage.sh extras/Waydroid-Toolbox.sh extras/Waydroid-Updater.sh extras/Android_Waydroid_Cage-experimental.sh ~/Android_Waydroid
chmod +x ~/Android_Waydroid/*.sh
# desktop shortcuts for toolbox + updater
ln -s ~/Android_Waydroid/Waydroid-Toolbox.sh ~/Desktop/Waydroid-Toolbox &> /dev/null
ln -s ~/Android_Waydroid/Waydroid-Updater.sh ~/Desktop/Waydroid-Updater &> /dev/null

# lets copy cage and wlr-randr to the correct folder
echo -e "$current_password\n" | sudo -S cp cage/cage cage/wlr-randr /usr/bin
echo -e "$current_password\n" | sudo -S chmod +x /usr/bin/cage /usr/bin/wlr-randr

# lets check if this is a reinstall
grep redfin /var/lib/waydroid/waydroid_base.prop || grep PH7M_EU_5596 /var/lib/waydroid/waydroid_base.prop &> /dev/null
if [ $? -eq 0 ]
then
	echo This seems to be a reinstall. No further config needed.

	# all done lets re-enable the readonly
	echo -e "$current_password\n" | sudo -S steamos-readonly enable
	echo Waydroid has been successfully installed!
else
	echo Downloading waydroid image from sourceforge.
	echo This can take a few seconds to a few minutes depending on the internet connection and the speed of the sourceforge mirror.
	echo Sometimes it connects to a slow sourceforge mirror and the downloads are slow -. This is beyond my control!
	echo If the downloads are slow due to a slow sourceforge mirror - cancel the script \(CTL-C\) and run it again.

	# lets initialize waydroid
	mkdir -p ~/waydroid/{images,custom,cache_http,host-permissions,lxc,overlay,overlay_rw,rootfs}
	echo -e "$current_password\n" | sudo mkdir /var/lib/waydroid &> /dev/null
	echo -e "$current_password\n" | sudo -S ln -s ~/waydroid/images /var/lib/waydroid/images &> /dev/null
	echo -e "$current_password\n" | sudo -S ln -s ~/waydroid/cache_http /var/lib/waydroid/cache_http &> /dev/null

	# place custom overlay files here - key layout, hosts, audio.rc etc etc
	# copy fixed key layout for Steam Controller
	echo -e "$current_password\n" | sudo -S mkdir -p /var/lib/waydroid/overlay/system/usr/keylayout
	echo -e "$current_password\n" | sudo -S cp extras/Vendor_28de_Product_11ff.kl /var/lib/waydroid/overlay/system/usr/keylayout/

	# copy custom audio.rc patch to lower the audio latency
	echo -e "$current_password\n" | sudo -S mkdir -p /var/lib/waydroid/overlay/system/etc/init
	echo -e "$current_password\n" | sudo -S cp extras/audio.rc /var/lib/waydroid/overlay/system/etc/init/

	# copy custom hosts file from StevenBlack to block ads (adware + malware + fakenews + gambling + pr0n)
	echo -e "$current_password\n" | sudo -S mkdir -p /var/lib/waydroid/overlay/system/etc
	echo -e "$current_password\n" | sudo -S cp extras/hosts /var/lib/waydroid/overlay/system/etc

	# copy nodataperm.sh - this is to fix the scoped storage issue in Android 11
	chmod +x extras/nodataperm.sh
	echo -e "$current_password\n" | sudo -S cp extras/nodataperm.sh /var/lib/waydroid/overlay/system/etc

	Choice=$(zenity --width 1040 --height 300 --list --radiolist --multiple \
		--title "SteamOS Waydroid Installer  - https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer"\
		--column "Select One" \
		--column "Option" \
		--column="Description - Read this carefully!"\
		TRUE A11_GAPPS "Download Android 11 image with Google Play Store."\
		FALSE A11_NO_GAPPS "Download Android 11 image without Google Play Store."\
		FALSE A13_NO_GAPPS "Download Android 13 image without Google Play Store."\
		FALSE TV11_NO_GAPPS "Download Android 11 TV image without Google Play Store - thanks SupeChicken666 for the build instructions!" \
		FALSE TV13_NO_GAPPS "Download Android 13 TV image without Google Play Store - thanks SupeChicken666 for the build instructions!" \
		FALSE EXIT "***** Exit this script *****")

		if [ $? -eq 1 ] || [ "$Choice" == "EXIT" ]
		then
			echo User pressed CANCEL / EXIT. Goodbye!
			cleanup_exit

		elif [ "$Choice" == "A11_GAPPS" ]
		then
			echo Initializing Waydroid
			echo -e "$current_password\n" | sudo -S waydroid init -s GAPPS
			check_waydroid_init

			echo Install libndk, widevine and fingerprint spoof
			install_android_extras
			
			echo Applying appropriate spoof
			install_android_spoof

		elif [ "$Choice" == "A11_NO_GAPPS" ]
		then
			echo Initializing Waydroid
			echo -e "$current_password\n" | sudo -S waydroid init
			check_waydroid_init

			echo Install libndk, widevine and fingerprint spoof
			install_android_extras
			
			echo Applying appropriate spoof
			install_android_spoof

		elif [ "$Choice" == "TV11_NO_GAPPS" ]
		then
			prepare_custom_image_location
			download_image $ANDROID11_TV_IMG $ANDROID11_TV_IMG_HASH ~/waydroid/custom/android11tv "Android 11 TV"

			echo Applying fix for Leanback Keyboard
			echo -e "$current_password\n" | sudo -S cp extras/ATV-Generic.kl /var/lib/waydroid/overlay/system/usr/keylayout/Generic.kl

			echo Initializing Waydroid
 			echo -e "$current_password\n" | sudo -S waydroid init
			check_waydroid_init

			echo Applying appropriate spoof
			install_android_spoof

		elif [ "$Choice" == "TV13_NO_GAPPS" ]
		then
			prepare_custom_image_location
			download_image $ANDROID13_TV_IMG $ANDROID13_TV_IMG_HASH ~/waydroid/custom/android13tv "Android 13 TV"

			echo Applying fix for Leanback Keyboard
			echo -e "$current_password\n" | sudo -S cp extras/ATV-Generic.kl /var/lib/waydroid/overlay/system/usr/keylayout/Generic.kl

			echo Initializing Waydroid
 			echo -e "$current_password\n" | sudo -S waydroid init
			check_waydroid_init
			
			echo Applying appropriate spoof
			install_android_spoof

		elif [ "$Choice" == "A13_NO_GAPPS" ]
		then
			prepare_custom_image_location
			download_image $ANDROID13_IMG $ANDROID13_IMG_HASH ~/waydroid/custom/android13 "Android 13"

			echo Initializing Waydroid
 			echo -e "$current_password\n" | sudo -S waydroid init
			check_waydroid_init
			
			echo Applying appropriate spoof
			install_android_spoof
		fi

	# change GPU rendering to use minigbm_gbm_mesa
	echo -e $PASSWORD\n | sudo -S sed -i "s/ro.hardware.gralloc=.*/ro.hardware.gralloc=minigbm_gbm_mesa/g" /var/lib/waydroid/waydroid_base.prop

	echo Adding shortcuts to Game Mode. Please wait.
	steamos-add-to-steam /home/deck/Android_Waydroid/Android_Waydroid_Cage.sh  &> /dev/null
	sleep 15
	echo Android_Waydroid_Cage.sh shortcut has been added to Game Mode.
	steamos-add-to-steam /usr/bin/steamos-nested-desktop  &> /dev/null
	sleep 15
	echo steamos-nested-desktop shortcut has been added to Game Mode.

	# all done lets re-enable the readonly
	echo -e "$current_password\n" | sudo -S steamos-readonly enable
	echo Waydroid has been successfully installed!
fi

# sanity check - re-enable decky loader service if it's installed.
if [ -f $PLUGIN_LOADER ]
then
	echo Re-enabling the Decky Loader plugin loader service.
	echo -e "$current_password\n" | sudo -S systemctl start plugin_loader.service
fi

if zenity --question --text="Do you Want to Return to Gaming Mode?"; then
	qdbus org.kde.Shutdown /Shutdown org.kde.Shutdown.logout
fi
