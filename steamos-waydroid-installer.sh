#!/bin/bash

clear

echo SteamOS Waydroid Installer Script by ryanrudolf
echo https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer
echo YT - 10MinuteSteamDeckGamer
sleep 2

# define variables here
steamos_version=$(cat /etc/os-release | grep -i version_id | cut -d "=" -f2)
kernel_version=$(uname -r | cut -d "-" -f 1-5 )
stable_kernel1=6.1.52-valve16-1-neptune-61
stable_kernel2=6.5.0-valve22-1-neptune-65
beta_kernel1=6.5.0-valve23-1-neptune-65
AUR_CASUALSNEK=https://github.com/casualsnek/waydroid_script.git
AUR_CASUALSNEK2=https://github.com/ryanrudolfoba/waydroid_script.git
DIR_CASUALSNEK=~/AUR/waydroid/waydroid_script
ANDROID_TV_IMG=https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer/releases/download/Android11TV/lineage-18.1-20241220-UNOFFICIAL-10MinuteSteamDeckGamer-WaydroidATV.zip
ANDROID_TV_IMG_MD5=4b0236af2d83164135d86872e27ce6af
STEAMOS_VERSION=$(grep VERSION_ID /etc/os-release | cut -d "=" -f 2)
FREE_HOME=$(df /home --output=avail | tail -n1)
FREE_VAR=$(df /var --output=avail | tail -n1)
MicroG=FALSE

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
	echo Cleanup completed. Please open an issue on the GitHub repo or leave a comment on the YT channel - 10MinuteSteamDeckGamer.
	exit
}

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
grep redfin /var/lib/waydroid/waydroid_base.prop &> /dev/null
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

# disable the SteamOS readonly
echo -e "$current_password\n" | sudo -S steamos-readonly disable

# initialize the keyring
echo -e "$current_password\n" | sudo -S pacman-key --init && echo -e "$current_password\n" | sudo -S pacman-key --populate

if [ $? -eq 0 ]
then
	echo pacman keyring has been initialized!
else
	echo Error initializing keyring! Run the script again to install waydroid.
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

# waydroid launcher - cage
cp extras/Android_Waydroid_Cage.sh ~/Android_Waydroid/Android_Waydroid_Cage.sh


# custom configs done. lets move them to the correct location
cp $PWD/extras/Waydroid-Toolbox.sh $PWD/extras/Android_Waydroid_Cage-experimental.sh ~/Android_Waydroid
chmod +x ~/Android_Waydroid/*.sh
ln -s ~/Android_Waydroid/Waydroid-Toolbox.sh ~/Desktop/Waydroid-Toolbox &> /dev/null

# lets copy cage and wlr-randr to the correct folder
echo -e "$current_password\n" | sudo -S cp cage/cage cage/wlr-randr /usr/bin
echo -e "$current_password\n" | sudo -S chmod +x /usr/bin/cage /usr/bin/wlr-randr

# lets check if this is a reinstall
grep redfin /var/lib/waydroid/waydroid_base.prop &> /dev/null
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
	mkdir -p ~/waydroid/{images,cache_http,host-permissions,lxc,overlay,overlay_rw,rootfs}
	echo -e "$current_password\n" | sudo mkdir /var/lib/waydroid &> /dev/null
	echo -e "$current_password\n" | sudo -S ln -s ~/waydroid/images /var/lib/waydroid/images &> /dev/null
	echo -e "$current_password\n" | sudo -S ln -s ~/waydroid/cache_http /var/lib/waydroid/cache_http &> /dev/null
    echo -e "$current_password\n" | sudo -S ln -s ~/waydroid/overlay /var/lib/waydroid/overlay &> /dev/null
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


	Choice=$(zenity --width 750 --height 240 --list --radiolist --multiple \
		--title "SteamOS Waydroid Installer  - https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer"\
		--column "Select One" \
		--column "Option" \
		--column="Description - Read this carefully!"\
		TRUE GAPPS "Download Android image with Google Play Store."\
		FALSE NO_GAPPS "Download Android image without Google Play Store."\
		FALSE TV "Download Android TV image - thanks SupeChicken666!" \
		FALSE EXIT "***** Exit this script *****")

		if [ $? -eq 1 ] || [ "$Choice" == "EXIT" ]
		then
			echo User pressed CANCEL / EXIT. Goodbye!
			cleanup_exit

		elif [ "$Choice" == "GAPPS" ]
		then
			echo -e "$current_password\n" | sudo -S waydroid init -s GAPPS

		elif [ "$Choice" == "NO_GAPPS" ]
		then
			echo -e "$current_password\n" | sudo -S waydroid init

		elif [ "$Choice" == "TV" ]
		then
			echo Android TV chosen!
			echo Initializing Waydroid
			echo -e "$current_password\n" | sudo -S waydroid init
			echo Downloading Android TV image
            echo -e "$current_password\n" | sudo -S curl -o ~/waydroid/images/androidtv.zip $ANDROID_TV_IMG -L
			hash=$(md5sum "/home/deck/waydroid/images/androidtv.zip" | awk '{print $1}')
			# Verify the MD5 hash
			if [[ "$hash" == "$ANDROID_TV_IMG_MD5" ]]; then
  				echo "'/home/deck/waydroid/images/androidtv.zip': MD5 hash verified."
			else
  				echo "'/home/deck/waydroid/images/androidtv.zip': MD5 hash mismatch."
			fi
			echo Extracting Archive
			echo -e "$current_password\n" | sudo -S unzip -o ~/waydroid/images/androidtv -d ~/waydroid/images
			echo -e "$current_password\n" | sudo -S rm ~/waydroid/images/androidtv.zip
			echo Reinitializing Waydroid
			echo -e "$current_password\n" | sudo -S waydroid init -f

			# install MicroG and Aurora Store if desired
			if zenity --question --text="Install MicroG and Aurora Store"; then
				MicroG=TRUE
				echo -e "$current_password\n" | sudo -S mkdir ~/waydroid/apks
				echo -e "$current_password\n" | sudo -S curl -L -o ~/waydroid/apks/com.google.android.gms-244735012.apk https://github.com/microg/GmsCore/releases/download/v0.3.6.244735/com.google.android.gms-244735012.apk
				echo -e "$current_password\n" | sudo -S curl -L -o ~/waydroid/apks/AuroraStore-4.6.4.apk https://auroraoss.com/downloads/AuroraStore/Release/AuroraStore-4.6.4.apk
				konsole -e bash /home/deck/Android_Waydroid/Android_Waydroid_Cage.sh &
				sleep 30
				waydroid app install ~/waydroid/apks/AuroraStore-4.6.4.apk
				sleep 40
		     	echo "$current_password\n" | sudo -S waydroid container stop

            else
            	echo OK!
            fi

		fi

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

	# casualsnek script
	echo -e "$current_password\n" | sudo -S pacman -Sy --noconfirm lzip
	python3 -m venv $DIR_CASUALSNEK/venv
	$DIR_CASUALSNEK/venv/bin/pip install -r $DIR_CASUALSNEK/requirements.txt &> /dev/null
	echo -e "$current_password\n" | sudo -S $DIR_CASUALSNEK/venv/bin/python3 $DIR_CASUALSNEK/main.py install {libndk,widevine}
	if [ "$MicroG" == "TRUE" ]; then
     echo -e "$current_password\n" | sudo -S "$DIR_CASUALSNEK/venv/bin/python3" "$DIR_CASUALSNEK/main.py" install microg
    fi
	if [ $? -eq 0 ]
	then
		echo Casualsnek script done.
		echo -e "$current_password\n" | sudo -S rm -rf ~/AUR
	else
		echo Error with casualsnek script. Run the script again.
		cleanup_exit
	fi

	# change GPU rendering to use minigbm_gbm_mesa
	echo -e $PASSWORD\n | sudo -S sed -i "s/ro.hardware.gralloc=.*/ro.hardware.gralloc=minigbm_gbm_mesa/g" /var/lib/waydroid/waydroid_base.prop

	# lets change the fingerprint so waydroid shows up as a Pixel 5 - Redfin
	{ echo -e "$current_password\n" ; cat extras/waydroid_base.prop ; } | sudo -S tee -a /var/lib/waydroid/waydroid_base.prop

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

if zenity --question --text="Do you Want to Return to Gaming Mode?"; then
	qdbus org.kde.Shutdown /Shutdown org.kde.Shutdown.logout
fi
