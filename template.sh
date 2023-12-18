#!/bin/bash

# Kill any previous remnants
if [ "$(systemctl is-active waydroid-container.service)" == 'active' ]; then
	sudo /usr/bin/waydroid-container-stop
fi

# Launch Weston
killall -9 weston
sudo /usr/bin/waydroid-container-start

if [ -z "$(pgrep weston)" ]; then
	/usr/bin/weston --socket=weston-waydroid --width=1280 --height=800 &> /dev/null &
fi

# start the waydroid session but dont show the UI yet
sleep 10 &&
export XDG_SESSION_TYPE='wayland'
export WAYLAND_DISPLAY='weston-waydroid'
/usr/bin/waydroid session start $@ &

sleep 15
sudo /usr/bin/waydroid-fix-controllers

# launch the android app automatically
/usr/bin/waydroid app launch com.netflix.mediaclient  &

