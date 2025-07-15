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
# let's clear the existing config first
	echo -e "$PASSWORD\n" | sudo -S firewall-cmd --zone=trusted --add-interface=waydroid0 &> /dev/null
	echo -e "$PASSWORD\n" | sudo -S firewall-cmd --zone=trusted --add-port=53/udp &> /dev/null
	echo -e "$PASSWORD\n" | sudo -S firewall-cmd --zone=trusted --add-port=67/udp &> /dev/null
	echo -e "$PASSWORD\n" | sudo -S firewall-cmd --zone=trusted --add-forward &> /dev/null
	echo -e "$PASSWORD\n" | sudo -S firewall-cmd --runtime-to-permanent &> /dev/null

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
    logged_in_user=$(whoami)
    logged_in_uid=$(id -u "$logged_in_user")
    logged_in_home=$(eval echo "~$logged_in_user")
    applications_dir="${logged_in_home}/.local/share/applications"
    icons_dir="${logged_in_home}/.local/share/waydroid/data/icons"
    temp_dir=$(mktemp -d)
    launcher_script="${logged_in_home}/Android_Waydroid/Android_Waydroid_Cage.sh"

    # Function to batch update icon paths in Steam shortcuts.vdf using embedded Python
    update_all_icon_paths() {
        local shortcuts_file="${logged_in_home}/.steam/root/userdata/${steamid3}/config/shortcuts.vdf"
        declare -n icon_map=$1

        python3 - <<EOF
import os
import struct
import sys

shortcuts_file = "${shortcuts_file}"
updates = {
$(for app in "${!icon_map[@]}"; do
    printf '    "%s": "%s",\n' "$app" "${icon_map[$app]}"
done)
}

def read_cstring(fp):
    chars = []
    while (c := fp.read(1)) and c != b'\x00':
        chars.append(c)
    return b''.join(chars).decode('utf-8', errors='replace')

def parse_binary_vdf(fp):
    stack = [{}]
    while True:
        type_byte = fp.read(1)
        if not type_byte:
            break
        if type_byte == b'\x08':
            if len(stack) > 1:
                stack.pop()
            else:
                break
            continue
        key = read_cstring(fp)
        current_dict = stack[-1]
        if type_byte == b'\x00':
            new_dict = {}
            current_dict[key] = new_dict
            stack.append(new_dict)
        elif type_byte == b'\x01':
            current_dict[key] = read_cstring(fp)
        elif type_byte == b'\x02':
            current_dict[key] = struct.unpack('<i', fp.read(4))[0]
        elif type_byte == b'\x03':
            current_dict[key] = struct.unpack('<f', fp.read(4))[0]
        elif type_byte == b'\x07':
            current_dict[key] = struct.unpack('<Q', fp.read(8))[0]
        elif type_byte == b'\x0A':
            current_dict[key] = struct.unpack('<q', fp.read(8))[0]
        else:
            raise ValueError(f"Unsupported type byte: {type_byte} for key {key}")
    return stack[0]

def write_cstring(fp, s):
    fp.write(s.encode('utf-8') + b'\x00')

def write_binary_vdf(fp, d):
    for key, val in d.items():
        if isinstance(val, dict):
            fp.write(b'\x00')
            write_cstring(fp, key)
            write_binary_vdf(fp, val)
            fp.write(b'\x08')
        elif isinstance(val, str):
            fp.write(b'\x01')
            write_cstring(fp, key)
            write_cstring(fp, val)
        elif isinstance(val, int):
            fp.write(b'\x02')
            write_cstring(fp, key)
            fp.write(struct.pack('<i', val))
        elif isinstance(val, float):
            fp.write(b'\x03')
            write_cstring(fp, key)
            fp.write(struct.pack('<f', val))
        else:
            raise ValueError(f"Unsupported value type: {type(val)} for key {key}")

if not os.path.exists(shortcuts_file):
    print(f"shortcuts.vdf not found: {shortcuts_file}", file=sys.stderr)
    sys.exit(1)

with open(shortcuts_file, 'rb') as f:
    data = parse_binary_vdf(f)

shortcuts = data.get("shortcuts", data)
updated = False

for key, icon in updates.items():
    try:
        app_name_expected, pkg_expected = key.split("|", 1)
    except ValueError:
        app_name_expected = key
        pkg_expected = None

    matched = False
    for sc in shortcuts.values():
        if not isinstance(sc, dict):
            continue

        app_name = sc.get("AppName") or sc.get("appname")
        exe_path = sc.get("Exe") or sc.get("exe")
        launch_opts = sc.get("LaunchOptions") or sc.get("launchoptions") or ""

        if (
            app_name == app_name_expected and
            exe_path and "Android_Waydroid_Cage.sh" in exe_path and
            pkg_expected and pkg_expected in launch_opts
        ):
            sc["icon"] = icon
            print(f"Icon applied: {icon}")
            updated = True
            matched = True
            break

if updated:
    with open(shortcuts_file, 'wb') as f:
        write_binary_vdf(f, data)
        f.write(b'\x08')
    print("Saved updated shortcuts.vdf")
EOF
}


    #Python to get most recent SteamID3
    steamid3=$(python3 - <<EOF
import os
import re

home = os.path.expanduser("~")
paths = [
    os.path.join(home, ".steam", "root", "config", "loginusers.vdf"),
    os.path.join(home, ".local", "share", "Steam", "config", "loginusers.vdf"),
]

vdf_path = next((p for p in paths if os.path.isfile(p)), None)
if not vdf_path:
    exit(1)

with open(vdf_path, "r", encoding="utf-8", errors="ignore") as f:
    content = f.read()

matches = re.findall(r'"(\d{17})"\s*{([^}]+)}', content)
most_recent = {"steamid64": None, "timestamp": 0}

for steamid, block in matches:
    ts_match = re.search(r'"Timestamp"\s+"(\d+)"', block)
    recent_match = re.search(r'"MostRecent"\s+"1"', block)
    timestamp = int(ts_match.group(1)) if ts_match else 0
    if recent_match or timestamp > most_recent["timestamp"]:
        most_recent["steamid64"] = int(steamid)
        most_recent["timestamp"] = timestamp

if most_recent["steamid64"]:
    print(most_recent["steamid64"] - 76561197960265728)
EOF
)

    if [[ -z "$steamid3" ]]; then
        echo "Steam config not found or could not determine most recent user. Skipping Steam integration."
    else
        echo "Detected SteamID3: $steamid3"
        userdata_folder="${logged_in_home}/.steam/root/userdata/${steamid3}"
        config_dir="${userdata_folder}/config"
        shortcuts_vdf_path="${config_dir}/shortcuts.vdf"

        shortcuts_file="$shortcuts_vdf_path"
    fi


    # Add any app here to ignore if needed
    ignored_files=(
    )

    declare -A exception_files=(
        ["com.google.android.videos"]="Google TV"
        # Add more exceptions to allow if needed
    )

    is_ignored() {
        local entry="$1"
        for ignore in "${ignored_files[@]}"; do
            [[ "$ignore" == "$entry" ]] && return 0
        done
        return 1
    }

    desktop_choices=()

    # Build the list of Waydroid apps for selection
    for icon in "$icons_dir"/*.png; do
        package_name=$(basename "$icon" .png)
        desktop_file="waydroid.${package_name}.desktop"
        full_path="${applications_dir}/${desktop_file}"

        if is_ignored "$desktop_file" || [[ "$package_name" =~ ^org\.lineageos\..* ]]; then
            continue
        fi

        if [[ -n "${exception_files[$package_name]}" ]]; then
            display_name="${exception_files[$package_name]}"
        elif [[ -f "$full_path" ]]; then
            display_name=$(grep -i "^Name=" "$full_path" | head -n1 | cut -d'=' -f2-)
            [[ -z "$display_name" || "$display_name" == "App Settings" ]] && continue
        else
            continue
        fi

        desktop_choices+=("FALSE" "$package_name" "$display_name")
    done

    if [[ ${#desktop_choices[@]} -eq 0 ]]; then
        zenity --info --title "Waydroid Toolbox" --text "No user apps found to add to Steam." --width 350 --height 75
        exit 0
    fi

    selected=$(zenity --list --title="Select Waydroid apps to add to Steam" \
        --width=700 --height=400 \
        --text="Select one or more Waydroid apps to add to Steam Game Mode." \
        --checklist \
        --column "Select" --column "Package" --column "App Name" \
        "${desktop_choices[@]}")

    if [[ -n "$selected" ]]; then
        games=()
        launch_opts=()
        if [[ -f "$shortcuts_file" ]]; then
            # Parse shortcuts.vdf: replace nulls with newlines, remove empty lines
            mapfile -t lines < <(tr '\0\1\2' '\n\n\n' < "$shortcuts_file" | grep -v '^$')
            for ((i=0; i < ${#lines[@]} - 1; i++)); do
                if [[ "${lines[i],,}" == "appname" ]]; then
                    appname="${lines[i+1]}"
                    # Trim whitespace
                    appname="${appname#"${appname%%[![:space:]]*}"}"
                    appname="${appname%"${appname##*[![:space:]]}"}"

                    launchopt=""
                    for ((j=i+1; j < ${#lines[@]} - 1; j++)); do
                        if [[ "${lines[j],,}" == "launchoptions" ]]; then
                            launchopt="${lines[j+1]}"
                            # Trim quotes and whitespace
                            launchopt="${launchopt%\"}"
                            launchopt="${launchopt#\"}"
                            launchopt="${launchopt#"${launchopt%%[![:space:]]*}"}"
                            launchopt="${launchopt%"${launchopt##*[![:space:]]}"}"
                            break
                        fi
                        [[ "${lines[j],,}" == "appname" ]] && break
                    done

                    if [[ -n "$appname" ]]; then
                        games+=("$appname")
                        launch_opts+=("$launchopt")
                    fi
                fi
            done
        else
            echo "Warning: shortcuts.vdf not found. Duplicate check will be skipped."
        fi

        IFS="|" read -ra selected_packages <<< "$selected"

        if [[ ! -x "$launcher_script" ]]; then
            zenity --error --title "Waydroid Toolbox" --text "Launcher script not found or not executable:\n$launcher_script" --width 400 --height 100
            exit 1
        fi

        apps_added=false
        declare -A icon_updates=()

        for pkg in "${selected_packages[@]}"; do
            desktop_path="${applications_dir}/waydroid.${pkg}.desktop"
            if [[ -f "$desktop_path" ]]; then
                name=$(grep -i "^Name=" "$desktop_path" | head -n1 | cut -d'=' -f2-)
            else
                name="${exception_files[$pkg]}"
            fi

            [[ -z "$name" ]] && name="$pkg"

            # Check if app already exists in shortcuts.vdf by matching name and package (launch options)
            already_exists=false
            launcher_cmd="${launcher_script} $pkg"

            for ((idx=0; idx < ${#games[@]}; idx++)); do
                # Normalize existing launch options for comparison
                existing_launchopt="${launch_opts[$idx]}"
                existing_launchopt="${existing_launchopt%\"}"
                existing_launchopt="${existing_launchopt#\"}"
                existing_launchopt="${existing_launchopt#"${existing_launchopt%%[![:space:]]*}"}"
                existing_launchopt="${existing_launchopt%"${existing_launchopt##*[![:space:]]}"}"

                if [[ "${games[$idx]}" == "$name" && "$existing_launchopt" == "$pkg" ]]; then
                    already_exists=true
                    break
                fi
            done

            if $already_exists; then
                echo "Skipping: $name is already in your Steam library."
                zenity --info --title "Waydroid Toolbox" \
                    --text="$name is already in your Steam library." \
                    --width 400 --height 75
                continue
            fi

            # Create temporary desktop file for this app
            launcher_file="${temp_dir}/waydroid_${pkg}.desktop"
            cat > "$launcher_file" <<EOF
[Desktop Entry]
Name=$name
Exec=${launcher_script} $pkg
Path=${logged_in_home}/Android_Waydroid
Type=Application
Terminal=false
Icon=application-default-icon
EOF

            steamos-add-to-steam "$launcher_file"
            sleep 1


            icon_file="${icons_dir}/${pkg}.png"
            if [[ -f "$icon_file" ]]; then
                sleep 1
                icon_updates["$name|$pkg"]="$icon_file"
                sleep 1
            else
                echo "Icon for $pkg not found at $icon_file, skipping icon update."
            fi


            zenity --info \
                --title="Waydroid Toolbox" \
                --text="'$name' has been successfully added to Steam!" \
                --width=400 --height=100 \
                --timeout=1

            echo "Added '$name' to Steam successfully!"
            apps_added=true
            rm -f "$launcher_file"

        done
        if (( ${#icon_updates[@]} > 0 )); then
            update_all_icon_paths icon_updates
        fi

        # Remove temp_dir after all apps processed
        rmdir "$temp_dir"

        if $apps_added; then
            zenity --info \
                --title="Waydroid Toolbox" \
                --text="Waydroid app(s) were successfully added to Steam.\n\n In order to refresh the icons, Steam must be restarted..." \
                --width=400 --height=120

            CHOICE=$(zenity --list \
                --title="Post-Installation Options" \
                --text="What would you like to do next?" \
                --radiolist \
                --column "Select" --column "Action" \
                TRUE "Restart Steam" \
                FALSE "Enter Game Mode" \
                FALSE "Exit" \
                --width=350 --height=200)

            case "$CHOICE" in
                "Restart Steam")
                    pkill steam 2>/dev/null
                    while pgrep -x steam >/dev/null; do sleep 1; done
                    nohup /usr/bin/steam -silent %U &>/dev/null & disown
                    ;;

                "Enter Game Mode")
                    qdbus org.kde.Shutdown /Shutdown org.kde.Shutdown.logout
                    ;;
            esac

        else
            zenity --info \
                --title="Waydroid Toolbox" \
                --text="No new Waydroid apps were added. All selected apps are already in your Steam library." \
                --width=400 --height=100
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
		echo -e "$PASSWORD\n" | sudo -S pacman -R --noconfirm libglibutil libgbinder python-gbinder waydroid wlroots dnsmasq lxc
	
		# delete the waydroid directories and config
		echo -e "$PASSWORD\n" | sudo -S rm -rf ~/waydroid /var/lib/waydroid /etc/waydroid-extra ~/AUR
	
		# delete waydroid config and scripts
		echo -e "$PASSWORD\n" | sudo -S rm /etc/sudoers.d/zzzzzzzz-waydroid /etc/modules-load.d/waydroid.conf /usr/bin/waydroid-fix-controllers \
			/usr/bin/waydroid-container-stop /usr/bin/waydroid-container-start
	
		# delete cage binaries
		echo -e "$PASSWORD\n" | sudo -S rm /usr/bin/cage /usr/bin/wlr-randr

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
		echo -e "$PASSWORD\n" | sudo -S pacman -R --noconfirm libglibutil libgbinder python-gbinder waydroid wlroots dnsmasq lxc
	
		# delete the waydroid directories and config
		echo -e $PASSWORD\n | sudo -S rm -rf ~/waydroid /var/lib/waydroid /etc/waydroid-extra ~/.local/share/waydroid ~/.local/share/applications/waydroid* ~/AUR
	
		# delete waydroid config and scripts
		echo -e "$PASSWORD\n" | sudo -S rm /etc/sudoers.d/zzzzzzzz-waydroid /etc/modules-load.d/waydroid.conf /usr/bin/waydroid-fix-controllers \
			/usr/bin/waydroid-container-stop /usr/bin/waydroid-container-start
	
		# delete cage binaries
		echo -e "$PASSWORD\n" | sudo -S rm /usr/bin/cage /usr/bin/wlr-randr

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
