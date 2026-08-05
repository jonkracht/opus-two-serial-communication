#!/bin/bash

echo -e "\nMinicom/Opus Two auto-configurator\n"

# Communication parameters
declare DefaultDevice='/dev/ttyUSB0'
declare Baud='921600'
declare Term='xterm-256color'
declare Color='off'  # on/off; color looks bad with terminal transparency


# Display output of dmesg to determine device path 
echo -e "\nRelevant dmesg output:"
echo "******************************"
echo "(Enter root password)"
sudo dmesg | grep attached
echo "******************************"

echo ""
read -p "Enter path to device or press enter to use $DefaultDevice:  " newDevice

if [ -z "$newDevice" ]
then
    Device=$DefaultDevice
else
    Device=$newDevice
fi

echo -e "\nUsing device $Device"

# Start minicom
minicom --baudrate "$Baud" --device "$Device" --8bit --term="$Term" --color="$Color"
