#!/bin/bash 


function CheckHex {
#file path, Ghidra offset, Hex to check
commandoutput="$(od $1 --skip-bytes=$(($2-0x101000)) --read-bytes=$((${#3} / 2)) --endian=little -t x1 -An file | sed 's/ //g')"
if [ "$commandoutput" = "$3" ]; then
echo "1"
else
echo "0"
fi
}

function PatchHex {
#file path, ghidra offset, original hex, new hex
file_offset=$(($2-0x101000))
if [ $(CheckHex $1 $2 $3) = "1" ]; then
    hexinbin=$(printf $4 | xxd -r -p)
    echo -n $hexinbin | dd of=$1 seek=$file_offset bs=1 conv=notrunc;
    tmp="Patched $1 at $file_offset with new hex $4"
    echo $tmp
elif [ $(CheckHex $1 $2 $4) = "1" ]; then
    echo "Already patched"
else
    echo "Hex mismatch!"
fi
}


ndk_path="/var/lib/waydroid/overlay/system/lib64/libndk_translation.so"

if [ -f $ndk_path ]; then
    if [ -w ndk_path ] || [ "$EUID" = 0 ]; then
        PatchHex $ndk_path 0x307dd1 83e2fa 83e2ff
        PatchHex $ndk_path 0x307cd6 83e2fa 83e2ff

    else
        echo "libndk_translation is not writeable. Please run with sudo"
    fi
else
    echo "libndk_translation not found. Please install it first."
fi
