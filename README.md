# Configuring an Opus Two controller using Linux

The following details a procedure to enable serial communication between a Linux computer and an [Opus Two](https://www.opustwoics.com/) (hereafter to referred to simply as "O2") controller card.

The method was initially developed on a laptop running Ubuntu 20.04.  Pop!_OS 22.04 and Arch Linux were later used for fine-tuning and so this process should be general-enough so that it is broadly portable to other flavors of Linux.

Most of the steps are performed in the terminal so you must have something like kitty, alacritty, ghosty, konsole, gnome-terminal, etc. installed.




***Summary of the procedure***  

1. Install a serial communication program (minicom) on the Linux computer 
2. Connect the computer to the O2 controller card via cable  
3. Grant read/write permissions on device 
4. Create a minicom configuration file
5. Begin serial communication  
6. Do things!  (modify system configurations files, tremolo parameters, etc.)


**Initial development July 2021**

**Updated January 2022, August 2022, January 2023, August 2026**


## Procedure

### 1.  Install a serial communication program on the Linux computer


We'll use minicom, a free and open source, terminal-based serial port communication program.  


Some documentation:
* [Source code](https://salsa.debian.org/minicom-team/minicom)  
* [User's manual](https://www.man7.org/linux/man-pages/man1/minicom.1.html)


Other terminal emulators (putty, cutecom, xterm, uxterm) were briefly examined during initial development but minicom was ultimately chosen.
It's probable that any of the others may be used to similar effect.


For each of the machines used in development (Ubuntu 20.04, Pop 22.04 and Arch Linux in 2026), minicom was available in the default repositories.  In this case, you may simply install it via a command like `sudo apt install minicom` or `sudo pacman -S minicom`.
If it is not provided by default, [build it from source](https://salsa.debian.org/minicom-team/minicom).


Minicom version 2.11.1 was used in August 2026.




### 2. Connect the computer to the O2 controller card via cable  


The O2 controller card contains two micro-USB ports.  The one marked 'TERM' is used for serial communication.

Find a cable that can connect your computer to this port.
A USB-A port was available on the development computer and so the following steps reflect a connection of this type.






### 3. Grant permissions

On a Linux system, the scope of the actions a user may perform is set by the system administrator or root user.  
To allow serial communications, the user must be a member of the `dialout` group on a Debian-based distribution and the `uucp` group on Arch.  To add the user to one of these groups:

```bash
sudo usermod -a -G [GROUP_NAME] [USER_NAME]
```

In addition, the device's read-write permissions may need to be manually set.
With the computer and the controller card physically connected by a cable, determine the `[DEVICE_NAME]`:
```bash
sudo dmesg | grep tty
```

[HERE](https://help.ubuntu.com/community/Minicom) is some additional description.
In development, the `[DEVICE_NAME]` was `ttyUSB0` and was located at `/dev/ttyUSB0`.

To grant both read and write privileges:
```BASH
sudo chmod 666 /dev/[DEVICE_NAME]
```
where `[DEVICE_NAME]` was determined previously via `dmesg`.










### 4.  Create a minicom configuration file

We'll now create a minicom configuration file setting communication parameters listed in the [CVA/CVE Technical Guide](https://www.opustwoics.com/s/ARM-TG-Updaters.pdf) (Page 14) and shown here for convenience:

![O2-settings](/opus-two-serial-settings.png)  


Explicitly, the parameters being set are:
* Baud rate 921600 
* 8 bit data 
* No Parity 
* 1 Stop Bit
* No flow control



Enter minicom's setup menu:
```bash
sudo minicom -s
```

Minicom is executed here with superuser privileges since the config file being created with be saved in the root file system.  If, instead, `sudo` is omitted, you would be able enter the setup and modify parameters but ultimately unable to save it for later use.

The menu system can be navigated using either arrow keys or vim-style 'hjkl' keys, ENTER, and ESCAPE.



#### Steps to create configuration file

1. Input communication parameters by entering "Serial port setup" sub-menu
    * Verify that "A - Serial Device" lists the correct device path
    * Set "E - Bps/Par/Bits" to 921600 8N1
    * Set both Hard and Software Flow Controls (entries F and G) to 'No'

2. If desired, set the location from which files will be up/downloaded in the "Filenames and paths" sub-menu

3. Save configuration either as the default or with a application-specific name
    * For default, select "Save setup as dfl". The default is used when minicom is run without explicitly pointing to a configuration file (i.e. simply `minicom`)
    * For an application-specific name, select "Save setup as..".  A name like "ttyUSB0.opus-two-cs" helps to provide context about the specific configuration.  `minirc.` will be prepended to this name in the eventual file saved.

The location to which the config is saved varies between systems but will likely be `/etc/minicom` or `/etc`.
If it is elsewhere, locate via:
```bash
sudo find / -name "minirc.*"
```

Some minicom installations include an example config located at `/usr/share/doc/minicom/examples/minirc.dfl`.
Additionally, a sample config files are included in this repo for reference.







### 5.  Begin serial communication

The appropriate terminal command will differ depending if a default or a custom configuration file was created in the previous step.
* To run the default configuration, simply run `minicom`
* To run some other configuration, run `minicom [CUSTOM_CONFIG_NAME]` where 'minirc.' is removed from the file name


Serial communication should now be initiated and "Welcome to the Opus-Two CVA Terminal Interface" should be visible in the terminal.

If the display is jittering, press 'z' to stabilize it.


#### Alternative communication method

Rather than creating a config file, pass serial communication parameters via flags:

```bash
minicom --baudrate 921600 --device /dev/ttyUSB0 --8bit --term=xterm-256color
```

Minicom does not provide flags for Hardware or Software flow control so it's possible this method may not work.

A bash script is included in this repository that automatically sets parameters and initializes communication with the O2 controller.
Grant execution privileges and run via `./opus-two-serial-setup.sh`


### 6.  Do things!


#### Upload configuration file to the controller

##### Dependencies

Organ-specific config files are input to the O2 controller card via the `xmodem` protocol.
Since minicom itself does not perform file transfers, additional software is required.
Specifically, the `sx` binary is recommended.
On may Linux distributions, it is provided by the `lrzsz` package and invoked via `lrzsz-sx`.

Once the `sx` binary is installed, ensure that your minicom configuration correctly invokes it.
In the "File transfer protocols" section of the minicom setup, ensure that the path to the `sx` executable is correct (i.e. matches `which lrzsz-sx`) and it is called with the necessary flags.
The `-X` flag ensures that the xmodem protocol (rather than ymodem or zmodem) is used.
Properly configured, the "Program" column should show something like `/usr/bin/lrzsz-sx -vv -X`.


##### Procedure

With communication initiated and the terminal showing the main menu of the O2 controller:

1.  Reset controller via `CTRL + Q` or `CTRL + SHIFT + Q`.
2.  Within five seconds of reset, press any key to place the controller into file transfer mode.
3.  Press `CTRL + A` followed by `S` to transfer a file via minicom.  
4.  Select the 'xmodem' option. 
5.  Select the config (with extension '.bin') to be uploaded to the controller.

If the file selector opens in a location other than where the config is located, you may navigate the file system by pressing spacebar twice to enter into a directory.
Selecting `[..]` will navigate to the parent directory.  Once the config has been located, highlight it by pressing spacebar once.
Hightlight "[Okay]" in the toolbar at the bottom of the screen and press Enter to begin the transfer.
A window should open displaying progress.

If the transfer was successful and the config was properly written/compiled, the organ should now perform in the manner specified by the uploaded config.




#### Modify tremolo behavior

Alter frequency and/or depth.

Refer to Opus Two documentation.







## TODO

* Unable to initiate communication with controller a second time (must be unplugged and replugged)
* Where are the rest of minicom's config parameters saved?  minirc.dfl only shows a few.  Perhaps only saves parameters that are "non-default".
* Commandline flag to set flow controls
* Testing controller card seems to timeout/freeze serial communication after about a minute of uptime.  This correlates to a yellow LED going from blinking to solidly on.
* Investigate modern serial communication programs:  TIO and screen.  tabby, cetus, and GTKTERM do not support xmodem protocol.  Seems like xmodem is not being supported.
* TeraTerm link is broken in O2 documentation.  Is project still active?



## Appendices


### Opus Two

The UART protocol is used between the computer and controller card.
The controller includes a USB to UART bridge to enable the protocol between modern machines.


### Minicom notes

#### Flags
* `-c [on/off]` controls whether minicom's menus are displayed in color.
* `-capturefile /PATH/TO/FILE`  saves minicom output to a log file for later examination


#### Shortcuts

Show help menu via C-A then z

![minicom-commands](/minicom-commands.png)


#### Misc

In the config file, flow controls are set via the 'rtscts' parameter.
The acronyms stand for "request to send" and "clear to send".


##### $TERM value

Minicom seems to not like environment variable `TERM=xterm-kitty`.  
Use a terminal whose $TERM variable is `xterm-i256color` or manually reset via `export TERM=xterm-256color` or pass into minicom by including `--term=xterm-256color` flag.


### Alternate transfer method

Set controller into waiting-for-transfer mode by resetting (C-Q) and hitting any key.
Input into another terminal window:

```bash
lrzsz-sx -k /PATH/TO/O2/config/bin < /PATH/TO/PORT > /PATH/TO/PORT
```

This method will perhaps provide more informative debugging output than minicom's.




## References

* https://www.poftut.com/install-use-linux-minicom-command-tutorial-examples/
* https://bloggerbust.ca/post/how-to-configure-minicom-to-connect-over-usb-serial-uart/
* https://www.centennialsoftwaresolutions.com/post/configure-minicom-for-a-usb-to-serial-converter
* https://wiki.emacinc.com/wiki/Product_wiki


