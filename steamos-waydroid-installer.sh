#!/bin/bash

clear

echo SteamOS Waydroid Installer Script by ryanrudolf
echo https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer
sleep 2

kernel_version=$(uname -r)

# check kernel version. exit immediately if not 6.1.52-valve9-1-neptune-61
echo Checking if kernel is supported.
echo $kernel_version | grep 6.1.52-valve9-1-neptune-61 &> /dev/null
if [ $? -eq 0 ]
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

# this are the AUR git urls we need to build waydroid
AUR_CASUALSNEK=https://github.com/casualsnek/waydroid_script.git

# AUR directories for the git clone command
DIR_CASUALSNEK=~/AUR/waydroid/waydroid_script

# create AUR directory where waydroid and binder module will be downloaded
mkdir -p ~/AUR/waydroid 2> /dev/null

# download waydroid but lets cleanup the directory first in case its not empty
echo -e "$current_password\n" | sudo -S rm -rf ~/AUR/waydroid*

git clone $AUR_CASUALSNEK $DIR_CASUALSNEK

# disable the SteamOS readonly
echo -e "$current_password\n" | sudo -S steamos-readonly disable

# lets install binder
echo -e "$current_password\n" | sudo -S cp $kernel_version/binder/binder_linux.ko.zst /lib/modules/$kernel_version && sudo depmod -a && sudo modprobe binder_linux

if [ $? -eq 0 ]
then
	echo binder kernel module has been installed!
else
	echo Error installing binder kernel module. Goodbye!
	echo -e "$current_password\n" | sudo -S rm /lib/modules/$kernel_version/binder_linux.ko.zst
	echo -e "$current_password\n" | sudo -S steamos-readonly enable
	exit
fi

# ok lets install waydroid and cage
echo -e "$current_password\n" | sudo -S pacman -U cage/wlroots-0.16.2-1-x86_64.pkg.tar.zst waydroid/dnsmasq-2.89-1-x86_64.pkg.tar.zst \
	waydroid/lxc-1\:5.0.2-1-x86_64.pkg.tar.zst waydroid/libglibutil-1.0.74-1-x86_64.pkg.tar.zst waydroid/libgbinder-1.1.35-1-x86_64.pkg.tar.zst \
	waydroid/python-gbinder-1.1.2-1-x86_64.pkg.tar.zst waydroid/waydroid-1.4.2-1-any.pkg.tar.zst waydroid/weston-12.0.1-1-x86_64.pkg.tar.zst \
	--noconfirm --overwrite "*" 

if [ $? -eq 0 ]
then
	echo binder kernel module has been installed!
else
	echo Error installing waydroid and cage. Goodbye!
	echo -e "$current_password\n" | sudo -S steamos-readonly enable
	exit
fi

# waydroid has been installed. lets make sure the service doesnt start on startup 
echo -e "$current_password\n" | sudo -S systemctl disable waydroid-container.service

# lets install the custom config files
mkdir ~/Android_Waydroid 2> /dev/null

# waydroid kernel module
cat > ~/Android_Waydroid/waydroid.conf << EOF
binder_linux
EOF

# waydroid start service
cat > ~/Android_Waydroid/waydroid-container-start << EOF
#!/bin/bash
systemctl start waydroid-container.service
sleep 5
ln -s /dev/binderfs/binder /dev/anbox-binder 2> /dev/null
chmod o=rw /dev/anbox-binder
EOF

# waydroid stop service
cat > ~/Android_Waydroid/waydroid-container-stop << EOF
#!/bin/bash
systemctl stop waydroid-container.service
EOF

# waydroid fix controllers
cat > ~/Android_Waydroid/waydroid-fix-controllers << EOF
#!/bin/bash
echo add > /sys/devices/virtual/input/input*/event*/uevent
EOF

# custom sudoers file do not ask for sudo for the custom waydroid scripts
cat > ~/Android_Waydroid/zzzzzzzz-waydroid << EOF
deck ALL=(ALL) NOPASSWD: /usr/bin/waydroid-container-stop
deck ALL=(ALL) NOPASSWD: /usr/bin/waydroid-container-start
deck ALL=(ALL) NOPASSWD: /usr/bin/waydroid-fix-controllers
EOF

# weston config file
cat > ~/Android_Waydroid/weston.ini << EOF
[core]
idle-time=0

[shell]
locking=false
clock-format=none
panel-position=none
background-image=/home/deck/Android_Waydroid/android.jpg
background-type=scale-crop
EOF

# waydroid launcher - weston
cat > ~/Android_Waydroid/Android_Waydroid_Weston.sh << EOF
#!/bin/bash

killall -9 weston &> /dev/null
sudo /usr/bin/waydroid-container-stop
sudo /usr/bin/waydroid-container-start

if [ -z "\$(pgrep weston)" ]; then
	/usr/bin/weston --socket=weston-waydroid --width=1280 --height=800 &> /dev/null &
fi

# Launch Waydroid
sleep 10 &&
export XDG_SESSION_TYPE='wayland'
export WAYLAND_DISPLAY='weston-waydroid'
/usr/bin/waydroid show-full-ui \$@ &

sleep 15
sudo /usr/bin/waydroid-fix-controllers
EOF

# waydroid launcher - cage
cat > ~/Android_Waydroid/Android_Waydroid_Cage.sh << EOF
#!/bin/bash

killall -9 cage &> /dev/null
sudo /usr/bin/waydroid-container-stop
sudo /usr/bin/waydroid-container-start

# Launch Waydroid via cage
cage -- ~/Android_Waydroid/cage_helper.sh
EOF

# waydroid launcher - cage helper script
cat > ~/Android_Waydroid/cage_helper.sh << EOF
#!/bin/bash

# Launch Waydroid via cage
wlr-randr --output X11-1 --custom-mode 1280x800@60Hz 
/usr/bin/waydroid show-full-ui \$@ &

sleep 15
sudo /usr/bin/waydroid-fix-controllers
EOF

# uninstall script
cat > ~/Android_Waydroid/uninstall.sh << EOF
#!/bin/bash

kernel_version=\$(uname -r)

# disable the steamos readonly
sudo steamos-readonly disable

# remove the kernel module and packages installed
sudo systemctl stop waydroid-container
sudo rm /lib/modules/\$kernel_version/binder_linux.ko.zst
sudo pacman -R --noconfirm libglibutil libgbinder python-gbinder waydroid wlroots dnsmasq lxc weston

# delete the waydroid directories and config
sudo rm -rf ~/waydroid /var/lib/waydroid ~/.local/share/waydroid ~/.local/share/application/waydroid* ~/AUR

# delete waydroid config and scripts
sudo rm /etc/sudoers.d/zzzzzzzz-waydroid
sudo rm /etc/modules-load.d/waydroid.conf
sudo rm /usr/bin/waydroid-fix-controllers
sudo rm /usr/bin/waydroid-container-stop
sudo rm /usr/bin/waydroid-container-start

# delete cage binaries
sudo rm /usr/bin/cage /usr/bin/wlr-randr
sudo rm -rf ~/Android_Waydroid &> /dev/null

# re-enable the steamos readonly
sudo steamos-readonly enable
EOF

# lets enable the binder module so we can start waydroid right away
echo -e "$current_password\n" | sudo -S modprobe binder_linux

# custom configs done. lets move them to the correct location
chmod +x ~/Android_Waydroid/uninstall.sh
chmod +x ~/Android_Waydroid/waydroid-*
chmod +x ~/Android_Waydroid/Android_Waydroid_Weston.sh
chmod +x ~/Android_Waydroid/Android_Waydroid_Cage.sh
chmod +x ~/Android_Waydroid/cage_helper.sh
sudo mv ~/Android_Waydroid/waydroid.conf /etc/modules-load.d/waydroid.conf
echo -e "$current_password\n" | sudo -S mv ~/Android_Waydroid/zzzzzzzz-waydroid /etc/sudoers.d/zzzzzzzz-waydroid
echo -e "$current_password\n" | sudo -S chown root:root /etc/sudoers.d/zzzzzzzz-waydroid &> /dev/null
echo -e "$current_password\n" | sudo -S mv ~/Android_Waydroid/waydroid-container-start /usr/bin/waydroid-container-start
echo -e "$current_password\n" | sudo -S mv ~/Android_Waydroid/waydroid-container-stop /usr/bin/waydroid-container-stop
echo -e "$current_password\n" | sudo -S mv ~/Android_Waydroid/waydroid-fix-controllers /usr/bin/waydroid-fix-controllers
cp android.jpg ~/Android_Waydroid/android.jpg
mv ~/Android_Waydroid/weston.ini ~/.config/weston.ini

# lets copy cage and wlr-randr to the correct folder
sudo cp cage/cage cage/wlr-randr /usr/bin
sudo chmod +x /usr/bin/cage
sudo chmod +x /usr/bin/wlr-randr

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
	echo -e "$current_password\n" | sudo -S ln -s ~/waydroid/images /var/lib/waydroid/images
	echo -e "$current_password\n" | sudo -S ln -s ~/waydroid/cache_http /var/lib/waydroid/cache_http
	echo -e "$current_password\n" | sudo -S waydroid init -s GAPPS
	
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
	echo -e "$current_password\n" | sudo -S tee -a  /var/lib/waydroid/waydroid_base.prop > /dev/null <<'EOF'

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
	steamos-add-to-steam /home/deck/Android_Waydroid/Android_Waydroid_Weston.sh
	sleep 15
	echo Android_Waydroid_Weston.sh shortcut has been added to game mode.
	steamos-add-to-steam /usr/bin/steamos-nested-desktop
	sleep 15
	echo steamos-nested-desktop shortcut has been added to game mode.
	
	# all done lets re-enable the readonly
	echo -e "$current_password\n" | sudo -S steamos-readonly enable
	echo Waydroid has been successfully installed!
fi
