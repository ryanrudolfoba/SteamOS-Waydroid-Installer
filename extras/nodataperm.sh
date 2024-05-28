#!/system/bin/sh

# no data permission hack to circumvent the Android 11 scoped storage permission
# Thanks to PrimeOS

chmod 777 -R /sdcard/Android
chmod 777 -R /sdcard/Android/obb
chmod 777 -R /sdcard/Android/data
chmod 777 -R /data/media/0/Android
chmod 777 -R /data/media/0/Android/obb
chmod 777 -R /data/media/0/Android/data
chmod 777 -R /mnt/*/*/*/*/Android/obb
chmod 777 -R /mnt/*/*/*/*/Android/data
