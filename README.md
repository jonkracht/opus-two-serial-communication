Jon Kracht   
Started July 2021  
Updated January 2022


Procedure to allow serial communication between a Linux computer and the Opus Two Control System (hereafter abbreviated O2)


---


## Summary of the procedure  
1. Install minicom, a terminal-based serial communication program  
2. Connect PC to O2 with a cable of some sort  
3. Modify permissions of device to allow communication  
4. Create a configuration file of parameters required by O2  
5. Begin communication with O2  
6. Do things (modify trems, upload 02 config files, etc.)  


---


## Caveats:
This procedure was developed on a Linux laptop running Ubuntu 20.04 and used a USB-C to USB-A cable to connect to O2.  If your particular circumstances are different, procedure may also be different.


---


### 1.  Install minicom


We'll use a minicom to configure serial communication.

Some documentation on minicom:

Source:  https://salsa.debian.org/minicom-team/minicom
Manual:  https://www.man7.org/linux/man-pages/man1/minicom.1.html

On Ubuntu or other Debian based distributions, install minicom in your terminal by:
sudo apt install minicom

(On other varieties of Linux, the procedure will be different.  :( )


### 2.  Connect PC to O2 via cable

02 requires a USB-C.  Find a cable that can connect your computer which is USB-C on the other end.  My laptop has USB-A ports so that is what we will use.



### 3.  Modify device permissions

Once the computer and O2 are physically connected by cable, locate the device in the Linux filesystem.  Since a USB-A port was used in the previous step, the device is located at /dev/ttyUSB0.
In your favorite terminal (alacritty, xterm, gnome-terminal, etc.), run the following to determine the device name:
dmesg | grep tty

To change the permissions of the device to allow read/write, run:
sudo chmod 666 /dev/DEVICE_NAME
where DEVICE_NAME was identified previously.  Since sudo is used, you'll need root access on the system.



### 4.  Create a config file

Now that minicom is installed, we'll create a configuration file setting parameters given in page 20 of the O2 manual (reference?) and are repeated here for convenience:
 
Baud rate 921600 
8 bit data 
No Parity 
1 Stop Bit
No flow control

In the terminal run:
sudo minicom -s

Select 'Serial port setup' and enter the parameters
Additionally, set the location in which files are to be up/downloaded from in the "Filenames and paths" section.

Save configuration either as minicom's default or to a new, customized name
- For default, select "Save setup as dfl"
    When a config file is not explicitly given, minicom runs the default configuration

- For a custom name, choose "Save setup as..".  
    A name like ttyUSB0.opus-two-cs conveys information about what parameters are set in the config file.

Config files are saved to /etc/minicom/



### 5.  Begin communication

If configuration was saved as default, simply type minicom in a terminal.  

If saved to a custom name for example YOUR_CUSTOM_NAME, run:
minicom YOUR_CUSTOM_NAME

At this point, your computer should be talking to 02 and should be able to follow all instructions given in the 02 manual.

Minicom has its own set of commands that may be accessed by first pressing CTRL + A and then typing one of the following:
X to exit and reset
Z for help menu
C to clear screen
S to send files
R to receive files
O to configure minicom
P for communication parameters



### 6.  Do things.

Upload new Opus Two configuration file
1.  Hold CTRL + Q to reset the controller (terminal menu and pdf manual are inconsistent)
2.  Within 5 seconds, hit any key to enter file transfer mode.
3.  Press CTRL + A followed by 'S' to send a file.  
4.  Select 'xmodem'.  
5.  Select the .bin configuration file you wish to upload to the controller.
6.  Witchcraft

#########################################################################


Some helpful references:

https://bloggerbust.ca/post/how-to-configure-minicom-to-connect-over-usb-serial-uart/
https://www.centennialsoftwaresolutions.com/post/configure-minicom-for-a-usb-to-serial-converter



