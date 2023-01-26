   

# Configuring the Opus Two Control System with Linux

The following details a procedure to enable communication between a computer running a GNU/Linux operating system and the [Opus Two Control System](https://www.opustwoics.com/), a system designed for the control of pipe organs and hereafter referred to simply as "O2".

A laptop running Ubuntu 20.04 was used during initial development and early updates.  Later modifications were done in Pop_OS! 22.04.
The procedure should be general-enough to be easily portable to other flavors of Linux.


**Initial development July 2021
Updated January 2022, August 2022, January 2023**





## Summary of the procedure  
1. Install a terminal emulator (minicom) 
2. Connect the computer to O2 via cable  
3. Allow read/write permissions on O2 
4. Make a configuration file
5. Begin communication  
6. Do things (ex. upload configurations files, modify tremolo parameters, etc.)  




### 1.  Install a terminal emulator


We'll use minicom, a free and open source, terminal-based serial port communication program to interface with O2.  


Some documentation on minicom:
* [Source code](https://salsa.debian.org/minicom-team/minicom)  
* [User's manual](https://www.man7.org/linux/man-pages/man1/minicom.1.html)

During initial development, other terminal emulators (putty, cutecom, xterm, uxterm) were briefly examined but minicom was ultimately chosen.
It's probable that any of the others may be used to similar effect.

 
Minicom is available in the Ubuntu 20.04 repository (edit: also, Pop_OS! 22.04) and so may simply installed using the `apt` package manager (in a terminal, run the command `sudo apt install minicom`).
It can also be installed as a snap package or built from source.
In any event, determine which installation method is best for your system and do so.







### 2.  Connect PC to O2 via cable


O2 contains a micro-USB port through which serial communication may be set up.  
Find a cable that can connect your computer to this port.
A USB-A port was available on the development computer and so the following steps reflect a connection of this type.






### 3. Allow read/write permissions on O2

Once the computer and O2 are physically connected via cable, determine the `[DEVICE_NAME]` using `dmesg` (a tool that prints kernel messages to stdout):
`sudo dmesg | grep tty`
[HERE](https://help.ubuntu.com/community/Minicom) is a thorough description on the process.
In development, the `[DEVICE_NAME]` was found to be `ttyUSB0` and was located in the file system at `/dev/ttyUSB0`.

There are two methods to grant read/write access to the device:
* Add user to the device's group
* Manually modify the privileges to the device

Of the two, the first option will needs only be performed once, while the second must be performed each time O2 is connected.


#### Manually modify privileges

To grant both read and write privileges, execute the following command in the terminal:


```BASH
sudo chmod 666 /dev/[DEVICE_NAME]
```
where `[DEVICE_NAME]` was determined previously.




#### Add user to device's group

Determine of which group the device is a member by executing:

```bash
ls -lah /dev/[DEVICE_NAME]
```

Common groups include `dialout` and `uucp`.

Add the user to this group via the `usermod` command:

```bash
sudo usermod -a -G [GROUP_NAME] [USER_NAME]
```








### 4.  Create a configuration file

We'll now create a configuration file setting communication parameters given in the [CVA/CVE Technical Guide](https://www.opustwoics.com/s/ARM-TG-Updaters.pdf) (Page 14) and shown here for convenience:

![O2-settings](/opus-two-serial-settings.png)  


Explicitly, the parameters to be set are:
* Baud rate 921600 
* 8 bit data 
* No Parity 
* 1 Stop Bit
* No flow control



Enter into minicom's setup menu by `sudo minicom -s`.
(Note, minicom is executed here with superuser privileges since the config files to be created are saved in the root file system.  If, instead, `sudo` is omitted, you would still be able to enter the setup menu but ultimately unable to save it for later use.)  

The menu system can be navigated using either arrow keys or vim-style 'hjkl' keys, ENTER, and ESCAPE.



#### Steps to create configuration file:

1. Input communication parameters by entering "Serial port setup"
    * Verify that "A - Serial Device" lists the correct `[DEVICE_NAME]`
    * Set "E - Bps/Par/Bits" to 921600 8N1
    * Set both Hard and Software Flow Controls (entries F and G) to 'No'

2. Set the location from which files are to be up/downloaded in "Filenames and paths"
    * Enter the paths in the "Download directory" and "Upload directory" fields.  If desired, may be the same location.

3. Save configuration either as the default or to a new, ideally informative name
    * For default, select "Save setup as dfl". The default is used when minicom is run from the terminal without explicitly pointing to a configuration file
    * For a new name, choose "Save setup as..".  A name such as "ttyUSB0.opus-two-cs" is advantageous in that it conveys information about for what setup the specific configuration is to be used.


Configuration files are saved to `/etc/minicom/` and are given names like "minirc.dfl" or "minirc.ttyUSB0.opus-two-cs".  An example configuration file "minirc.ttyUSB0.opus-two-cs" is included in this repository for refrence.
Also, a template configuration file is included in the installation and located at `/usr/share/doc/minicom/examples/minirc.dfl`.





### 5.  Begin communication

The appropriate terminal command will differ depending if a default or a custom configuration file was created in the previous step.
* If default was chosen, simply run `minicom` in the terminal.
* If custom, run `minicom [CUSTOM_NAME]` in the terminal.

At this point, the terminal should display "Welcome to the Opus-Two CVA Terminal Interface" and it should be possible to perform tasks listed in the O2 manual.  
If the display is jittering, press 'z'.




### 6.  Do things


#### Upload new Opus Two configuration file

1.  Reset controller by holding `CTRL + SHIFT + Q` (Note, terminal menu and manual are inconsistent whether the shift key is required.  Also, this key combination might conflict with other terminal shortcuts...)
2.  Within 5 seconds of resetting, press any key to enter file transfer mode.
3.  Press `CTRL + A` followed by 'S' to send a file.  
4.  Select 'xmodem' option. 
5.  Select the configuration file (with extension '.bin') to be uploaded to the controller.


#### Modify tremolo parameters
Frequency, depth.
Refer to O2 manual.





## Minicom

### Minicom flags
* `-con` use color


### Minicom shortcuts

Press CTRL + A then Z to enter help menu

![minicom-commands](/minicom-commands.png){ width=60%, height:30px }



## Miscellaneous notes
* Minicom seems to not like environment variable `TERM=xterm-kitty`.  Use a terminal whose $TERM variable is `xterm-i256color` or  manually reset via `export TERM=xterm-256color` or pass it in during function call via `--term=xterm-256color` flag


## TODO
* Unable to start main controller second time (must be unplugged and replugged to restart communication)


## Appendix

A few potentially helpful references:
* https://www.poftut.com/install-use-linux-minicom-command-tutorial-examples/
* https://bloggerbust.ca/post/how-to-configure-minicom-to-connect-over-usb-serial-uart/
* https://www.centennialsoftwaresolutions.com/post/configure-minicom-for-a-usb-to-serial-converter
* https://wiki.emacinc.com/wiki/Product_wiki


