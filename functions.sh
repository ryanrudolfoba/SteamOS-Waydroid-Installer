#!/bin/bash

# define functions here
cleanup_exit () {
	# call this function to perform cleanup when a sanity check fails
	
	echo Something went wrong! Performing cleanup. Run the script again to install waydroid.
	
	# remove installed packages
	echo -e "$current_password\n" | sudo -S pacman -R --noconfirm libglibutil libgbinder \
		python-gbinder waydroid wlroots cage wlr-randr binder_linux-dkms fakeroot debugedit \
		dkms plymouth linux-neptune-$(uname -r | cut -d "-" -f5)-headers &> /dev/null
	
	# delete the waydroid directories
	echo -e "$current_password\n" | sudo -S rm -rf ~/waydroid /var/lib/waydroid &> /dev/null
	
	# delete waydroid config and scripts
	echo -e "$current_password\n" | sudo -S rm /etc/sudoers.d/zzzzzzzz-waydroid /etc/modules-load.d/waydroid.conf /usr/bin/waydroid* &> /dev/null

	# delete Waydroid Toolbox and Waydroid Update symlinks
	rm ~/Desktop/Waydroid-Updater &> /dev/null
	rm ~/Desktop/Waydroid-Toolbox &> /dev/null

	# delete Android_Waydroid folder and enable the readonly
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
	# casualsnek / aleasto waydroid_script - install libndk and widevine
	python3 -m venv $WAYDROID_SCRIPT_DIR/venv
	$WAYDROID_SCRIPT_DIR/venv/bin/pip install -r $WAYDROID_SCRIPT_DIR/requirements.txt &> /dev/null

	if [ "$Choice" == "A13_NO_GAPPS" ] || [ "$Choice" == "A13_GAPPS" ]
	then
		echo -e "$current_password\n" | sudo -S $WAYDROID_SCRIPT_DIR/venv/bin/python3 $WAYDROID_SCRIPT_DIR/main.py -a13 install {libndk,widevine}
	fi

	echo casualsnek / aleasto waydroid_script done.
	echo -e "$current_password\n" | sudo -S rm -rf $WAYDROID_SCRIPT_DIR
	
	# waydroid_base.prop - controller config and disable root
	cat extras/waydroid_base.prop | sudo tee -a /var/lib/waydroid/waydroid_base.prop > /dev/null

	# waydroid_base.prop fingerprint spoof - check if A11 or A13 and apply the spoof accordingly
	if [ "$Choice" == "A13_NO_GAPPS" ] || [ "$Choice" == "A13_GAPPS" ] 
	then
		cat extras/android_spoof.prop | sudo tee -a /var/lib/waydroid/waydroid_base.prop > /dev/null

	elif [ "$Choice" == "TV13_NO_GAPPS" ]
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
