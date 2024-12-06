#!/bin/bash

# Check if waydroid exists
if [ ! -f /usr/bin/waydroid ]
then
	kdialog --sorry "Cannot start Waydroid. Waydroid does not exist! \
	\nIf you recently performed a SteamOS update, then you also need to re-install Waydroid! \
	\nLaunch the Waydroid install script again to re-install Waydroid! \
	\nSteamOS version: $(cat /etc/os-release | grep -i VERSION_ID | cut -d "=" -f 2) \
	\nKernel version: $(uname -r | cut -d "-" -f 1-5)"
	exit
fi

# Try to kill cage gracefully using SIGTERM
timeout 5s killall -15 cage -w &> /dev/null
if [ $? -eq 124 ]
then
	# Timed out, process still active, let's force some more using SIGINT
	timeout 5s killall -2 cage -w &> /dev/null
	if [ $? -eq 124 ]
	then
		# Timed out again, this will shut it down for good using SIGKILL
		timeout 5s killall -9 cage -w &> /dev/null
	fi
fi

export RESOLUTION=$(xdpyinfo | awk '/dimensions/{print $2}')
export RES_X=$(echo $RESOLUTION | cut -d 'x' -f1)
export RES_Y=$(echo $RESOLUTION | cut -d 'x' -f2)

# ask if Landscape or Portrait
SCREEN_ORIENTATION=$(kdialog --radiolist "Select Waydroid Orientation:" \
       1 "Landscape $RES_X x $RES_Y" on \
       2 "Portrait $RES_Y x $RES_X" off)

if [ $? -eq 1 ]
then
	kdialog --sorry "User pressed CANCEL.\nGoing back to Game Mode."
	exit

elif [ $SCREEN_ORIENTATION -eq 1 ]
then
	export TRANSFORM=normal
	export HEIGHT=$RES_Y
	export WIDTH=$RES_X

elif [ $SCREEN_ORIENTATION -eq 2 ]
then
	export TRANSFORM=90
	export HEIGHT=$RES_X
	export WIDTH=$RES_Y
fi

# stop and start the waydroid container
sudo /usr/bin/waydroid-container-stop
sudo /usr/bin/waydroid-container-start
systemctl status waydroid-container.service | grep -i running
if [ $? -eq 0 ]
then
	echo All good continue with the script.
else
	kdialog --sorry "Something went wrong. Waydroid container did not initialize correctly."
	exit
fi

# Check if non Steam shortcut has the game / app as the launch option
if [ -z "$1" ]
	then
		# launch option not provided. launch Waydroid via cage and show the full ui right away
		cage -- bash -c 'wlr-randr --output X11-1 --transform $TRANSFORM --custom-mode ${RESOLUTION}@60Hz ;	\
			/usr/bin/waydroid session start $@ & \
			sleep 5 ;\
			waydroid prop set persist.waydroid.height $HEIGHT ;\
			waydroid prop set persist.waydroid.width $WIDTH ;\
			/usr/bin/waydroid session stop ;\
			
			/usr/bin/waydroid session start $@ & \
			sleep 15 ; \

			sudo /usr/bin/waydroid-startup-scripts ;\
			/usr/bin/waydroid show-full-ui $@ & '
	else
		# launch option provided. launch Waydroid via cage but do not show full ui, launch the app from the arguments, then launch the full ui so it doesnt crash when exiting the app provided
		cage -- env PACKAGE="$1" bash -c 'wlr-randr --output X11-1 --transform $TRANSFORM --custom-mode ${RESOLUTION}@60Hz ; \
			/usr/bin/waydroid session start $@ & \
			sleep 5 ;\
			waydroid prop set persist.waydroid.height $HEIGHT ;\
			waydroid prop set persist.waydroid.width $WIDTH ;\
			/usr/bin/waydroid session stop ;\
			
			/usr/bin/waydroid session start $@ & \
			sleep 15 ; \

			sudo /usr/bin/waydroid-startup-scripts ; \

			sleep 5 ; \
			/usr/bin/waydroid app launch $PACKAGE & \

   			sleep 1 ; \
      			/usr/bin/waydroid show-full-ui &'
fi

# Reset cage so it doesn't nuke the display environment variable on exit
while [ -n "$(pgrep cage)" ]
do
	sleep 1
done

cage -- bash -c 'wlr-randr'
