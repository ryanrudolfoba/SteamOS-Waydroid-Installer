#!/bin/bash

# Check if waydroid exists
if [ ! -f /usr/bin/waydroid ]
then
	kdialog --sorry "Cannot start Waydroid. Waydroid does not exist! \
	\nIf you recently performed a SteamOS update, then you also need to re-install / update Waydroid! \
	\n\nFollow the Waydroid upgrade guide here - https://youtu.be/CJAMwIb_oI0 \
	\n\nSteamOS version: $(cat /etc/os-release | grep -i VERSION_ID | cut -d "=" -f 2) \
	\nKernel version: $(uname -r | cut -d "-" -f 1-5)"
	exit
fi

run_waydroid () {
local APP=$1

# mount /var/lib/waydroid
sudo /usr/bin/waydroid-mount

# fix for intermittent broken internet connection and start waydroid container service
sudo /usr/bin/waydroid-firewall

# check the status of waydroid container
systemctl status waydroid-container.service | grep -i running
if [ $? -ne 0 ]
then
	kdialog --sorry "Something went wrong. Waydroid container did not initialize correctly."
	exit
fi

# Check if non Steam shortcut has the game / app as the launch option
if [ -z "$APP" ]
then
	# launch option not provided. launch Waydroid via cage and show the full ui right away
	LD_LIBRARY_PATH=$HOME/Android_Waydroid/cage $HOME/Android_Waydroid/cage/cage -- env RESOLUTION=$(xdpyinfo | awk '/dimensions/{print $2}') \
		bash -c 'wlr-randr --output X11-1 --custom-mode $RESOLUTION ; \
		/usr/bin/waydroid show-full-ui $@ & \

		sleep 10 ; \
		waydroid prop set persist.waydroid.fake_wifi $(cat config/fake_wifi) ; \
		waydroid prop set persist.waydroid.fake_touch $(cat config/fake_touch) ; \

		sudo /usr/bin/waydroid-startup-scripts'
else
	# launch option provided. launch the app from the arguments, then launch the Waydroid full ui so it doesnt crash when exiting the app provided
	LD_LIBRARY_PATH=$HOME/Android_Waydroid/cage $HOME/Android_Waydroid/cage/cage -- env APP="$1" RESOLUTION=$(xdpyinfo | awk '/dimensions/{print $2}') \
		bash -c 'wlr-randr --output X11-1 --custom-mode $RESOLUTION ; \
		/usr/bin/waydroid session start $@ & \
		
		sleep 10 ; \
		waydroid prop set persist.waydroid.fake_wifi $(cat config/fake_wifi) ; \
		waydroid prop set persist.waydroid.fake_touch $(cat config/fake_touch) ; \

		sudo /usr/bin/waydroid-startup-scripts ; \

		sleep 1 ; \
		/usr/bin/waydroid app launch $APP & \

		sleep 1 ; \
		/usr/bin/waydroid show-full-ui $@ &'
fi

# run shutdown scripts to cleanup when waydroid exits
while [ -n "$(pgrep cage)" ]
do
	sleep 1
done

sudo /usr/bin/waydroid-shutdown-scripts
}

# display menu
Menu_Choice=$(kdialog --radiolist "Select an item" \
	WAYDROID "Launch Waydroid" OFF \
	ROOT "Launch Waydroid with ROOT" OFF \
	EXIT "EXIT IMMEDIATELY" ON )

if [ $? -eq 1 ] || [ "$Menu_Choice" == "EXIT" ]
then
	kdialog --msgbox "User pressed EXIT / CANCEL. Goodbye!"
	exit

elif [ "$Menu_Choice" == "WAYDROID" ]
then
	run_waydroid $1

elif [ "$Menu_Choice" == "ROOT" ]
then
	kdialog --sorry "This is still in testing. It may / may not work. \
		\n\n But for the most part it works!"
	sudo /usr/bin/load-kernelsu -d
	run_waydroid $1
fi
