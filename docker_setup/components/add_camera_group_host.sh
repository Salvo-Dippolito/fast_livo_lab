#!/bin/bash


#this has to be run in the host somehow



# Define the udev rule file
UDEV_RULES_FILE="/etc/udev/rules.d/80-drivers-SDK-2bdf.rules"
RULE='ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="2bdf", MODE="0666", GROUP="plugdev"'

# Ensure the script runs with root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script requires root privileges. Asking for sudo..."
   exec sudo "$0" "$@"
   exit 1
fi

# Check if the rule already exists
if grep -Fxq "$RULE" "$UDEV_RULES_FILE" 2>/dev/null; then
    echo " Udev rule is already present. No changes made."
else
    # Create or append the udev rule
    echo "$RULE" > "$UDEV_RULES_FILE"
    
    # Reload udev rules and apply changes
    udevadm control --reload-rules
    udevadm trigger

    echo " Udev rule applied successfully!"
    echo "You may need to unplug and replug the device or reboot."
fi

exit 0
