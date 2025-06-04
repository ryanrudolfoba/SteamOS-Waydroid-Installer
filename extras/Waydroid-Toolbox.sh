#!/bin/bash

# libndk patcher from qwerty12356-wart
ndk_path="/var/lib/waydroid/overlay/system/lib64/libndk_translation.so"
function CheckHex {
#file path, Ghidra offset, Hex to check
commandoutput="$(od $1 --skip-bytes=$(($2-0x101000)) --read-bytes=$((${#3} / 2)) --endian=little -t x1 -An file | sed 's/ //g')"
if [ "$commandoutput" = "$3" ]; then
echo "1"
else
echo "0"
fi
}

function PatchHex {
#file path, ghidra offset, original hex, new hex
file_offset=$(($2-0x101000))
if [ $(CheckHex $1 $2 $3) = "1" ]; then
    hexinbin=$(printf $4 | xxd -r -p)
    # pre-cache sudo password so dd below can actually do its job
    echo -e "$5\n" | sudo -S true &>/dev/null
    echo -n $hexinbin | sudo dd of=$1 seek=$file_offset bs=1 conv=notrunc;
    tmp="Patched $1 at $file_offset with new hex $4"
    echo $tmp
elif [ $(CheckHex $1 $2 $4) = "1" ]; then
    echo "Already patched"
else
    echo "Hex mismatch! This patcher is for Android 11 LIBNDK only!"
fi
}

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
 	FALSE LIBNDK "Use custom LIBNDK patches or the original LIBNDK."\
	FALSE LAUNCHER "Add Android Waydroid Cage launcher to Game Mode."\
	FALSE ADD_APPS "Select individual Waydroid apps to add to Game Mode."\
	FALSE NETWORK "Reinitialize firewall configuration - use this when WIFI is not working."\
	FALSE UNINSTALL "Choose this to uninstall Waydroid and revert any changes made."\
	TRUE EXIT "***** Exit the Waydroid Toolbox *****")

if [ $? -eq 1 ] || [ "$Choice" == "EXIT" ]
then
	echo User pressed CANCEL / EXIT.
	exit

elif [ "$Choice" == "NETWORK" ]
then
# firewall config for waydroid0 interface to forward packets for internet to work
	echo -e "$PASSWORD\n" | sudo -S firewall-cmd --zone=trusted --add-interface=waydroid0 &> /dev/null
	echo -e "$PASSWORD\n" | sudo -S firewall-cmd --zone=trusted --add-port=53/udp &> /dev/null
	echo -e "$PASSWORD\n" | sudo -S firewall-cmd --zone=trusted --add-port=67/udp &> /dev/null
	echo -e "$PASSWORD\n" | sudo -S firewall-cmd --zone=trusted --add-forward &> /dev/null
	echo -e "$PASSWORD\n" | sudo -S firewall-cmd --runtime-to-permanent &> /dev/null

  	zenity --warning --title "Waydroid Toolbox" --text "Waydroid network configuration completed!" --width 350 --height 75

elif [ "$Choice" == "LIBNDK" ]
then
LIBNDK_Choice=$(zenity --width 600 --height 220 --list --radiolist --multiple --title "Waydroid Toolbox" --column "Select One" --column "Option" --column="Description - Read this carefully!"\
	FALSE PATCHED "Apply LIBNDK custom patches from qwerty12356-wart."\
	FALSE ORIGINAL "Remove the patch and use the original LIBNDK."\
	TRUE MENU "***** Go back to Waydroid Toolbox Main Menu *****")
	if [ $? -eq 1 ] || [ "$LIBNDK_Choice" == "MENU" ]
	then
		echo User pressed CANCEL. Going back to main menu.

	elif [ "$LIBNDK_Choice" == "PATCHED" ]
	then
		# patch the libndk - credits from qwerty12356-wart
		PatchHex $ndk_path 0x307dd1 83e2fa 83e2ff "$PASSWORD"
		PatchHex $ndk_path 0x307cd6 83e2fa 83e2ff "$PASSWORD"

		zenity --warning --title "Waydroid Toolbox" --text "LIBNDK custom patches has been applied!" --width 350 --height 75

	elif [ "$LIBNDK_Choice" == "ORIGINAL" ]
	then
		# remove the patch
		PatchHex $ndk_path 0x307dd1 83e2ff 83e2fa "$PASSWORD"
		PatchHex $ndk_path 0x307cd6 83e2ff 83e2fa "$PASSWORD"

  		zenity --warning --title "Waydroid Toolbox" --text "LIBNDK custom patches has been removed!" --width 350 --height 75
	fi

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


elif [ "$Choice" == "ADD_APPS" ]; then
    logged_in_home="$HOME"
    applications_dir="${logged_in_home}/.local/share/applications"
    temp_dir=$(mktemp -d)

    ignored_files=(
        "waydroid.com.android.inputmethod.latin.desktop"
        "waydroid.com.android.gallery3d.desktop"
        "waydroid.com.android.documentsui.desktop"
        "waydroid.com.android.settings.desktop"
        "waydroid.org.lineageos.eleven.desktop"
        "waydroid.com.android.calculator2.desktop"
        "waydroid.com.android.contacts.desktop"
        "waydroid.org.lineageos.etar.desktop"
        "waydroid.org.lineageos.jelly.desktop"
        "waydroid.com.android.camera2.desktop"
        "waydroid.com.android.deskclock.desktop"
        "waydroid.org.lineageos.recorder.desktop"
    )

    is_ignored() {
        local filename="$1"
        for ignored in "${ignored_files[@]}"; do
            if [[ "$filename" == "$ignored" ]]; then
                return 0
            fi
        done
        return 1
    }

    if [[ ! -d "$applications_dir" ]]; then
        zenity --error --title "Waydroid Toolbox" --text "Waydroid .desktop directory not found!" --width 400 --height 100
        exit 1  # Exit the script if the directory is not found
    fi

    desktop_choices=()
    for file_path in "$applications_dir"/*.desktop; do
        file_name=$(basename "$file_path")
        if is_ignored "$file_name"; then
            continue
        fi
        if ! grep -qi "waydroid" "$file_path"; then
            continue
        fi
        display_name=$(grep -i "^Name=" "$file_path" | head -n1 | cut -d'=' -f2-)
        exec_cmd=$(grep -i "^Exec=" "$file_path" | head -n1 | cut -d'=' -f2-)
        if [[ -z "$display_name" || "$exec_cmd" != *"waydroid app launch"* ]]; then
            continue
        fi
        desktop_choices+=("FALSE" "$file_name" "$display_name")
    done

    if [[ ${#desktop_choices[@]} -eq 0 ]]; then
        zenity --info --title "Waydroid Toolbox" --text "No user apps found to add to Steam." --width 350 --height 75
    else
        selected=$(zenity --list --title="Select apps to add to Steam" \
            --width=700 --height=400 \
            --text="Select one or more Waydroid apps to add to Steam Game Mode." \
            --checklist \
            --column "Select" --column "File" --column "App Name" \
            "${desktop_choices[@]}")

        if [ -n "$selected" ]; then
            IFS="|" read -ra selected_files <<< "$selected"
            for entry in "${selected_files[@]}"; do
                original_path="${applications_dir}/${entry}"
                display_name=$(grep -i "^Name=" "$original_path" | head -n1 | cut -d'=' -f2-)
                exec_cmd=$(grep -i "^Exec=" "$original_path" | head -n1 | cut -d'=' -f2-)

                # Ensure exec_cmd is not empty and contains the expected value
                if [[ -z "$exec_cmd" ]]; then
                    continue
                fi

                read -ra parts <<< "$exec_cmd"
                app_name="${parts[-1]}"

                # Create temporary custom launcher in the temp directory
                launcher_file="${temp_dir}/waydroid_${app_name}.desktop"
                cat > "$launcher_file" <<EOF
[Desktop Entry]
Name=$display_name
Exec=${HOME}/Android_Waydroid/Android_Waydroid_Cage.sh $app_name
Path=${HOME}/Android_Waydroid
Type=Application
Terminal=false
Icon=application-default-icon
EOF

                steamos-add-to-steam "$launcher_file"
            done

            zenity --info --title "Waydroid Toolbox" --text "Selected apps added to Steam!" --width 400 --height 100

            # Remove the temporary desktop files after use
            rm -rf "$temp_dir"
        else
            zenity --info --title "Waydroid Toolbox" --text "No apps selected." --width 300 --height 75
        fi
    fi



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
		# disable the steamos readonly
		echo -e $PASSWORD\n | sudo -S steamos-readonly disable
	
		# remove the kernel module and packages installed
		echo -e "$PASSWORD\n" | sudo -S systemctl stop waydroid-container
		echo -e "$PASSWORD\n" | sudo -S rm /lib/modules/$(uname -r)/binder_linux.ko.zst
		echo -e "$PASSWORD\n" | sudo -S pacman -R --noconfirm libglibutil libgbinder python-gbinder waydroid wlroots cage wlr-randr
	
		# delete the waydroid directories and config
		echo -e "$PASSWORD\n" | sudo -S rm -rf ~/waydroid /var/lib/waydroid /etc/waydroid-extra ~/AUR
	
		# delete waydroid config and scripts
		echo -e "$PASSWORD\n" | sudo -S rm /etc/sudoers.d/zzzzzzzz-waydroid /etc/modules-load.d/waydroid.conf /usr/bin/waydroid-fix-controllers \
			/usr/bin/waydroid-container-stop /usr/bin/waydroid-container-start
	
		# delete Waydroid Toolbox symlink
		rm ~/Desktop/Waydroid-Toolbox
	
		# delete contents of ~/Android_Waydroid
		rm -rf ~/Android_Waydroid/
	
		# re-enable the steamos readonly
		echo -e "$PASSWORD\n" | sudo -S steamos-readonly enable
	
		zenity --warning --title "Waydroid Toolbox" --text "Waydroid has been uninstalled! Goodbye!" --width 600 --height 75
		exit
		
	elif [ "$UNINSTALL_Choice" == "FULL" ]
	then
		# disable the steamos readonly
		echo -e "$PASSWORD\n" | sudo -S steamos-readonly disable
	
		# remove the kernel module and packages installed
		echo -e "$PASSWORD\n" | sudo -S systemctl stop waydroid-container
		echo -e "$PASSWORD\n" | sudo -S rm /lib/modules/$(uname -r)/binder_linux.ko.zst
		echo -e "$PASSWORD\n" | sudo -S pacman -R --noconfirm libglibutil libgbinder python-gbinder waydroid wlroots cage wlr-randr
	
		# delete the waydroid directories and config
		echo -e $PASSWORD\n | sudo -S rm -rf ~/waydroid /var/lib/waydroid /etc/waydroid-extra ~/.local/share/waydroid ~/.local/share/applications/waydroid* ~/AUR
	
		# delete waydroid config and scripts
		echo -e "$PASSWORD\n" | sudo -S rm /etc/sudoers.d/zzzzzzzz-waydroid /etc/modules-load.d/waydroid.conf /usr/bin/waydroid-fix-controllers \
			/usr/bin/waydroid-container-stop /usr/bin/waydroid-container-start
	
		# delete Waydroid Toolbox and Waydroid Updatersymlink
		rm ~/Desktop/Waydroid-Toolbox
		rm ~/Desktop/Waydroid-Updater
	
		# delete contents of ~/Android_Waydroid
		rm -rf ~/Android_Waydroid/
	
		# re-enable the steamos readonly
		echo -e "$PASSWORD\n" | sudo -S steamos-readonly enable
	
		zenity --warning --title "Waydroid Toolbox" --text "Waydroid and Android user data has been uninstalled! Goodbye!" --width 600 --height 75
		exit
	fi
fi
done
