#!/bin/bash

if [ "$(id -u)" -eq 0 ]; then
    return 0 2>/dev/null || exit 0
fi

LOGDIR="$HOME/.local/share/swl"
LOGFILE="$LOGDIR/swl.log"
export LOGFILE
MAXSIZE=$((1024 * 1024)) # 1MB

mkdir -p "$LOGDIR"

# Rotate log if too big
if [ -f "$LOGFILE" ] && [ "$(stat -c%s "$LOGFILE")" -ge "$MAXSIZE" ]; then
    mv "$LOGFILE" "$LOGFILE.old"
    touch "$LOGFILE"
fi

# Ensure the log file exists and is writable
if ! touch "$LOGFILE"; then
    echo "Cannot create or write to $LOGFILE. Exiting."
    exit 1
fi
exec > >(tee -a "$LOGFILE") 2>&1