#!/bin/bash

# script for check path
SCRIPT_PATH="$(readlink -f "$0")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
INSTALLATION_METHOD=true

# define functions here
cleanup_exit () {
	# call this function to perform cleanup when a sanity check fails
	
	echo Something went wrong! Performing cleanup. Run the script again to install waydroid.
	
	# remove installed packages
	echo -e "$current_password\n" | sudo -S pacman -R --noconfirm libglibutil libgbinder \
		python-gbinder waydroid wlroots cage wlr-randr binder_linux-dkms fakeroot debugedit \
		dkms plymouth linux-neptune-$(uname -r | cut -d "-" -f5)-headers &> /dev/null
	
	# delete the waydroid directories
	echo -e "$current_password\n" | sudo -S rm -rf ~/waydroid $HOME/.waydroid /var/lib/waydroid &> /dev/null
	
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

# Cloning Repo waydroids script from casualsnek
cloning_repo_waydroid_script () {

	WAYDROID_SCRIPT=https://github.com/casualsnek/waydroid_script.git
	WAYDROID_SCRIPT_DIR=$(mktemp -d)/waydroid_script

	# perform git clone of waydroid_script and binder kernel module source
	echo Cloning casualsnek / aleasto waydroid_script repo and binder kernel module source repo.
	echo This can take a few minutes depending on the speed of the internet connection and if github is having issues.
	echo If the git clone is slow - cancel the script \(CTL-C\) and run it again.

	git clone --depth=1 $WAYDROID_SCRIPT $WAYDROID_SCRIPT_DIR &> /dev/null && \

	if [[ $? -eq 0 ]]
	then
		echo Repo has been successfully cloned! Proceed to the next step.
	else
		echo Error cloning the repo!
		rm -rf $WAYDROID_SCRIPT_DIR
		if $INSTALLATION; then
			cleanup_exit
		fi
	fi
}

# copy custom config for controller and such
copy_android_custom_config () {

	# Controller support
	{ echo ""; sed -n '/^#CONTROLLER_CONFIG_START/,/^#CONTROLLER_CONFIG_END/p' $SCRIPT_DIR/extras/waydroid_base.prop; } | sudo tee -a /var/lib/waydroid/waydroid_base.prop > /dev/null
	
	# ROOT waydroid disabled config
	{ echo "";sed -n '/^#DISABLED_ROOT_START/,/^#DISABLED_ROOT_END/p' $SCRIPT_DIR/extras/waydroid_base.prop; } | sudo tee -a /var/lib/waydroid/waydroid_base.prop > /dev/null
		
	# waydroid_base.prop - controller config and disable root NOT USED ANYMORE
	# cat extras/waydroid_base.prop | sudo tee -a /var/lib/waydroid/waydroid_base.prop > /dev/null

	# waydroid_base.prop fingerprint spoof - check if A11 or A13 and apply the spoof accordingly
	if [ "$ANDROID_INSTALL_CHOICE" == "A13_NO_GAPPS" ] || [ "$ANDROID_INSTALL_CHOICE" == "A13_GAPPS" ]
	then
		# sed -n '/^#DISABLED_ROOT_START/,/^#DISABLED_ROOT_END/p' xtras/android_spoof.prop | sudo tee -a /var/lib/waydroid/waydroid_base.prop > /dev/null
		cat $SCRIPT_DIR/extras/android_spoof.prop | sudo tee -a /var/lib/waydroid/waydroid_base.prop > /dev/null

	elif [ "$ANDROID_INSTALL_CHOICE" == "TV13_NO_GAPPS" ]
	then
		cat $SCRIPT_DIR/extras/androidtv_spoof.prop | sudo tee -a /var/lib/waydroid/waydroid_base.prop > /dev/null
	fi
}

#install arm layer from casualsnek
install_android_extras () {

	# casualsnek / aleasto waydroid_script - install libndk and widevine
	python3 -m venv $WAYDROID_SCRIPT_DIR/venv
	$WAYDROID_SCRIPT_DIR/venv/bin/pip install -r $WAYDROID_SCRIPT_DIR/requirements.txt &> /dev/null

	echo -e "$current_password\n" | sudo -S $WAYDROID_SCRIPT_DIR/venv/bin/python3 $WAYDROID_SCRIPT_DIR/main.py -a13 install {$Choice,widevine}

	echo casualsnek / aleasto waydroid_script done.
	echo -e "$current_password\n" | sudo -S rm -rf $WAYDROID_SCRIPT_DIR
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
