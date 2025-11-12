#!/bin/bash

clear

echo SteamOS Waydroid Installer Script by ryanrudolf
echo https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer
echo YT - 10MinuteSteamDeckGamer
sleep 2

# define variables here
script_version_sha=$(git rev-parse --short HEAD)
steamos_version=$(cat /etc/os-release | grep -i version_id | cut -d "=" -f2)
WORKING_DIR=$(pwd)
LOGFILE=$WORKING_DIR/logfile
BINDER_AUR=https://aur.archlinux.org/binder_linux-dkms.git
BINDER_GITHUB=https://github.com/archlinux/aur.git
BINDER_DIR=$(mktemp -d)/aur_binder
WAYDROID_SCRIPT=https://github.com/casualsnek/waydroid_script.git
WAYDROID_SCRIPT_DIR=$(mktemp -d)/waydroid_script
FREE_HOME=$(df /home --output=avail | tail -n1)
FREE_VAR=$(df /var --output=avail | tail -n1)

# android TV builds
ANDROID13_TV_IMG=https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer/releases/download/Android13TV/lineage-20-20250117-UNOFFICIAL-10MinuteSteamDeckGamer-WaydroidATV.zip

# android TV hash
ANDROID13_TV_IMG_HASH=2ac5d660c3e32b8298f5c12c93b1821bc7ccefbd7cfbf5fee862e169aa744f4c

echo script version: $script_version_sha

# define functions here
source functions.sh

# run the sanity checks
source sanity-checks.sh

# sanity checks are all good. lets go!
# create AUR directory where casualsnek script will be saved
mkdir -p ~/AUR/waydroid &> /dev/null

# perform git clone of waydroid_script and binder kernel module source
echo Cloning casualsnek / aleasto waydroid_script repo and binder kernel module source repo.
echo This can take a few minutes depending on the speed of the internet connection and if github is having issues.
echo If the git clone is slow - cancel the script \(CTL-C\) and run it again.

git clone --depth=1 $WAYDROID_SCRIPT $WAYDROID_SCRIPT_DIR &> /dev/null && \
git clone $BINDER_AUR $BINDER_DIR &> /dev/null
if [[ $? -ne 0 ]]; then
	echo "AUR repo failed, falling back to GitHub mirror."
	git clone --branch binder_linux-dkms --single-branch $BINDER_GITHUB $BINDER_DIR &> /dev/null
fi

if [[ $? -eq 0 ]]
then
	echo Repo has been successfully cloned! Proceed to the next step.
else
	echo Error cloning the repo!
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

# lets install the packages needed to build binder
echo Installing packages needed to build binder module from source. This can take a while.
echo "*** pacman install dependencies for binder ***" &>> $LOGFILE
echo -e "$current_password\n" | sudo -S pacman -S --noconfirm fakeroot debugedit dkms plymouth \
	linux-neptune-$(uname -r | cut -d "-" -f5)-headers --overwrite "*" &>> $LOGFILE

if [ $? -eq 0 ]
then
	echo No errors encountered installing packages needed to build binder module.
else
	echo Errors were encountered.
	echo Performing clean up. Good bye!
	cleanup_exit
	exit
fi

# finally lets build and install binder from source!
echo Building and installing binder module from source. This can take a while.
echo "*** build and install binder from source ***" &>> $LOGFILE
cd $BINDER_DIR && makepkg -f &>> $LOGFILE && \
	echo -e "$current_password\n" | sudo -S pacman -U --noconfirm binder_linux-dkms*.zst &>> $LOGFILE && \
	echo -e "$current_password\n" | sudo -S modprobe binder_linux device=binder,hwbinder,vndbinder &>> $LOGFILE

if [ $? -eq 0 ]
then
	echo No errors encountered building the binder module. Binder module has been loaded.
else
	echo Errors were encountered.
	echo Performing clean up. Good bye!
	cleanup_exit
	exit
fi

# ok lets install precompiled waydroid
echo Installing waydroid packages. This can take a while.
echo "*** pacman install waydroid packages ***" &>> $LOGFILE
cd $WORKING_DIR
echo -e "$current_password\n" | sudo -S pacman -U --noconfirm waydroid/libgbinder*.zst waydroid/libglibutil*.zst \
	waydroid/python-gbinder*.zst waydroid/waydroid*.zst &>> $LOGFILE && \

# ok lets install additional packages from pacman repo
echo -e "$current_password\n" | sudo -S pacman -S --noconfirm wlroots cage wlr-randr &>> $LOGFILE

if [ $? -eq 0 ]
then
	echo waydroid and cage has been installed!
	echo -e "$current_password\n" | sudo -S systemctl disable waydroid-container.service
else
	echo Error installing waydroid and cage. Run the script again to install waydroid.
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
mkdir ~/Android_Waydroid &> /dev/null

# waydroid binder configuration file
echo -e "$current_password\n" | sudo -S cp extras/waydroid_binder.conf /etc/modules-load.d/waydroid_binder.conf
echo -e "$current_password\n" | sudo -S cp extras/options-waydroid_binder.conf /etc/modprobe.d/waydroid_binder.conf

# waydroid startup and shutdown scripts
echo -e "$current_password\n" | sudo -S cp extras/waydroid-startup-scripts /usr/bin/waydroid-startup-scripts
echo -e "$current_password\n" | sudo -S cp extras/waydroid-shutdown-scripts /usr/bin/waydroid-shutdown-scripts
echo -e "$current_password\n" | sudo -S chmod +x /usr/bin/waydroid-startup-scripts /usr/bin/waydroid-shutdown-scripts

# custom sudoers file do not ask for sudo for the custom waydroid scripts
echo -e "$current_password\n" | sudo -S cp extras/zzzzzzzz-waydroid /etc/sudoers.d/zzzzzzzz-waydroid
echo -e "$current_password\n" | sudo -S chown root:root /etc/sudoers.d/zzzzzzzz-waydroid

# waydroid launcher, toolbox and updater
cp extras/Android_Waydroid_Cage.sh extras/Waydroid-Toolbox.sh extras/Waydroid-Updater.sh ~/Android_Waydroid
chmod +x ~/Android_Waydroid/*.sh

# Dolphin File Manager extension for root access
mkdir -p ~/.local/share/kio/servicemenus
cp extras/open_as_root.desktop ~/.local/share/kio/servicemenus
chmod +x ~/.local/share/kio/servicemenus/open_as_root.desktop

# desktop shortcuts for toolbox + updater
ln -s ~/Android_Waydroid/Waydroid-Toolbox.sh ~/Desktop/Waydroid-Toolbox &> /dev/null
ln -s ~/Android_Waydroid/Waydroid-Updater.sh ~/Desktop/Waydroid-Updater &> /dev/null

# lets check if this is a reinstall
grep redfin /var/lib/waydroid/waydroid_base.prop &> /dev/null || grep PH7M_EU_5596 /var/lib/waydroid/waydroid_base.prop &> /dev/null
if [ $? -eq 0 ]
then
	echo This seems to be a reinstall. Lets just make sure the symlinks are in place!
	if [ ! -d /etc/waydroid-extra ]
	then
		echo -e "$current_password\n" | sudo -S mkdir /etc/waydroid-extra
		echo -e "$current_password\n" | sudo -S ln -s ~/waydroid/custom /etc/waydroid-extra/images &> /dev/null
	fi

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

	# download custom hosts file from StevenBlack to block ads (adware + malware + fakenews + gambling + pr0n)
	echo -e "$current_password\n" | sudo -S wget https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn/hosts \
		       -O /var/lib/waydroid/overlay/system/etc/hosts

	Choice=$(zenity --width 1040 --height 320 --list --radiolist --multiple \
		--title "SteamOS Waydroid Installer  - https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer"\
		--column "Select One" \
		--column "Option" \
		--column="Description - Read this carefully!"\
		TRUE A13_GAPPS "Download official Android 13 image with Google Play Store."\
		FALSE A13_NO_GAPPS "Download official Android 13 image without Google Play Store."\
		FALSE TV13_NO_GAPPS "Download unofficial Android 13 TV image without Google Play Store - thanks SupeChicken666 for the build instructions!" \
		FALSE EXIT "***** Exit this script *****")

		if [ $? -eq 1 ] || [ "$Choice" == "EXIT" ]
		then
			echo User pressed CANCEL / EXIT. Goodbye!
			cleanup_exit

		elif [ "$Choice" == "A13_GAPPS" ]
		then
			echo Initializing Waydroid.
			echo -e "$current_password\n" | sudo -S waydroid init -s GAPPS
			check_waydroid_init

		elif [ "$Choice" == "A13_NO_GAPPS" ]
		then
			echo Initializing Waydroid.
			echo -e "$current_password\n" | sudo -S waydroid init
			check_waydroid_init

		elif [ "$Choice" == "TV13_NO_GAPPS" ]
		then
			prepare_custom_image_location
			download_image $ANDROID13_TV_IMG $ANDROID13_TV_IMG_HASH ~/waydroid/custom/android13tv "Android 13 TV"

			echo Applying fix for Leanback Keyboard.
			echo -e "$current_password\n" | sudo -S cp extras/ATV-Generic.kl /var/lib/waydroid/overlay/system/usr/keylayout/Generic.kl

			echo Initializing Waydroid.
 			echo -e "$current_password\n" | sudo -S waydroid init
			check_waydroid_init
			
		fi
	
	# run casualsnek / aleasto waydroid_script
	echo Install libndk, widevine and fingerprint spoof.
	install_android_extras

	# change GPU rendering to use minigbm_gbm_mesa
	echo -e $PASSWORD\n | sudo -S sed -i "s/ro.hardware.gralloc=.*/ro.hardware.gralloc=minigbm_gbm_mesa/g" /var/lib/waydroid/waydroid_base.prop

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
fi

# all done! Display dialog box for Gaming Mode
if zenity --question --text="Do you Want to Return to Gaming Mode?"; then
	qdbus org.kde.Shutdown /Shutdown org.kde.Shutdown.logout
fi
