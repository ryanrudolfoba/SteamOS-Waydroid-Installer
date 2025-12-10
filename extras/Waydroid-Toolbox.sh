#!/bin/bash
SCRIPT_PATH="$(readlink -f "$0")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"

# Source functions.sh (using absolute path)
source "$SCRIPT_DIR/functions.sh"

PASSWORD=$(zenity --password --title "sudo Password Authentication")
echo -e "$PASSWORD\n" | sudo -S ls &> /dev/null
if [ $? -ne 0 ]
then
	echo sudo password is wrong! | \
		zenity --text-info --title "Waydroid Toolbox" --width 400 --height 200
	exit
fi

while true
do
Choice=$(zenity --width 850 --height 400 --list --radiolist --multiple --title "Waydroid Toolbox for SteamOS Waydroid script  - https://github.com/ryanrudolfoba/steamos-waydroid-installer"\
	--column "Select One" \
	--column "Option" \
	--column="Description - Read this carefully!"\
	FALSE ADBLOCK "Disable or update the custom adblock hosts file."\
	FALSE AUDIO "Enable or disable the custom audio fixes."\
	FALSE SERVICE "Start or Stop the Waydroid container service."\
	FALSE GPU "Change the GPU config - GBM or MINIGBM."\
	FALSE LAUNCHER "Add Android Waydroid Cage launcher to Game Mode."\
	FALSE NETWORK "Reinitialize firewall configuration - use this when WIFI is not working."\
	FALSE ARM_LIB "Change Translation Layer, libhoudini or libndk"\
	FALSE UNINSTALL "Choose this to uninstall Waydroid and revert any changes made."\
	TRUE EXIT "***** Exit the Waydroid Toolbox *****")

if [ $? -eq 1 ] || [ "$Choice" == "EXIT" ]
then
	echo User pressed CANCEL / EXIT.
	exit
elif [ "$Choice" == "ARM_LIB" ]
then
	# Path to waydroid base
	CLEAR_PREVIOUS_ARM=$(sed -n 's/^ro\.dalvik\.vm\.native\.bridge=//p' "$HOME/.waydroid/waydroid_base.prop")
	
	if [ "$CLEAR_PREVIOUS_ARM" = "libndk_translation.so" ]; then
		CLEAR_PREVIOUS_ARM="libndk"
	elif [ "$CLEAR_PREVIOUS_ARM" = "libhoudini.so" ]; then
		CLEAR_PREVIOUS_ARM="libhoudini"
	fi

	OPTIONS=("libndk" "libhoudini" "MENU")
	OPT_DESCRIPTION=("libndk arm translation, better for AMD CPUs (Internet Connection Required)" "libhoudini arm translation, better for Intel CPUs (Internet Connection Required)" "***** BACK TO MENU *****")

	LIST=()
	for i in "${!OPTIONS[@]}"; do
		opt="${OPTIONS[$i]}"
		desc="${OPT_DESCRIPTION[$i]}"

		if [ "$opt" = "$CLEAR_PREVIOUS_ARM" ]; then
			LIST+=(TRUE "$opt" "$desc")
		else
			LIST+=(FALSE "$opt" "$desc")
		fi
	done

	ARM_Choice=$(zenity --width 900 --height 220 \
	--list --radiolist --multiple \
	--title "Waydroid Toolbox" \
	--column "Select One" --column "Option" --column="Description - Read this carefully!"\
    "${LIST[@]}")

	if [ $? -eq 1 ] || [ "$ARM_Choice" == "MENU" ]
	then
		echo User pressed MENU. Going back to main menu.
	elif [ "$ARM_Choice" == "libndk" ] || [ "$ARM_Choice" == "libhoudini" ]
 	then

		LOG_PIPE="/tmp/zenity_log.pipe"
		TMP_FOLDER="$(mktemp -d)"
		rm -f "$LOG_PIPE"
		mkfifo "$LOG_PIPE"

		# open Zenity text window to display logs
		zenity --text-info --title="Live Logs" --width=800 --height=400 --auto-scroll < "$LOG_PIPE" &

		# write logs to both console and Zenity
		exec > >(tee -a "$LOG_PIPE") 2>&1
		
		WAYDROID_SCRIPT=https://github.com/casualsnek/waydroid_script.git
		WAYDROID_SCRIPT_DIR=$TMP_FOLDER/waydroid_script
		Choice=$ARM_Choice
		# perform git clone of waydroid_script and binder kernel module source
		echo Cloning casualsnek / aleasto waydroid_script repo and binder kernel module source repo.
		echo This can take a few minutes depending on the speed of the internet connection and if github is having issues.
		echo If the git clone is slow - cancel the script \(CTL-C\) and run it again.

		git clone --depth=1 $WAYDROID_SCRIPT $WAYDROID_SCRIPT_DIR &> /dev/null && \

		if [[ $? -eq 0 ]]
		then
			echo Repo waydroid script has been successfully cloned! Proceed to the next step.
		else
			echo Error cloning the repo!
			rm -rf $WAYDROID_SCRIPT_DIR
		fi
		
		#located in function.sh
		INSTALLATION_METHOD=false
		
		CLEAR_PREVIOUS_ARM=$(sed -n 's/^ro\.dalvik\.vm\.native\.bridge=//p' "$HOME/.waydroid/waydroid_base.prop")
		if [ "$CLEAR_PREVIOUS_ARM" = "libndk_translation.so" ]; then
			CLEAR_PREVIOUS_ARM="libndk"
		elif [ "$CLEAR_PREVIOUS_ARM" = "libhoudini.so" ]; then
			CLEAR_PREVIOUS_ARM="libhoudini"
		fi
		# install casualsnek libhoudini/libndk
		install_android_extras "$Choice" "$CLEAR_PREVIOUS_ARM"

		#copy custom prop from this repo
		#TODO: need to check if android is using A13TV or A13_GAPPS
		ANDROID_INSTALL_CHOICE="A13_GAPPS"
		echo "Copying Android spoof custom config"
		copy_android_custom_config


		if [[ $? -eq 0 ]]
		then
			echo "ARM changed successfully to $ARM_Choice!"
		else
			echo "Error occured when changing ARM!"
		fi
		rm -f "$LOG_PIPE"
		rm -rf $WAYDROID_SCRIPT_DIR
		# Close the log pipe when finished
		exec >&-
fi
elif [ "$Choice" == "NETWORK" ]
then
	echo -e "$PASSWORD\n" | sudo -S systemctl start firewalld

# let's clear the existing config first
	echo -e "$PASSWORD\n" | sudo -S firewall-cmd --zone=trusted --remove-interface=waydroid0 &> /dev/null
	echo -e "$PASSWORD\n" | sudo -S firewall-cmd --zone=trusted --remove-port=53/udp &> /dev/null
	echo -e "$PASSWORD\n" | sudo -S firewall-cmd --zone=trusted --remove-port=67/udp &> /dev/null
	echo -e "$PASSWORD\n" | sudo -S firewall-cmd --zone=trusted --remove-forward &> /dev/null
	echo -e "$PASSWORD\n" | sudo -S firewall-cmd --runtime-to-permanent &> /dev/null

# firewall config for waydroid0 interface to forward packets for internet to work
	echo -e "$PASSWORD\n" | sudo -S firewall-cmd --zone=trusted --add-interface=waydroid0 &> /dev/null
	echo -e "$PASSWORD\n" | sudo -S firewall-cmd --zone=trusted --add-port=53/udp &> /dev/null
	echo -e "$PASSWORD\n" | sudo -S firewall-cmd --zone=trusted --add-port=67/udp &> /dev/null
	echo -e "$PASSWORD\n" | sudo -S firewall-cmd --zone=trusted --add-forward &> /dev/null
	echo -e "$PASSWORD\n" | sudo -S firewall-cmd --runtime-to-permanent &> /dev/null
	
	echo -e "$PASSWORD\n" | sudo -S systemctl stop firewalld

  	zenity --warning --title "Waydroid Toolbox" --text "Waydroid network configuration completed!" --width 350 --height 75

elif [ "$Choice" == "ADBLOCK" ]
then
ADBLOCK_Choice=$(zenity --width 600 --height 250 --list --radiolist --multiple --title "Waydroid Toolbox" --column "Select One" \
	--column "Option" --column="Description - Read this carefully!"\
	FALSE DISABLE "Disable the custom adblock hosts file."\
	FALSE ENABLE "Disable the custom adblock hosts file."\
	FALSE UPDATE "Update and enable the custom adblock hosts file."\
	TRUE MENU "***** Go back to Waydroid Toolbox Main Menu *****")

	if [ $? -eq 1 ] || [ "$ADBLOCK_Choice" == "MENU" ]
	then
		echo User pressed CANCEL. Going back to main menu.

	elif [ "$ADBLOCK_Choice" == "DISABLE" ]
	then
		# Disable the custom adblock hosts file
		echo -e "$PASSWORD\n" | sudo -S mv /var/lib/waydroid/overlay/system/etc/hosts /var/lib/waydroid/overlay/system/etc/hosts.disable &> /dev/null

		zenity --warning --title "Waydroid Toolbox" --text "Custom adblock hosts file has been disabled!" --width 350 --height 75

	elif [ "$ADBLOCK_Choice" == "ENABLE" ]
	then
		# Enable the custom adblock hosts file
		echo -e "$PASSWORD\n" | sudo -S mv /var/lib/waydroid/overlay/system/etc/hosts.disable /var/lib/waydroid/overlay/system/etc/hosts &> /dev/null

		zenity --warning --title "Waydroid Toolbox" --text "Custom adblock hosts file has been enabled!" --width 350 --height 75

	elif [ "$ADBLOCK_Choice" == "UPDATE" ]
	then
		# get the latest custom adblock hosts file from steven black github
		echo -e "$PASSWORD\n" | sudo -S rm /var/lib/waydroid/overlay/system/etc/hosts.disable &> /dev/null
		echo -e "$PASSWORD\n" | sudo -S wget https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn/hosts \
		       -O /var/lib/waydroid/overlay/system/etc/hosts	

		zenity --warning --title "Waydroid Toolbox" --text "Custom adblock hosts file has been updated!" --width 350 --height 75
	fi

elif [ "$Choice" == "GPU" ]
then
GPU_Choice=$(zenity --width 600 --height 220 --list --radiolist --multiple --title "Waydroid Toolbox" --column "Select One" --column "Option" --column="Description - Read this carefully!"\
	FALSE GBM "Use gbm config for GPU."\
	FALSE MINIGBM "Use minigbm_gbm_mesa for GPU (default)."\
	TRUE MENU "***** Go back to Waydroid Toolbox Main Menu *****")
	if [ $? -eq 1 ] || [ "$GPU_Choice" == "MENU" ]
	then
		echo User pressed CANCEL. Going back to main menu.

	elif [ "$GPU_Choice" == "GBM" ]
	then
		# Edit waydroid prop file to use gbm
		echo -e "$PASSWORD\n" | sudo -S sed -i "s/ro.hardware.gralloc=.*/ro.hardware.gralloc=gbm/g" \
			/var/lib/waydroid/waydroid_base.prop 

		zenity --warning --title "Waydroid Toolbox" --text "gbm is now in use!" --width 350 --height 75

	elif [ "$GPU_Choice" == "MINIGBM" ]
	then
		# Edit waydroid prop file to use minigbm_gbm_mesa
		echo -e "$PASSWORD\n" | sudo -S sed -i "s/ro.hardware.gralloc=.*/ro.hardware.gralloc=minigbm_gbm_mesa/g" \
			/var/lib/waydroid/waydroid_base.prop

		zenity --warning --title "Waydroid Toolbox" --text "minigbm_gbm_mesa is now in use!" --width 350 --height 75
	fi

elif [ "$Choice" == "AUDIO" ]
then
AUDIO_Choice=$(zenity --width 600 --height 220 --list --radiolist --multiple --title "Waydroid Toolbox" --column "Select One" --column "Option" --column="Description - Read this carefully!"\
	FALSE DISABLE "Disable the custom audio config."\
	FALSE ENABLE "Enable the custom audio config to lower audio latency."\
	TRUE MENU "***** Go back to Waydroid Toolbox Main Menu *****")
	if [ $? -eq 1 ] || [ "$AUDIO_Choice" == "MENU" ]
	then
		echo User pressed CANCEL. Going back to main menu.

	elif [ "$AUDIO_Choice" == "DISABLE" ]
	then
		# Disable the custom audio config
		echo -e "$PASSWORD\n" | sudo -S mv /var/lib/waydroid/overlay/system/etc/init/audio.rc \
		       	/var/lib/waydroid/overlay/system/etc/init/audio.rc.disable &> /dev/null

		zenity --warning --title "Waydroid Toolbox" --text "Custom audio config has been disabled!" --width 350 --height 75

	elif [ "$AUDIO_Choice" == "ENABLE" ]
	then
		# Enable the custom audio config
		echo -e "$PASSWORD\n" | sudo -S mv /var/lib/waydroid/overlay/system/etc/init/audio.rc.disable \
		       	/var/lib/waydroid/overlay/system/etc/init/audio.rc &> /dev/null

		zenity --warning --title "Waydroid Toolbox" --text "Custom audio config has been enabled!" --width 350 --height 75
	fi

elif [ "$Choice" == "SERVICE" ]
then
SERVICE_Choice=$(zenity --width 600 --height 220 --list --radiolist --multiple --title "Waydroid Toolbox" --column "Select One" --column "Option" --column="Description - Read this carefully!"\
	FALSE START "Start the Waydroid container service."\
	FALSE STOP "Stop the Waydroid container service."\
	TRUE MENU "***** Go back to Waydroid Toolbox Main Menu *****")
	if [ $? -eq 1 ] || [ "$SERVICE_Choice" == "MENU" ]
	then
		echo User pressed CANCEL. Going back to main menu.

	elif [ "$SERVICE_Choice" == "START" ]
	then
		# start the waydroid container service
		echo -e "$PASSWORD\n" | sudo -S waydroid-container-start
		waydroid session start &
		sleep 5

		zenity --warning --title "Waydroid Toolbox" --text "Waydroid container service has been started!" --width 350 --height 75

	elif [ "$SERVICE_Choice" == "STOP" ]
	then
		# stop the waydroid container service
		waydroid session stop
		echo -e "$PASSWORD\n" | sudo -S waydroid-container-stop
		pkill kwallet

		zenity --warning --title "Waydroid Toolbox" --text "Waydroid container service has been stopped!" --width 350 --height 75
	fi

elif [ "$Choice" == "LAUNCHER" ]
then
	steamos-add-to-steam /home/deck/Android_Waydroid/Android_Waydroid_Cage.sh
	sleep 5
	zenity --warning --title "Waydroid Toolbox" --text "Android Waydroid Cage launcher has been added to Game Mode!" --width 450 --height 75

elif [ "$Choice" == "UNINSTALL" ]
then
UNINSTALL_Choice=$(zenity --width 600 --height 220 --list --radiolist --multiple --title "Waydroid Toolbox" --column "Select One" --column "Option" --column="Description - Read this carefully!"\
	FALSE WAYDROID "Uninstall Waydroid but keep the Android user data."\
	FALSE FULL "Uninstall Waydroid and delete the Android user data."\
	TRUE MENU "***** Go back to Waydroid Toolbox Main Menu *****")
	if [ $? -eq 1 ] || [ "$UNINSTALL_Choice" == "MENU" ]
	then
		echo User pressed CANCEL. Going back to main menu.

	elif [ "$UNINSTALL_Choice" == "WAYDROID" ]
	then

		LOG_PIPE="/tmp/zenity_log.pipe"
		rm -f "$LOG_PIPE"
		mkfifo "$LOG_PIPE"

		# open Zenity text window to display logs
		zenity --text-info --title="Live Logs" --width=600 --height=400 --auto-scroll < "$LOG_PIPE" &

		# write logs to both console and Zenity
		exec > >(tee -a "$LOG_PIPE") 2>&1

		echo Disable the steamos readonly
		echo -e $PASSWORD\n | sudo -S steamos-readonly disable
	
		echo Remove the kernel module and waydroid packages installed
		echo -e "$PASSWORD\n" | sudo -S systemctl stop waydroid-container
		echo -e "$PASSWORD\n" | sudo -S pacman -R --noconfirm binder_linux-dkms fakeroot debugedit dkms plymouth libglibutil libgbinder python-gbinder waydroid wlroots cage wlr-randr
	
		echo Delete the waydroid directories and config
		echo -e "$PASSWORD\n" | sudo -S rm -rf ~/waydroid /var/lib/waydroid $HOME/.waydroid /etc/waydroid-extra ~/AUR
	
		echo Delete waydroid config and scripts
		echo -e "$PASSWORD\n" | sudo -S rm /etc/sudoers.d/zzzzzzzz-waydroid /etc/modules-load.d/waydroid_binder.conf /etc/modprobe.d/waydroid_binder.conf \
			/usr/bin/waydroid-startup-scripts /usr/bin/waydroid-shutdown-scripts
	
		echo Delete Waydroid Toolbox symlink
		rm ~/Desktop/Waydroid-Toolbox
	
		echo Delete contents of ~/Android_Waydroid
		rm -rf ~/Android_Waydroid/
	
		echo Re-enable the steamos readonly
		echo -e "$PASSWORD\n" | sudo -S steamos-readonly enable
		sleep 1

		# Close the log pipe when finished
		exec >&-
		rm -f "$LOG_PIPE"

		zenity --warning --title "Waydroid Toolbox" --text "Waydroid has been uninstalled! Goodbye!" --width 600 --height 75
		exit
		
	elif [ "$UNINSTALL_Choice" == "FULL" ]
	then

		LOG_PIPE="/tmp/zenity_log.pipe"
		rm -f "$LOG_PIPE"
		mkfifo "$LOG_PIPE"

		# open Zenity text window to display logs
		zenity --text-info --title="Live Logs" --width=600 --height=400 --auto-scroll < "$LOG_PIPE" &

		# write logs to both console and Zenity
		exec > >(tee -a "$LOG_PIPE") 2>&1


		echo Disable the steamos readonly
		echo -e "$PASSWORD\n" | sudo -S steamos-readonly disable
		
		echo Remove the kernel module and waydroid packages installed
		echo -e "$PASSWORD\n" | sudo -S systemctl stop waydroid-container
		echo -e "$PASSWORD\n" | sudo -S pacman -R --noconfirm binder_linux-dkms fakeroot debugedit dkms plymouth libglibutil libgbinder python-gbinder waydroid wlroots cage wlr-randr
			
		echo Delete the waydroid directories and config
		echo -e $PASSWORD\n | sudo -S rm -rf ~/waydroid /var/lib/waydroid $HOME/.waydroid /etc/waydroid-extra ~/.local/share/waydroid ~/.local/share/applications/waydroid* ~/AUR
	
		echo Delete waydroid config and scripts
		echo -e "$PASSWORD\n" | sudo -S rm /etc/sudoers.d/zzzzzzzz-waydroid /etc/modules-load.d/waydroid_binder.conf /etc/modprobe.d/waydroid_binder.conf \
			/usr/bin/waydroid-startup-scripts /usr/bin/waydroid-shutdown-scripts
	
		echo Delete Waydroid Toolbox and Waydroid Updatersymlink
		rm ~/Desktop/Waydroid-Toolbox
		rm ~/Desktop/Waydroid-Updater
	
		echo Delete contents of ~/Android_Waydroid
		rm -rf ~/Android_Waydroid/
	
		echo Re-enable the steamos readonly
		echo -e "$PASSWORD\n" | sudo -S steamos-readonly enable

		# Close the log pipe when finished
		exec >&-
		rm -f "$LOG_PIPE"
	
		zenity --warning --title "Waydroid Toolbox" --text "Waydroid and Android user data has been uninstalled! Goodbye!" --width 600 --height 75
		exit
	fi
fi
done
