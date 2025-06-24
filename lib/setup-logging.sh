#!/bin/bash

LOGDIR="$HOME/.local/share/swl"
LOGFILE="$LOGDIR/swl.log"
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
exec >> "$LOGFILE" 2>&1