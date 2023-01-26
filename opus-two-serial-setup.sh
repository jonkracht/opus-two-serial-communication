#!/bin/bash

echo -e "\nWelcome to the Minicom frontend\n"

# Communication parameters
declare DefaultPath='/dev/ttyUSB0'
declare Baud='921600'
declare Term='xterm-256color'
declare Color='off'  # on/off; color looks bad with terminal transparency


# Display output of dmesg to determine device path 
echo "Relevant output of dmesg:"
echo "******************************"
sudo dmesg | grep attached
echo "******************************"

echo " "
read -p "Enter path to device or press enter to use $DefaultPath:  " inputPath

echo $inputPath

if [$inputPath -eq ""] 
then
    PortPath=$DefaultPath
else
    PortPath=$inputPath
fi

echo $PortPath

minicom --baudrate $Baud --device $PortPath --8bit --term=$Term --color=$Color
