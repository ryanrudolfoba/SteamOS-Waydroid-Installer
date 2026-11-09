#!/bin/bash

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

# sanity check - make sure this is running on supported kernel 6.18.50-valve2-1-neptune-618. This is SteamOS 3.8.28
# Valve removed binder support in kernel so we need to rely on kmods again :(
if [ $KERNEL_VERSION = $COMPAT_KERNEL ]
then
	echo SteamOS $STEAMOS_VERSION detected running on kernel version $KERNEL_VERSION.
	echo This configuration is SUPPORTED! Proceed to the next step.
else
	echo SteamOS $STEAMOS_VERSION detected running on kernel version $KERNEL_VERSION.
	echo The script needs the kernel version $COMPAT_KERNEL for the binder kernel module and root kernel module.
	echo This configuration is NOT SUPPORTED. Exit immediately.
	exit
fi

# sanity check - make sure there is enough free space in the home partition (at least 10GB)
echo Checking if home partition has enough free space
echo home partition has $FREE_HOME free space.
if [ $FREE_HOME -ge 10000000 ]
then
	echo home partition has enough free space.
else
	echo Not enough space on the home partition!
	echo Make sure that there is at least 10GB free space on the home partition!
	exit
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
systemctl is-active --quiet plugin_loader.service
if [ $? -eq 0 ]
then
	echo Decky Loader detected! This may cause issues with the SteamOS Waydroid installer script!
	echo Temporary disabling the Decky Loader plugin loader service.
	echo -e "$current_password\n" | sudo -S systemctl stop plugin_loader.service

	if [ $? -eq 0 ]
	then
		DECKY_LOADER_STOPPED=true
		echo Decky Loader Plugin Loader service successfully disabled.
		echo It will be automatically re-enabled once the installer finishes.
	else
		echo Error ecountered when stopping the Decky Loader Plugin Loader service.
		echo Exiting immediately.
		exit
	fi
fi

#  santy check - is there pacman lock file?
if [ -f /usr/lib/holo/pacmandb/db.lck ]
then
	echo pacman lock file exists!
	echo Script will be unable to perform pacman operations because the lock file exists!
	echo Exiting immediately.
	exit
fi

