#!/bin/bash
#
# spice-resize-monitor - Auto-resize display for SPICE guests
# on non-GNOME desktops (MATE, XFCE, etc.)
#
# spice-vdagent fails to auto-apply resolution changes on desktops
# that don't provide org.gnome.Mutter.DisplayConfig over DBus.
# This script listens for RandR events and applies the preferred
# resolution immediately.
#

set -euo pipefail

# Find active X display and user
DISPLAY=:0
export DISPLAY

USER=$(who | grep '(:[0-9]*)' | head -1 | awk '{print $1}')
if [ -z "$USER" ]; then
    echo "No X user session found, exiting." >&2
    exit 1
fi

export XAUTHORITY=/home/$USER/.Xauthority

if [ ! -f "$XAUTHORITY" ]; then
    echo "Xauthority not found for user $USER, exiting." >&2
    exit 1
fi

# Apply current preferred resolution
/usr/bin/xrandr --output Virtual-1 --auto

# Listen for RandR events and apply resolution changes
exec xev -root -event randr | while read line; do
    /usr/bin/xrandr --output Virtual-1 --auto
done
