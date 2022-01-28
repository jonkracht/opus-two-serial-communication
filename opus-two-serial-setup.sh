#!/bin/bash

# Install minicom
sudo apt install minicom

# Communication parameters
declare port-path='/dev/ttyUSB0'
declare baud='921600'

# Run minicom
minicom --baudrate $baud --device $port-path --8bit  
