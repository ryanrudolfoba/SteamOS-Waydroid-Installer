#!/bin/bash
clone () {
local BRANCH=$(echo "$1" | tr '[:upper:]' '[:lower:]')
cd ~/
rm -rf ~/steamos-waydroid-installer
git clone --depth=1 https://github.com/ryanrudolfoba/steamos-waydroid-installer -b $BRANCH
cd ~/steamos-waydroid-installer
chmod +x steamos-waydroid-installer.sh
./steamos-waydroid-installer.sh
}

# display menu
Menu_Choice=$(kdialog --radiolist "Select an item" --geometry 750x200 \
	MAIN "Clone the MAIN branch of github.com/ryanrudolfoba/SteamOS-Waydroid-Installer and install it." OFF \
	TESTING "Clone the TESTING branch of github.com/ryanrudolfoba/SteamOS-Waydroid-Installer and install it." OFF \
	EXIT "EXIT IMMEDIATELY" ON )

if [ $? -eq 1 ] || [ "$Menu_Choice" == "EXIT" ]
then
	kdialog --msgbox "User pressed EXIT / CANCEL. Goodbye!"
	exit

elif [ "$Menu_Choice" == "MAIN" ]
then
	kdialog --warningyesno "This will clone the github.com/ryanrudolfoba/SteamOS-Waydroid-Installer $Menu_Choice branch and install automatically. \
		\n\n Do you want to continue? \n"
	if [ $? -eq 0 ]
	then
		clone $Menu_Choice
	else
		kdialog --msgbox "User pressed NO / CANCEL. Goodbye!"
		exit
	fi

elif [ "$Menu_Choice" == "TESTING" ]
then
	kdialog --warningyesno "This will clone the github.com/ryanrudolfoba/SteamOS-Waydroid-Installer $Menu_Choice branch and install automatically. \
		\n\n Do you want to continue? \n"
	if [ $? -eq 0 ]
	then
		clone $Menu_Choice
	else
		kdialog --msgbox "User pressed NO / CANCEL. Goodbye!"
		exit
	fi
fi
