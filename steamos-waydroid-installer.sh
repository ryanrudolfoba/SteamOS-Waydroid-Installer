#!/bin/bash

clear

echo SteamOS Waydroid Installer Script by ryanrudolf
echo https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer
sleep 2

# check SteamOS version. exit immediately if not on SteamOS 3.5.x
cat /etc/os-release | grep VERSION_ID | grep 3.5
if [ $? -eq 0 ]
then
	echo SteamOS 3.5.x detected. Proceed with the script.
else
	echo SteamOS 3.4.x detected. Exit immediately. Good bye!
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

# sudo password is already set by the end user, all good let's go!
echo -e "$current_password\n" | sudo -S ls &> /dev/null
if [ $? -eq 0 ]
then
	echo So far so good!
else
	echo Something went wrong make sure sudo is correct.  Re-run script!
	exit
fi

# this are the AUR git urls we need to build waydroid
AUR_WAYDROID=https://aur.archlinux.org/waydroid.git
AUR_BINDER=https://aur.archlinux.org/binder_linux-dkms.git
AUR_PYTHON_GBINDER=https://aur.archlinux.org/python-gbinder.git
AUR_LIBGBINDER=https://aur.archlinux.org/libgbinder.git
AUR_LIBGLIBUTIL=https://aur.archlinux.org/libglibutil.git
AUR_CASUALSNEK=https://github.com/casualsnek/waydroid_script.git

# AUR directories for the git clone command
DIR_WAYDROID=~/AUR/waydroid/waydroid
DIR_BINDER=~/AUR/waydroid/binder_linux-dkms
DIR_PYTHON_GBINDER=~/AUR/waydroid/python-gbinder
DIR_LIBGBINDER=~/AUR/waydroid/libgbinder
DIR_LIBGLIBUTIL=~/AUR/waydroid/libglibutil
DIR_CASUALSNEK=~/AUR/waydroid/waydroid_script

# disable the SteamOS readonly
echo -e "$current_password\n" | sudo -S steamos-readonly disable

# initialize pacman keyring
echo -e "$current_password\n" | sudo -S pacman-key --init && echo -e "$current_password\n" | sudo -S pacman-key --populate

if [ $? -eq 0 ]
then
	echo Pacman has been initialized!
else
	echo There was an error initializing pacman. good bye!
	echo -e "$current_password\n" | sudo -S steamos-readonly enable
	exit
fi

# create AUR directory where waydroid and binder module will be downloaded
mkdir -p ~/AUR/waydroid 2> /dev/null

# download waydroid but lets cleanup the directory first in case its not empty
echo -e "$current_password\n" | sudo -S rm -rf ~/AUR/waydroid*

git clone $AUR_WAYDROID $DIR_WAYDROID && git clone $AUR_BINDER $DIR_BINDER && git clone $AUR_PYTHON_GBINDER $DIR_PYTHON_GBINDER && git clone $AUR_LIBGBINDER $DIR_LIBGBINDER && git clone $AUR_LIBGLIBUTIL $DIR_LIBGLIBUTIL && git clone $AUR_CASUALSNEK $DIR_CASUALSNEK

if [ $? -eq 0 ]
then
	echo No errors encountered downloading from AUR.
else
	echo Errors were ecnountered downloading from AUR.
	echo Cleaninup up AUR directory. Try again. good bye!
	rm -rf ~/AUR/waydroid/*
	echo -e "$current_password\n" | sudo -S steamos-readonly enable
	exit
fi

# ok so far so good lets install the dependecies
echo -e "$current_password\n" | sudo -S pacman -S --noconfirm fakeroot base-devel glibc glib2 linux-api-headers linux-neptune-61-headers python3 lxc dnsmasq weston --overwrite "*" 

if [ $? -eq 0 ]
then
	echo Pacman dependencies has been installed!
else
	echo Error installing pacman dependencies. good bye!
	echo -e "$current_password\n" | sudo -S steamos-readonly enable
	exit
fi

# if this is a reinstall need to delete this file or else waydroid wont install
echo -e "$current_password\n" | sudo -S rm /etc/xdg/menus/applications-merged/waydroid.menu 2> /dev/null

# ok lets build and install waydroid
(cd $DIR_BINDER && makepkg --noconfirm -si -f && \
	cd $DIR_LIBGLIBUTIL && makepkg --noconfirm -si -f && \
	cd $DIR_LIBGBINDER && makepkg --noconfirm -si -f && \
	cd $DIR_PYTHON_GBINDER && makepkg --noconfirm -si -f &&
	cd $DIR_WAYDROID && makepkg --noconfirm -si -f)

if [ $? -eq 0 ]
then
	echo Waydroid has been installed!
else
	echo Error building and installing waydroid. good bye!
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
#sh -c 'for i in \$(seq 7 9); do echo add > /sys/class/input/event\$i/uevent; done'
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

# waydroid launcher
cat > ~/Android_Waydroid/Android_Waydroid.sh << EOF
#!/bin/bash

# Kill any previous remnants
if [ "\$(systemctl is-active waydroid-container.service)" == 'active' ]; then
	sudo /usr/bin/waydroid-container-stop
fi

# Launch Weston
killall -9 weston
sudo /usr/bin/waydroid-container-start

if [ -z "\$(pgrep weston)" ]; then
	/usr/bin/weston --socket=weston-waydroid --width=1280 --height=800 &> /dev/null &
fi

# Launch Waydroid
sleep 10 &&
export XDG_SESSION_TYPE='wayland'
export WAYLAND_DISPLAY='weston-waydroid'
/usr/bin/waydroid show-full-ui \$@ &

sleep 5
sudo /usr/bin/waydroid-fix-controllers
EOF

# uninstall script
cat > ~/Android_Waydroid/uninstall.sh << EOF
#!/bin/bash

# disable the steamos readonly
sudo steamos-readonly disable

# remove the kernel module and packages installed
sudo dkms remove binder/1
sudo pacman -R --noconfirm binder_linux-dkms libglibutil libgbinder python-gbinder waydroid weston

# delete the waydroid directories and config
sudo rm -rf ~/waydroid
sudo rm -rf /var/lib/waydroid
sudo rm -rf ~/.local/share/waydroid
sudo rm -rf ~/.local/share/application/waydroid*
sudo rm -rf ~/AUR
sudo rm /etc/sudoers.d/zzzzzzzz-waydroid
sudo rm /etc/modules-load.d/waydroid.conf
sudo rm /usr/bin/waydroid-fix-controllers
sudo rm /usr/bin/waydroid-container-stop
sudo rm /usr/bin/waydroid-container-start
sudo rm -rf ~/Android_Waydroid

# re-enable the steamos readonly
sudo steamos-readonly enable
EOF

# lets enable the binder module so we can start waydroid right away
echo -e "$current_password\n" | sudo -S modprobe binder_linux

# custom configs done. lets move them to the correct location
chmod +x ~/Android_Waydroid/uninstall.sh
chmod +x ~/Android_Waydroid/waydroid-*
chmod +x ~/Android_Waydroid/Android_Waydroid.sh
sudo mv ~/Android_Waydroid/waydroid.conf /etc/modules-load.d/waydroid.conf
echo -e "$current_password\n" | sudo -S mv ~/Android_Waydroid/zzzzzzzz-waydroid /etc/sudoers.d/zzzzzzzz-waydroid
echo -e "$current_password\n" | sudo -S chown root:root /etc/sudoers.d/zzzzzzzz-waydroid &> /dev/null
echo -e "$current_password\n" | sudo -S mv ~/Android_Waydroid/waydroid-container-start /usr/bin/waydroid-container-start
echo -e "$current_password\n" | sudo -S mv ~/Android_Waydroid/waydroid-container-stop /usr/bin/waydroid-container-stop
echo -e "$current_password\n" | sudo -S mv ~/Android_Waydroid/waydroid-fix-controllers /usr/bin/waydroid-fix-controllers
cp android.jpg ~/Android_Waydroid/android.jpg
mv ~/Android_Waydroid/weston.ini ~/.config/weston.ini

# lets check if this is a reinstall
grep redfin /var/lib/waydroid/waydroid_base.prop > /dev/null
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
	echo -e "$current_password\n" | sudo mkdir /var/lib/waydroid
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
	
	steamos-add-to-steam /home/deck/Android_Waydroid/Android_Waydroid.sh
	sleep 10
	echo Press ENTER as this seems to get stuck......
	echo Press ENTER as this seems to get stuck......
	steamos-add-to-steam /usr/bin/steamos-nested-desktop
	
	# all done lets re-enable the readonly
	echo -e "$current_password\n" | sudo -S steamos-readonly enable
	echo Waydroid has been successfully installed!
fi
