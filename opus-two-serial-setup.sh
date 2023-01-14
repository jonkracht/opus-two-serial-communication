#!/bin/bash

# Communication parameters
declare PortPath='/dev/ttyUSB0'
declare Baud='921600'
declare Term='xterm-256color'
declare Color='off'  # looks kind of crappy with transparency


minicom --baudrate $Baud --device $PortPath --8bit --term=$Term --color=$Color
