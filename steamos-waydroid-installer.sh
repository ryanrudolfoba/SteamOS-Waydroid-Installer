#!/bin/bash

clear

echo SteamOS Waydroid Installer Script by ryanrudolf
echo https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer
echo YT - 10MinuteSteamDeckGamer
sleep 2

# define variables here
SCRIPT_VERSION_SHA=$(git rev-parse --short HEAD)
STEAMOS_VERSION=$(cat /etc/os-release | grep -i version_id | cut -d "=" -f2 | cut -d "." -f1-3)
KERNEL_VERSION=$(uname -r | cut -d "-" -f 1-5 )
COMPAT_KERNEL=7.2.7-valve2-2-neptune-72
WORKING_DIR=$(pwd)
LOGFILE=$WORKING_DIR/logfile
WAYDROID_SCRIPT=https://github.com/casualsnek/waydroid_script.git
WAYDROID_SCRIPT_DIR=$(mktemp -d)/waydroid_script
FREE_HOME=$(df /home --output=avail | tail -n1)
ARM_Choice=libhoudini

# android TV builds
ANDROID13_TV_OTA=https://ota.supechicken666.dev

# custom Android 13 builds
ANDROID13_IMG=https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer/releases/download/Android13-PvZ2/lineage-20-20251210-UNOFFICIAL-10MinuteSteamDeckGamer-Waydroid.zip

# custom Android 13 hash
ANDROID13_IMG_HASH=aafdd4ef69e8a11d64ba02e881c1697d6a3ee4fa4c1fb97e33abc6da5f4bb6d4

echo script version: $SCRIPT_VERSION_SHA

# define functions here
source functions.sh

# run the sanity checks
source sanity-checks.sh

# sanity checks are all good. lets go!

# perform git clone of waydroid_script
echo Cloning casualsnek / aleasto waydroid_script repo.
echo This can take a few minutes depending on the speed of the internet connection and if github is having issues.
echo If the git clone is slow - cancel the script \(CTL-C\) and run it again.

git clone --depth=1 $WAYDROID_SCRIPT $WAYDROID_SCRIPT_DIR &> /dev/null
if [ $? -eq 0 ]
then
	echo Repo has been successfully cloned! Proceed to the next step.
else
	echo Error cloning the casualsnek / aleasto waydroid_script repo!
	rm -rf $WAYDROID_SCRIPT_DIR
	cleanup_exit
fi

# unlock the readonly and initialize keyring using the devmode method
echo Unlocking SteamOS and initializing keyring via steamos-devmode. This can take a while.
echo "*** steamos-devmode ***" &> $LOGFILE
echo -e "$current_password\n" | sudo -S steamos-devmode enable --no-prompt &>> $LOGFILE

if [ $? -eq 0 ]
then
	echo pacman keyring has been initialized!
else
	echo Error initializing keyring!
	cleanup_exit
fi

# lets install KernelSU kernel module for root
kernelsu_differs=$(cmp -s extras/kernelsu/$KERNEL_VERSION/kernelsu.ko.zst /lib/modules/$(uname -r)/kernelsu.ko.zst; echo $?)
if [ "$kernelsu_differs" -ne 0 ]
then
	echo KernelSU kernel module not found or not up to date! Installing KernelSU!
	echo -e "$current_password\n" | sudo -S cp extras/kernelsu/$KERNEL_VERSION/kernelsu.ko.zst /lib/modules/$(uname -r) && \
	echo -e "$current_password\n" | sudo -S cp extras/kernelsu/$KERNEL_VERSION/load-kernelsu /usr/bin/load-kernelsu && \
	echo -e "$current_password\n" | sudo -S cp extras/kernelsu/$KERNEL_VERSION/kernelsu-loader /usr/bin/kernelsu-loader && \
	echo -e "$current_password\n" | sudo -S pacman -U --noconfirm extras/kernelsu/$KERNEL_VERSION/modloader-2.0.0-1-x86_64.pkg.tar.zst --overwrite "*" && \
	echo -e "$current_password\n" | sudo -S depmod -a

	if [ $? -eq 0 ]
	then
		echo KernelSU kernel module has been installed!
	else
		echo Error installing KernelSU kernel module.
		cleanup_exit
	fi
else
	echo KernelSU kernel module already loaded and up to date! No need to install KernelSU!
fi

# ok lets install waydroid
# starting SteamOS3.9.5 waydroid and its dependencies are in the repos
# no need for precompiled binaries anymore!
echo Installing waydroid packages. This can take a while.
echo "*** pacman install waydroid packages ***" &>> $LOGFILE
echo -e "$current_password\n" | sudo -S pacman -S --noconfirm waydroid cage wlr-randr --overwrite "*" &>> $LOGFILE 

if [ $? -eq 0 ]
then
	echo Waydroid and its dependencies has been installed!
	echo -e "$current_password\n" | sudo -S systemctl disable waydroid-container.service
else
	echo Error installing waydroid. Run the script again to install waydroid.
	cleanup_exit
fi

# firewall config for waydroid0 interface to forward packets for internet to work
# but first lets enable firewalld - some instance of SteamOS this is disabled / stopped?
echo -e "$current_password\n" | sudo -S systemctl start firewalld
echo -e "$current_password\n" | sudo -S firewall-cmd --zone=trusted --add-interface=waydroid0 &> /dev/null
echo -e "$current_password\n" | sudo -S firewall-cmd --zone=trusted --add-port={53,67}/udp &> /dev/null
echo -e "$current_password\n" | sudo -S firewall-cmd --zone=trusted --add-forward &> /dev/null
echo -e "$current_password\n" | sudo -S firewall-cmd --runtime-to-permanent &> /dev/null
echo -e "$current_password\n" | sudo -S systemctl stop firewalld

# lets install the custom config files
mkdir -p ~/Android_Waydroid/config &> /dev/null

# waydroid startup and shutdown scripts
echo -e "$current_password\n" | sudo -S cp extras/scripts/waydroid-startup-scripts /usr/bin/waydroid-startup-scripts
echo -e "$current_password\n" | sudo -S cp extras/scripts/waydroid-shutdown-scripts /usr/bin/waydroid-shutdown-scripts
echo -e "$current_password\n" | sudo -S cp extras/scripts/waydroid-mount /usr/bin/waydroid-mount
echo -e "$current_password\n" | sudo -S cp extras/scripts/waydroid-binder /usr/bin/waydroid-binder
echo -e "$current_password\n" | sudo -S cp extras/scripts/waydroid-firewall /usr/bin/waydroid-firewall
echo -e "$current_password\n" | sudo -S chmod +x /usr/bin/waydroid-startup-scripts /usr/bin/waydroid-shutdown-scripts /usr/bin/waydroid-mount /usr/bin/waydroid-firewall /usr/bin/waydroid-binder

# custom sudoers file do not ask for sudo for the custom waydroid scripts
echo -e "$current_password\n" | sudo -S cp extras/zzzzzzzz-waydroid /etc/sudoers.d/zzzzzzzz-waydroid
echo -e "$current_password\n" | sudo -S chown root:root /etc/sudoers.d/zzzzzzzz-waydroid

# copy waydroid launcher dependencies
cp extras/scripts/Android_Waydroid_Cage.sh extras/scripts/Waydroid-Toolbox.sh extras/scripts/Waydroid-Updater.sh ~/Android_Waydroid
cp -R extras/config ~/Android_Waydroid

# waydroid launcher, toolbox and updater
chmod +x ~/Android_Waydroid/*.sh

# Dolphin File Manager extension for root access
mkdir -p ~/.local/share/kio/servicemenus
cp extras/open_as_root.desktop ~/.local/share/kio/servicemenus
chmod +x ~/.local/share/kio/servicemenus/open_as_root.desktop

# desktop shortcuts for toolbox + updater
ln -s ~/Android_Waydroid/Waydroid-Toolbox.sh ~/Desktop/Waydroid-Toolbox &> /dev/null
ln -s ~/Android_Waydroid/Waydroid-Updater.sh ~/Desktop/Waydroid-Updater &> /dev/null


# lets check if this is a reinstall
echo Checking if this is a reinstall - step1.
if [ -d /var/lib/waydroid ]
then
	echo /var/lib/waydroid exists! 
else
	sudo -S mkdir /var/lib/waydroid
fi

echo Checking if this is a reinstall - step2.
if [ -f $HOME/Android_Waydroid/waydroid.img ]
then
	echo Most probably this is a reinstall!
	echo Mounting waydroid.img to /var/lib/waydroid
	ROOTDEV=$(sudo losetup --find --show $HOME/Android_Waydroid/waydroid.img) && sudo mount $ROOTDEV /var/lib/waydroid

	if [ $? -eq 0 ]
	then
		echo waydroid.img successfully mounted to /var/lib/waydroid
	else
		echo Error mounting waydroid.img
		echo Exiting immediately.
		cleanup_exit
	fi
else
	echo waydroid.img not found!
	echo Preparing to mount waydroid.img
	mount_waydroid_var

	if [ $? -eq 0 ]
	then
		echo Custom /var/lib/waydroid has been created and mounted!
	else
		echo Error creating /var/lib/waydroid. Exiting immediately.
		cleanup_exit
	fi
fi

echo Checking if this is a reinstall - step3.
grep blazer /var/lib/waydroid/waydroid_base.prop &> /dev/null || grep PH7M_EU_5596 /var/lib/waydroid/waydroid_base.prop &> /dev/null
if [ $? -eq 0 ]
then
	echo This seems to be a reinstall. Lets just make sure the symlinks are in place!
	if [ ! -d /etc/waydroid-extra ]
	then
		echo -e "$current_password\n" | sudo -S mkdir /etc/waydroid-extra
		echo -e "$current_password\n" | sudo -S ln -s /var/lib/waydroid/custom /etc/waydroid-extra/images &> /dev/null
	fi

	# all done lets re-enable the readonly
	echo -e "$current_password\n" | sudo -S steamos-readonly enable
	echo Waydroid has been successfully installed!
else
	echo Downloading waydroid image from sourceforge.
	echo This can take a few seconds to a few minutes depending on the internet connection and the speed of the sourceforge mirror.
	echo Sometimes it connects to a slow sourceforge mirror and the downloads are slow -. This is beyond my control!
	echo If the downloads are slow due to a slow sourceforge mirror - cancel the script \(CTL-C\) and run it again.

	# place custom overlay files here - key layout, hosts, audio.rc etc etc
	# copy fixed key layout for Steam Controller
	echo -e "$current_password\n" | sudo -S mkdir -p /var/lib/waydroid/overlay/system/usr/keylayout
	echo -e "$current_password\n" | sudo -S cp extras/fixes/Vendor_28de_Product_11ff.kl /var/lib/waydroid/overlay/system/usr/keylayout/

	# copy custom audio.rc patch to lower the audio latency
	echo -e "$current_password\n" | sudo -S mkdir -p /var/lib/waydroid/overlay/system/etc/init
	echo -e "$current_password\n" | sudo -S cp extras/fixes/audio.rc /var/lib/waydroid/overlay/system/etc/init/

	# download custom hosts file from StevenBlack to block ads (adware + malware + fakenews + gambling + pr0n)
	echo -e "$current_password\n" | sudo -S wget https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn/hosts \
		       -O /var/lib/waydroid/overlay/system/etc/hosts

	Android_Choice=$(zenity --width 1040 --height 320 --list --radiolist --multiple \
		--title "SteamOS Waydroid Installer  - https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer"\
		--column "Select One" \
		--column "Option" \
		--column="Description - Read this carefully!"\
		TRUE A13_GAPPS "Download official Android 13 image with Google Play Store."\
		FALSE A13_NO_GAPPS "Download official Android 13 image without Google Play Store."\
		FALSE TV13_GAPPS "Download unofficial Android 13 TV image with Google Play Store - thanks SupeChicken666 for the image!" \
		FALSE TV13_NO_GAPPS "Download unofficial Android 13 TV image without Google Play Store - thanks SupeChicken666 for the image!" \
		FALSE EXIT "***** Exit this script *****")

		if [ $? -eq 1 ] || [ "$Android_Choice" == "EXIT" ]
		then
			echo User pressed CANCEL / EXIT. Goodbye!
			cleanup_exit

		elif [ "$Android_Choice" == "A13_GAPPS" ]
		then
			echo Initializing Waydroid.
			echo -e "$current_password\n" | sudo -S waydroid init -s GAPPS
			check_waydroid_init

		elif [ "$Android_Choice" == "A13_NO_GAPPS" ]
		then
			echo Initializing Waydroid.
			echo -e "$current_password\n" | sudo -S waydroid init
			check_waydroid_init

		elif [ "$Android_Choice" == "TV13_GAPPS" ]
		then
			echo Initializing Waydroid.
 			echo -e "$current_password\n" | sudo -S waydroid init -c ${ANDROID13_TV_OTA}/system -v ${ANDROID13_TV_OTA}/vendor -s GAPPS
			check_waydroid_init

		elif [ "$Android_Choice" == "TV13_NO_GAPPS" ]
		then
			echo Initializing Waydroid.
 			echo -e "$current_password\n" | sudo -S waydroid init -c ${ANDROID13_TV_OTA}/system -v ${ANDROID13_TV_OTA}/vendor
			check_waydroid_init
		fi

	# run casualsnek / aleasto waydroid_script
	echo Install $ARM_Choice widevine and fingerprint spoof.
	if [ "$Android_Choice" == "TV13_GAPPS" ] || [ "$Android_Choice" == "TV13_NO_GAPPS" ]
	then
		echo No need for casualsnek / aleasto waydroid_script for TV13 images.
		echo TV13 images already contains libhoudini arm translation layer and widevine.
	else
		install_android_extras
	fi

	# apply custom config for controller detection, root and fingerprint spoof
	apply_android_custom_config

	# change GPU rendering to use minigbm_gbm_mesa
	echo -e "$current_password\n" | sudo -S sed -i "s/ro.hardware.gralloc=.*/ro.hardware.gralloc=minigbm_gbm_mesa/g" /var/lib/waydroid/waydroid_base.prop

	echo "Adding shortcuts to Game Mode. Please wait..."

	logged_in_user=$(whoami)
	logged_in_home=$(eval echo "~$logged_in_user")
	launcher_script="${logged_in_home}/Android_Waydroid/Android_Waydroid_Cage.sh"
	icon_path="/usr/share/icons/hicolor/512x512/apps/waydroid.png"

	if [ -f "$launcher_script" ]; then
		chmod +x "$launcher_script"
	else
		echo "Error: Launcher script '$launcher_script' not found."
	fi

	TMP_DESKTOP="/tmp/waydroid-temp.desktop"
	cat > "$TMP_DESKTOP" << EOF
[Desktop Entry]
Name=Waydroid
Exec=${launcher_script}
Path=${logged_in_home}/Android_Waydroid
Type=Application
Terminal=false
Icon=application-default-icon
EOF

	chmod +x "$TMP_DESKTOP"
	steamos-add-to-steam "$TMP_DESKTOP"
	sleep 3
	rm -f "$TMP_DESKTOP"
	echo Waydroid shortcut has been added to Game Mode.

	# create icon for the Waydroid shortcut
	python3 extras/icon.py

	# add steamos-nested-desktop to Game Mode. This can be used when doing Waydroid maintenance.
	steamos-add-to-steam /usr/bin/steamos-nested-desktop  &> /dev/null
	sleep 3
	echo steamos-nested-desktop shortcut has been added to Game Mode.

	# all done lets re-enable the readonly
	echo -e "$current_password\n" | sudo -S steamos-readonly enable
	echo Waydroid has been successfully installed!

	# unmount the custom /var/lib/waydroid
	echo Unmounting the custom /var/lib/waydroid
	echo -e "$current_password\n" | sudo systemctl stop waydroid-container.service
	unmount_waydroid_var
	mv extras/waydroid.img ~/Android_Waydroid/waydroid.img
fi

# all done! Display dialog box for Gaming Mode
if zenity --question --text="Do you Want to Return to Gaming Mode?"; then
	qdbus org.kde.Shutdown /Shutdown org.kde.Shutdown.logout
fi
