Jon Kracht   
Originally created July 2021; updated January 2022


Procedure to set up serial communication between a Linux computer and the [Opus Two Control System](https://www.opustwoics.com/), hereafter referred to as "O2"



## Summary of the procedure  
1. Install minicom 
2. Connect PC to O2 via cable  
3. Modify permissions of device to allow communication  
4. Create a configuration file of communication parameters  
5. Begin communication  
6. Do things (modify tremolo speed/depth, upload O2 config files, etc.)  



---


### 1.  Install minicom


We'll use a minicom, a free and open source, terminal-based emulator to configure serial communication.  Some documentation on minicom:
* [Source code](https://salsa.debian.org/minicom-team/minicom)  
* [User's manual](https://www.man7.org/linux/man-pages/man1/minicom.1.html)

On Ubuntu or another Debian-based distribution using the apt package manager, install minicom by opening your favorite terminal (xterm, gnome-terminal, konsole, alacritty, kitty, etc.) and running:
```bash
sudo apt install minicom
```

Installation should be reasonably similar in other flavors of Linux.


### 2.  Connect PC to O2 via cable


O2 utilizes a USB-C port for communication.  Obtain a cable that can connect your computer to this USB-C port.   A USB-A port was available on the computer on which development occured so that is what is used in the following steps.



### 3.  Modify device permissions

Once the computer and O2 are physically connected via cable,  determine the `DEVICE_NAME` by running:  
```bash
dmesg | grep tty
```

In development where a USB-A cable was used, the device name was `ttyUSB0` and was mounted to the filesystem at `/dev/ttyUSB0`.
To change the permissions of the device to allow both read and write:

```BASH
sudo chmod 666 /dev/DEVICE_NAME
```
where `DEVICE_NAME` was determined previously.



### 4.  Create a config file

Now that minicom is installed, we'll create a configuration file setting necessary parameters given in the [CVA/CVE Technical Guide](https://www.opustwoics.com/s/ARM-TG-Updaters.pdf) and repeated here for convenience:
* Baud rate 921600 
* 8 bit data 
* No Parity 
* 1 Stop Bit
* No flow control

![O2-settings](/opus-two-serial-settings.png)

Enter minicom's setup menu by:
```vim
sudo minicom -s
```

Navigate menu using arrow keys, ENTER and ESCAPE.

Steps to create configuration file:
1. Input communication parameters by entering "Serial port setup" and:
    * Check that "Serial Device" lists correct path
    * Set "Bps/Par/Bits" to 921600 8N1
    * Set both Hard and Software Flow Controls to 'No'

2. Set the location from which files are to be up/downloaded in "Filenames and paths"
    * Input paths in the "Download directory" and "Upload directory" fields.  Can be the same location.

3. Save configuration either as the default or to a new, customized name
    * For default, select "Save setup as dfl". The default is used when minicom is run without explicitly giving a configuration file
    * For a customized name, choose "Save setup as..".  A name such as "ttyUSB0.opus-two-cs" is desirable in that it conveys information about what parameters are set in the config file.

Configuration files are saved to `/etc/minicom/` and are given names like `minirc.dfl` or `minirc.ttyUSB0.opus-two-cs`.  An example configuration file is included in this repository for reference.



### 5.  Begin communication


If the configuration file was saved as default in the previous step, simply run `minicom` in a terminal session.  Alternatively, if a custom name was chosen instead, run `minicom CUSTOM_NAME`.

At this point, the terminal should display "Welcome to the Opus-Two CVA Terminal Interface" menu.
You should be able to follow instructions given in the O2 manual to complete a desired action.


Minicom has its own set of commands that may be accessed by first pressing `CTRL + A` and then typing one of the following:
* X: exit and reset
* Z: help menu
* C: clear screen
* S: send files
* R: receive files
* O: configure minicom
* P: communication parameters



### 6.  Do things.

#### Upload new Opus Two configuration file
1.  Hold `CTRL + Q` to reset the controller (terminal menu and pdf manual are inconsistent)
2.  Within 5 seconds, hit any key to enter file transfer mode.
3.  Press `CTRL + A` followed by 'S' to send a file.  
4.  Select 'xmodem'.  
5.  Select the .bin configuration file you wish to upload to the controller.
6.  Witchcraft

#### Modify tremolo parameters

---


Some helpful references:

https://bloggerbust.ca/post/how-to-configure-minicom-to-connect-over-usb-serial-uart/
https://www.centennialsoftwaresolutions.com/post/configure-minicom-for-a-usb-to-serial-converter



