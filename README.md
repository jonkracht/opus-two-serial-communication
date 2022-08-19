Jon Kracht   
Initial development July 2021; updated January 2022, August 2022



# Configuring the Opus Two Control System using Linux

What follows are steps to enable communication between a computer running a GNU/Linux operating system and the [Opus Two Control System](https://www.opustwoics.com/) which is used to control pipe organs.  The control system is hereafter referred to as "O2".
The computer used in development was a laptop running Ubuntu 20.04.
The steps detailed below seem general-enough that they should be possible on other flavors of Linux.


## Summary of the procedure  
1. Install a terminal emulator (minicom) 
2. Connect computer to O2 via cable  
3. Allow read/write permissions on O2 
4. Make a config file
5. Begin communication  
6. Do things (ex. upload configurations files, modify tremolo parameters, etc.)  




### 1.  Install a terminal emulator


We'll use minicom, a free and open source, terminal-based serial communication program to interface with O2.  
Some documentation on minicom:
* [Source code](https://salsa.debian.org/minicom-team/minicom)  
* [User's manual](https://www.man7.org/linux/man-pages/man1/minicom.1.html)

Note, other terminal emulators (putty, cutecom, xterm, uxterm) were briefly examined but minicom was ultimately chosen.
It's probable that another emulator may be used to the same effect.

 
Minicom is available in the Ubuntu 20.04 repos (edit: also, PopOS 22.04) and so may simply installed using the `apt` package manager (open a terminal and run the command `sudo apt install minicom`).
It is also available as a snap package or built directly from source.
In any event, determine which installation method is best for your system and do so.







### 2.  Connect PC to O2 via cable


O2 contains a micro-USB port through which serial communication may set up.  
Find a cable that is able to connect your computer to this port.
A USB-A port was available on the development computer and so the following steps reflect a connection of this type.






### 3. Allow read/write permissions on O2

Once the computer and O2 are physically connected via cable,  determine the `[DEVICE_NAME]` using the `dmesg` command.  
Here's a thorough guide to the procedure:
[Examples of determining the device name](https://help.ubuntu.com/community/Minicom)

In development,the `[DEVICE_NAME]` was determined to be `ttyUSB0` and so was mounted to the computer's filesystem at `/dev/ttyUSB0`.

To change the permissions of the device to allow both read and write operations, run:

```BASH
sudo chmod 666 /dev/DEVICE_NAME
```
where `DEVICE_NAME` was determined previously.

Alternatively, adding the Linux user to the group of which the `[DEVICE_NAME]` is a member will grant the desired read/write privileges.
Determine this appropriate group name by running:
```bash
ls -lah [/PATH/TO/DEVICE]
```

Common groups include 'dialout' and 'uucp'.
Add the user to this group using the `usermod` command (something like `sudo usermod -a -G [groupname] [username]`).





### 4.  Make a config file

We'll now create a configuration file setting necessary communication parameters given in the [CVA/CVE Technical Guide](https://www.opustwoics.com/s/ARM-TG-Updaters.pdf) and displayed for convenience:

![O2-settings](/opus-two-serial-settings.png)

Explicitly, the parameters to be set are:
* Baud rate 921600 
* 8 bit data 
* No Parity 
* 1 Stop Bit
* No flow control



With necessary communication parameters now in hand, enter into minicom's setup menu by `sudo minicom -s`.
(Note, minicom must be executed here with superuser privileges since files in the root directory will be modified.)  

The setup menu system can be navigated using either arrow keys or vim-style hjkl keys, ENTER, and ESCAPE.

#### Steps to create configuration file:
1. Input communication parameters by entering "Serial port setup" submenu
    * Verify that "Serial Device" lists correct `[DEVICE_NAME]`
    * Set "Bps/Par/Bits" to 921600 8N1
    * Set both Hard and Software Flow Controls to 'No'

2. Set the location from which files are to be up/downloaded in "Filenames and paths"
    * Enter the paths in the "Download directory" and "Upload directory" fields.  If desired, may be the same location.

3. Save configuration either as the default or to a new (ideally informative) name
    * For default, select "Save setup as dfl". The default is used when minicom is run from the terminal without explicitly pointing to a configuration file
    * For a new name, choose "Save setup as..".  A name such as "ttyUSB0.opus-two-cs" is advantageous in that it conveys information about what setup the specific configuration is designed for.

Configuration files are saved to `/etc/minicom/` and are given names like `minirc.dfl` or `minirc.ttyUSB0.opus-two-cs`.  An example configuration file (minirc.ttyUSB0.opus-two-cs) is included in this repository for reference.



### 5.  Begin communication

The appropriate terminal command will differ depending if a default or a custom configuration file was created in the previous step.
* For default, simply run `minicom` in the terminal.
* For custom, run `minicom [CUSTOM_NAME]` in the terminal.

At this point, the terminal should display "Welcome to the Opus-Two CVA Terminal Interface" and it should be possible to perform tasks detailed in the O2 manual.


#### Minicom shortcuts



A few useful ones are listed here for convenience.  To input a shortcut, first press `CTRL + A` and then:

| Key | Action |
| --- | --- |
| X | Exit and reset |
| Z | Help menu |
| C | Clear screen |
| S | Send files |
| R | Receive files |
| O | Configure `minicom` |
| P | Communication parameters |


### 6.  Do things

Some common things to do.

#### Upload new Opus Two configuration file
1.  Hold `CTRL + Q` to reset the controller (terminal menu and pdf manual are inconsistent)
2.  Within 5 seconds, hit any key to enter file transfer mode.
3.  Press `CTRL + A` followed by 'S' to send a file.  
4.  Select 'xmodem' option. 
5.  Select the configuration file (wit extension '.bin') to be uploaded to the controller.

#### Modify tremolo parameters

Refer to O2 manual.

---

### Appendix

A few potentially helpful references:
* https://www.poftut.com/install-use-linux-minicom-command-tutorial-examples/
* https://bloggerbust.ca/post/how-to-configure-minicom-to-connect-over-usb-serial-uart/
* https://www.centennialsoftwaresolutions.com/post/configure-minicom-for-a-usb-to-serial-converter
* https://wiki.emacinc.com/wiki/Product_wiki


