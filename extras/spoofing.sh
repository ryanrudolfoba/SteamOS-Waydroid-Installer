#!/system/bin/sh

# fix for CoD Mobile controller. This will simulate a gamepad Xbox Wireless Controller in addition to the Xbox 360 controller
export CLASSPATH=/system/bin/classes.dex ; app_process / com.android.commands.hid.Hid
