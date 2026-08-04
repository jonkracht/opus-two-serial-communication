#!/bin/bash

echo -e "\nMinicom/Opus Two auto-configurator\n"

# Communication parameters
declare DefaultPath='/dev/ttyUSB0'
declare Baud='921600'
declare Term='xterm-256color'
declare Color='off'  # on/off; color looks bad with terminal transparency


# Display output of dmesg to determine device path 
echo "Relevant dmesg output:"
echo "******************************"
echo "(Enter root password)"
sudo dmesg | grep attached
echo "******************************"

echo " "
read -p -r "Enter path to device or press enter to use $DefaultPath:  " inputPath

echo "$inputPath"

if [ -z "$inputPath" ]
then
    PortPath=$DefaultPath
else
    PortPath=$inputPath
fi

echo "$PortPath"

# Start minicom
minicom --baudrate "$Baud" --device "$PortPath" --8bit --term="$Term" --color="$Color"
