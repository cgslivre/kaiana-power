#!/bin/bash
## Part of power installer
# Credits to: makubi
# See for more details: https://github.com/makubi/bash-helper-scripts/blob/master/libnotify/notify-send-as-root.sh

MESSAGE="$1"
ERROR="$2"
OWNER="$3"

USER_DBUS_PROC_NAME="gconfd-2"

if [ "$ERROR" == "true" ]; then
    ICON="error"
elif [ "$ERROR" == "false" ]; then
    ICON="power-installer"
else
    ICON=""
fi

# Get DBus session
DBUS_PID="$(ps ax | grep $USER_DBUS_PROC_NAME | grep -v grep | awk '{ print $1 }')"
DBUS_SESSION=`grep -z DBUS_SESSION_BUS_ADDRESS /proc/$DBUS_PID/environ | sed -e s/DBUS_SESSION_BUS_ADDRESS=//`

# Execution
DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION su -c "notify-send \"Power Installer\" \"$MESSAGE\" \"-i\" \"$ICON\"" "$OWNER"

exit "$?"
