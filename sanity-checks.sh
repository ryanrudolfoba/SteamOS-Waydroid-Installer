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

# sanity check - make sure kernel version is supported. exit immediately if not on the supported kernel
echo Checking if kernel is supported.
if [ $kernel_version = $stable_kernel1 ] || [ $kernel_version = $beta_kernel1 ]
then
	echo SteamOS $steamos_version - kernel version $kernel_version is supported. Proceed to next step.
else
	echo SteamOS $steamos_version - kernel version $kernel_version is NOT supported. Please wait for update from 10MinuteSteamDeckGamer. Check the github repo for updates.  Exiting immediately.
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
grep redfin /var/lib/waydroid/waydroid_base.prop &> /dev/null || grep PH7M_EU_5596 /var/lib/waydroid/waydroid_base.prop &> /dev/null
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

