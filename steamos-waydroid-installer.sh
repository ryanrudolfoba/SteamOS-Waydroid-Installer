#!/bin/bash

clear

echo SteamOS Waydroid Installer Script by ryanrudolf
echo https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer
sleep 2

kernel_version=$(uname -r)
stable1=6.1.52-valve9-1-neptune-61
preview1=6.1.52-valve14-1-neptune-61
preview2=6.1.52-valve16-1-neptune-61

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

# check kernel version. exit immediately if not on the supported kernel
echo Checking if kernel is supported.
if [ $kernel_version = $stable1 ] || [ $kernel_version = $preview1 ] || [ $kernel_version = $preview2 ]
then
	echo $kernel_version is supported. Proceed to next step.
else
	echo $kernel_version is NOT supported. Exiting immediately.
	exit
fi

# check if sudo password is already set
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

# github URL for casualsnek
AUR_CASUALSNEK=https://github.com/casualsnek/waydroid_script.git

# target directory for the git command
DIR_CASUALSNEK=~/AUR/waydroid/waydroid_script

# create AUR directory where casualsnek script will be saved
mkdir -p ~/AUR/waydroid &> /dev/null

# perform git clone but lets cleanup first in case the directory is not empty
echo -e "$current_password\n" | sudo -S rm -rf ~/AUR/waydroid*  &> /dev/null && git clone $AUR_CASUALSNEK $DIR_CASUALSNEK

if [ $? -eq 0 ]
then
	echo Casualsnek repo has been successfully cloned!
else
	echo Error cloning Casualsnek repo! Goodbye!
	echo -e "$current_password\n" | sudo -S rm -rf ~/AUR/waydroid*
	exit
fi

# disable the SteamOS readonly
echo -e "$current_password\n" | sudo -S steamos-readonly disable

# initialize the keyring
echo -e "$current_password\n" | sudo -S pacman-key --init && echo -e "$current_password\n" | sudo -S pacman-key --populate

if [ $? -eq 0 ]
then
	echo pacman keyring has been initialized!
else
	echo Error initializing keyring! Goodbye!
	echo -e "$current_password\n" | sudo -S steamos-readonly enable
	exit
fi

# lets install and enable the binder module so we can start waydroid right away
lsmod | grep binder
if [ $? -eq 1 ]
then
	echo binder kernel module not found! Installing binder!
	echo -e "$current_password\n" | sudo -S cp binder/$kernel_version/binder_linux.ko.zst /lib/modules/$kernel_version && \
		echo -e "$current_password\n" | sudo -S depmod -a && sudo modprobe binder_linux && \
		echo -e "$current_password\n" | sudo -S modprobe binder_linux

	if [ $? -eq 0 ]
	then
		echo binder kernel module has been installed!
	else
		echo Error installing binder kernel module. Goodbye!
 		# cleanup remove binder kernel module
		echo -e "$current_password\n" | sudo -S rm /lib/modules/$kernel_version/binder_linux.ko.zst
		echo -e "$current_password\n" | sudo -S steamos-readonly enable
		exit
	fi
else
	echo binder kernel module already loaded! no need to reinstall binder!
fi

# ok lets install waydroid and cage
echo -e "$current_password\n" | sudo -S pacman -U cage/wlroots-0.16.2-1-x86_64.pkg.tar.zst waydroid/dnsmasq-2.89-1-x86_64.pkg.tar.zst \
	waydroid/lxc-1\:5.0.2-1-x86_64.pkg.tar.zst waydroid/libglibutil-1.0.74-1-x86_64.pkg.tar.zst waydroid/libgbinder-1.1.35-1-x86_64.pkg.tar.zst \
	waydroid/python-gbinder-1.1.2-1-x86_64.pkg.tar.zst waydroid/waydroid-1.4.2-1-any.pkg.tar.zst --noconfirm --overwrite "*"

if [ $? -eq 0 ]
then
	echo waydroid and cage has been installed!
	echo -e "$current_password\n" | sudo -S systemctl disable waydroid-container.service
else
	echo Error installing waydroid and cage. Goodbye!
 	# cleanup remove binder kernel module
 	echo -e "$current_password\n" | sudo -S rm /lib/modules/$kernel_version/binder_linux.ko.zst
	echo -e "$current_password\n" | sudo -S steamos-readonly enable
	exit
fi

# lets install the custom config files
mkdir ~/Android_Waydroid &> /dev/null

# waydroid kernel module
echo -e "$current_password\n" | sudo -S tee /etc/modules-load.d/waydroid.conf > /dev/null <<'EOF'
binder_linux
EOF

# waydroid start service
echo -e "$current_password\n" | sudo -S tee /usr/bin/waydroid-container-start > /dev/null <<'EOF'
#!/bin/bash
systemctl start waydroid-container.service
sleep 5
ln -s /dev/binderfs/binder /dev/anbox-binder &> /dev/null
chmod o=rw /dev/anbox-binder
EOF
echo -e "$current_password\n" | sudo -S chmod +x /usr/bin/waydroid-container-start

# waydroid stop service
echo -e "$current_password\n" | sudo -S tee /usr/bin/waydroid-container-stop > /dev/null <<'EOF'
#!/bin/bash
systemctl stop waydroid-container.service
EOF
echo -e "$current_password\n" | sudo -S chmod +x /usr/bin/waydroid-container-stop

# waydroid fix controllers
echo -e "$current_password\n" | sudo -S tee /usr/bin/waydroid-fix-controllers > /dev/null <<'EOF'
#!/bin/bash
echo add > /sys/devices/virtual/input/input*/event*/uevent
EOF
echo -e "$current_password\n" | sudo -S chmod +x /usr/bin/waydroid-fix-controllers

echo -e "$current_password\n" | sudo -S tee /usr/bin/waydroid-set-properties > /dev/null <<'EOF'
#!/bin/bash
if [ "\$1" == "libndk" ]
then
	if [ "\$2" == "fixer" ]
	then
		sed -i "s/^ro.dalvik.vm.native.bridge=.*/ro.dalvik.vm.native.bridge=libndk_fixer.so/g" /var/lib/waydroid/waydroid_base.prop
	else
		sed -i "s/^ro.dalvik.vm.native.bridge=.*/ro.dalvik.vm.native.bridge=libndk_translation.so/g" /var/lib/waydroid/waydroid_base.prop
	fi
fi
EOF
echo -e "$current_password\n" | sudo -S chmod +x /usr/bin/waydroid-set-properties

# custom sudoers file do not ask for sudo for the custom waydroid scripts
echo -e "$current_password\n" | sudo -S tee /etc/sudoers.d/zzzzzzzz-waydroid > /dev/null <<'EOF'
deck ALL=(ALL) NOPASSWD: /usr/bin/waydroid-container-stop
deck ALL=(ALL) NOPASSWD: /usr/bin/waydroid-container-start
deck ALL=(ALL) NOPASSWD: /usr/bin/waydroid-fix-controllers
deck ALL=(ALL) NOPASSWD: /usr/bin/waydroid-set-properties
EOF
echo -e "$current_password\n" | sudo -S chown root:root /etc/sudoers.d/zzzzzzzz-waydroid

# waydroid launcher - cage
cat > ~/Android_Waydroid/Android_Waydroid_Cage.sh << EOF
#!/bin/bash

USER_PROPERTIES_FILE="/home/deck/Android_Waydroid/.user_properties"
if [ -f "\${USER_PROPERTIES_FILE}" ]
	source "\${USER_PROPERTIES_FILE}"
fi

set_libndk() {
	local package="\$1"

	if [ "\${waydroid_libndk}" != "fixer" ] && [ "\${waydroid_libndk}" != "translation" ] && [ "\${package}" == "com.roblox.client" ]
	then
		sudo /usr/bin/waydroid-set-properties libndk fixer
	elif [ "\${waydroid_libndk}" == "fixer" ]
	then
		sudo /usr/bin/waydroid-set-properties libndk fixer
	else
		sudo /usr/bin/waydroid-set-properties libndk translation
	fi
}

# try to kill cage gracefully using SIGTERM
timeout 5s killall -15 cage -w &> /dev/null
if [ \$? -eq 124 ]
then
	# timed out, process still active, let's force some more usin SIGINT
	timeout 5s killall -2 cage -w &> /dev/null
	if [ \$? -eq 124 ]
	then
		# timed out again, this will shut it down for good using SIGKILL
		timeout 5s killall -9 cage -w &> /dev/null
	fi
fi

sudo /usr/bin/waydroid-container-stop

set_libndk "\$1"

sudo /usr/bin/waydroid-container-start

# Check if non Steam shortcut has the game / app as the launch option
if [ -z "\$1" ]
	then
		# launch option not provided. launch Waydroid via cage and show the full ui right away
		cage -- bash -c 'wlr-randr --output X11-1 --custom-mode 1280x800@60Hz ;	\\
			/usr/bin/waydroid show-full-ui \$@ & \\

			sleep 15 ; \\
			sudo /usr/bin/waydroid-fix-controllers'

	else
		# launch option provided. launch Waydroid via cage but do not show full ui, launch the package from the arguments
		cage -- env PACKAGE="\$1" bash -c 'wlr-randr --output X11-1 --custom-mode 1280x800@60Hz ; \\
			/usr/bin/waydroid session start \$@ & \\

			sleep 15 ; \\
			sudo /usr/bin/waydroid-fix-controllers ; \\

			sleep 1 ; \\
			/usr/bin/waydroid app launch \$PACKAGE &'
fi

# reset libndk
set_libndk ""
EOF

# custom configs done. lets move them to the correct location
cp $PWD/extras/Waydroid-Toolbox.sh ~/Android_Waydroid
chmod +x ~/Android_Waydroid/*.sh
ln -s ~/Android_Waydroid/Waydroid-Toolbox.sh ~/Desktop/Waydroid-Toolbox &> /dev/null

# lets copy cage and wlr-randr to the correct folder
echo -e "$current_password\n" | sudo -S cp cage/cage cage/wlr-randr /usr/bin
echo -e "$current_password\n" | sudo -S chmod +x /usr/bin/cage /usr/bin/wlr-randr

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

# copy libndk_fixer.so - this is needed to play roblox
echo -e "$current_password\n" | sudo -S mkdir -p /var/lib/waydroid/overlay/system/lib64
echo -e "$current_password\n" | sudo -S cp extras/libndk_fixer.so /var/lib/waydroid/overlay/system/lib64

# change GPU rendering to use minigbm_gbm_mesa
echo -e $PASSWORD\n | sudo -S sed -i "s/ro.hardware.gralloc=.*/ro.hardware.gralloc=minigbm_gbm_mesa/g" /var/lib/waydroid/waydroid_base.prop

# lets check if this is a reinstall
grep redfin /var/lib/waydroid/waydroid_base.prop &> /dev/null
if [ $? -eq 0 ]
then
	echo This seems to be a reinstall. No further config needed.

	# all done lets re-enable the readonly
	echo -e "$current_password\n" | sudo -S steamos-readonly enable
	echo Waydroid has been successfully installed!
else
	echo Config file missing. Lets configure waydroid.

	# lets initialize waydroid
	mkdir -p ~/waydroid/{images,cache_http}
	echo -e "$current_password\n" | sudo mkdir /var/lib/waydroid &> /dev/null
	echo -e "$current_password\n" | sudo -S ln -s ~/waydroid/images /var/lib/waydroid/images &> /dev/null
	echo -e "$current_password\n" | sudo -S ln -s ~/waydroid/cache_http /var/lib/waydroid/cache_http &> /dev/null
	echo -e "$current_password\n" | sudo -S waydroid init -s GAPPS

 	# check if waydroid initialization completed without errors
	if [ $? -eq 0 ]
	then
		echo Waydroid initialization completed without errors!
	else
		echo Waydroid did not initialize correctly. Performing cleanup!

		# remove binder kernel module
		echo -e "$current_password\n" | sudo -S rm /lib/modules/$kernel_version/binder_linux.ko.zst

		# remove installed packages
		echo -e "$current_password\n" | sudo -S pacman -R --noconfirm libglibutil libgbinder python-gbinder waydroid wlroots dnsmasq lxc

		# delete the waydroid directories and config
		echo -e "$current_password\n" | sudo -S rm -rf ~/waydroid /var/lib/waydroid ~/.local/share/waydroid ~/.local/share/application/waydroid* ~/AUR

		# delete waydroid config and scripts
		echo -e "$current_password\n" | sudo -S rm /etc/sudoers.d/zzzzzzzz-waydroid /etc/modules-load.d/waydroid.conf /usr/bin/waydroid-fix-controllers \
  		/usr/bin/waydroid-container-stop /usr/bin/waydroid-container-start

		# delete cage binaries
		sudo rm /usr/bin/cage /usr/bin/wlr-randr
		sudo rm -rf ~/Android_Waydroid &> /dev/null

		echo Cleanup completed! Try running the install script again! Goodbye!
		exit
	fi

	# firewall config for waydroid0 interface to forward packets for internet to work
	echo -e "$current_password\n" | sudo -S firewall-cmd --zone=trusted --add-interface=waydroid0 &> /dev/null
	echo -e "$current_password\n" | sudo -S firewall-cmd --zone=trusted --add-port=53/udp &> /dev/null
	echo -e "$current_password\n" | sudo -S firewall-cmd --zone=trusted --add-port=67/udp &> /dev/null
	echo -e "$current_password\n" | sudo -S firewall-cmd --zone=trusted --add-forward &> /dev/null
	echo -e "$current_password\n" | sudo -S firewall-cmd --runtime-to-permanent &> /dev/null

	# casualsnek script
	cd ~/AUR/waydroid/waydroid_script
	python3 -m venv venv
	venv/bin/pip install -r requirements.txt
	echo -e "$current_password\n" | sudo -S venv/bin/python3 main.py install {libndk,widevine}
	if [ $? -eq 0 ]
	then
		echo Casualsnek script done.
	else
		echo Error with casualsnek script.
	fi

	# lets change the fingerprint so waydroid shows up as a Pixel 5 - Redfin
	echo -e "$current_password\n" | sudo -S tee -a /var/lib/waydroid/waydroid_base.prop > /dev/null <<'EOF'

##########################################################################
# controller config for udev events
persist.waydroid.udev=true
persist.waydroid.uevent=true

##########################################################################
### start of custom build prop - you can safely delete if this causes issue

ro.product.brand=google
ro.product.manufacturer=Google
ro.system.build.product=redfin
ro.product.name=redfin
ro.product.device=redfin
ro.product.model=Pixel 5
ro.system.build.flavor=redfin-user
ro.build.fingerprint=google/redfin/redfin:11/RQ3A.211001.001/eng.electr.20230318.111310:user/release-keys
ro.system.build.description=redfin-user 11 RQ3A.211001.001 eng.electr.20230318.111310 release-keys
ro.bootimage.build.fingerprint=google/redfin/redfin:11/RQ3A.211001.001/eng.electr.20230318.111310:user/release-keys
ro.build.display.id=google/redfin/redfin:11/RQ3A.211001.001/eng.electr.20230318.111310:user/release-keys
ro.build.tags=release-keys
ro.build.description=redfin-user 11 RQ3A.211001.001 eng.electr.20230318.111310 release-keys
ro.vendor.build.fingerprint=google/redfin/redfin:11/RQ3A.211001.001/eng.electr.20230318.111310:user/release-keys
ro.vendor.build.id=RQ3A.211001.001
ro.vendor.build.tags=release-keys
ro.vendor.build.type=user
ro.odm.build.tags=release-keys

### end of custom build prop - you can safely delete if this causes issue
##########################################################################
EOF

	echo Adding shortcuts to game mode. Please wait.
	steamos-add-to-steam /home/deck/Android_Waydroid/Android_Waydroid_Cage.sh
	sleep 15
	echo Android_Waydroid_Cage.sh shortcut has been added to game mode.
	steamos-add-to-steam /usr/bin/steamos-nested-desktop
	sleep 15
	echo steamos-nested-desktop shortcut has been added to game mode.

	# all done lets re-enable the readonly
	echo -e "$current_password\n" | sudo -S steamos-readonly enable
	echo Waydroid has been successfully installed!
fi
