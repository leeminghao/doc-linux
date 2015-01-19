U-Boot
================================================================================

U-boot is the bootloader commonly used on our allwinner SoCs. Amongst others, it provides the basic infrastructure to bring up a board to a point where it can load a linux kernel and start booting your operating system.

This page covers the sunxi branch of U-Boot. Increasingly sunxi devices are available from upstream U-Boot and we have a separate page for Mainline U-Boot.

Compile U-Boot
--------------------------------------------------------------------------------

Get a toolchain
If you haven't done so before, get a suitable toolchain installed and added to your PATH.
Clone the repository
You can clone our u-boot repository by running:

```
git clone https://github.com/linux-sunxi/u-boot-sunxi.git
```

This should checkout the sunxi branch, which allows booting from SD, over USB and over ethernet, but it still lacks support for booting off the NAND. For more information about booting from NAND, check the NAND howto.

Note: the 'sunxi' branch in the u-boot-sunxi repository is currently under active development and also frequently merges in the changes from the upstream u-boot. Expect it to be occasionally broken. There is no stable branch or tag at the moment. If something does not work correctly, please consider trying older revisions from the 'sunxi' branch or look for any possible not-yet-applied fixes in the linux-sunxi and u-boot mailing lists.
Determine build target

You can list the available u-boot targets by running:

```
grep sunxi boards.cfg | awk '{print $7}'
```

You will notice that some board names are duplicates, but with _FEL attached. These are for use with USBBoot, while the standard ones will boot from SD.

Build
--------------------------------------------------------------------------------

When you have determined what target you want to build, configure:

```
make CROSS_COMPILE=arm-linux-gnueabihf- {TARGET}_config
```

Then just build it:

```
make CROSS_COMPILE=arm-linux-gnueabihf-
```

You might want to add '-j4' to make use of 4 processors (or any number that matches your system), to speed up the build.

Boot
--------------------------------------------------------------------------------

When the build has completed, there will be spl/sunxi-spl.bin and u-boot.img available in your u-boot tree.

For getting these bits loaded onto the hardware, please refer to the respective howto:

* SD Card
* USB
* Ethernet
* NAND

Configure U-Boot
--------------------------------------------------------------------------------

TODO: Move these to their respective howtos
Setting environment variables

There is a difference in setting environment variables between the boot script and the u-boot shell.

Inside the shell you would set, for instance:

```
setenv root /dev/sda1
```

But in the script you would use:

```
root=/dev/sda1
```

### SD Card

```
setenv bootargs console=ttyS0,115200 root=/dev/mmcblk0p2 rootwait panic=10 ${extra}
ext2load mmc 0 0x43000000 script.bin
ext2load mmc 0 0x48000000 uImage
bootm 0x48000000
```

### NAND

Example u-boot environment, as found in uEnv.txt from a stock android u-boot environment partition

```
bootdelay=0
bootcmd=run setargs boot_normal
console=ttyS0,115200
nand_root=/dev/nandc
mmc_root=/dev/mmcblk0p4
init=/init
loglevel=8
setargs=setenv bootargs console=${console} root=${nand_root} init=${init} loglevel=${loglevel}
boot_normal=nand read 40007800 boot;boota 40007800
boot_recovery=nand read 40007800 recovery;boota 40007800
boot_fastboot=fastboot
```

### NFS

Recent version of u-boot are able to boot from NFS as well as TFTP, but you have to get rid of the automatic setup of FTP. Check Ethernet for more information.

Note: on the A20 based cubieboards, this only seems to work on the stable kernel, not on stage.

FB console

To get u-boot output shown on the built-in framebuffer driver (currently, HDMI only at 1024x768), add the following to your boot.cmd:

```
setenv stdout=serial,vga
setenv stderr=serial,vga
```

The default environment has these values set as well.
Adding a new device to U-Boot

The boards.cfg file in the top level of your u-boot tree holds all board configurations.

Scroll down until you find the sunxi devices and create an entry for your device, in alphabetical order under device_name. The device_name field should follow the Manufacturer_Device format used for naming your device wiki page. The device_name field will be the target name used when building U-Boot. Note that this is case sensitive.

```
Active  arm         armv7          sunxi       -               sunxi               device_name                          sunXi:DEVICE_NAME,SPL                                                                                                             -
```

If you wish to copy the above, then make sure that you make your browser wide enough so that even the - at the end is shown. It is probably easier to copy another entry from boards.cfg directly though.

The next stage is to set the build options. In the example before these are sunXi:DEVICE_NAME,SPL, which sets the system on chip, DRAM settings and builds the secondary program loader. Each option after the colon should be capitalized and separated by a comma. The sections below give more details on the best options for your device.

### System on Chip (SoC)

The first part of the build options, before the colon, identifies the sunxi generation your device's SoC belongs to. This with be either sun4i, sun5i, sun6i, sun7i or sun8i. See Allwinner SoC Family to find the generation a chip belongs to.

This option is used by the build system to identify a header file in include/configs. If you need to read the U-Boot source code for more details on build options then it is useful to know the SoC generation header files also include the include/configs/sunxi-common.h file. That file uses most of the build options given after the colon in boards.cfg and can be a useful source when investigating a build option.
### DRAM Settings

Settings should aim to provide a stable system under heavy workloads, such as manipulating graphics, while giving maximum performance.

There are three sources for DRAM settings: settings used by the device manufacturer; existing files from the sunxi U-Boot; and research of optimal settings. The recommended approach is to read the settings used by the device manufacturer and then check a similar file does not already exist in sunxi U-Boot.

### Generate a settings C file

The device manufacturer is likely to have stored stable settings in the device and sunxi tools can be used to retrieve the device information.

Execute meminfo -u from within the original OS to read the memory registers and output a dram configuration C file for use with U-Boot. The output from bootinfo reads the settings from boot1 and could also be used to create a dram C file.

Alternatively fexc will translate values from a fex file into a C file (note: using a fex file derived from a script.bin file will likely be missing important values).

### Verify the settings are unique

The C file should be placed in the board/sunxi directory of your local copy of sunxi U-Boot. Run the bash script ./scripts/sunxi_dram_duplicates_find.sh from the top level of your U-Boot directory and any files with the same settings should be shown.

There are a lot of generic dram files available and if one of those matches your settings then refer to the generic file when adding your device to the build system and delete your created file. If an existing board config for another device matches yours, then please consider turning this into a generic dram file.

If nothing matches, then git add your new file.
Update the build system

After you have a DRAM settings C file, edit board/sunxi/Makefile to add a line, in alphabetical order, for your device that links with the right dram_ object.

```
obj-$(CONFIG_DEVICE_NAME)  += dram_something.o

Make sure that the += is preceded by just tabs, and not by spaces.
```

The build option is DEVICE_NAME and can now be added to your devices's build options in boards.cfg.

### Stress test

And as the final step, be sure to verify the reliability of the resulting dram settings using the lima-memtester tool once you have built and run the new U-Boot. It has been discovered on more than one occasion that the dram settings from the vendors are not always perfectly reliable. So, let's say, in 90% of cases you are going to be fine by trusting the device manufacturers. But if you are out of luck, then you may get a system with mysterious application crashes or some very rare occasional deadlocks, preventing the system from having long uptime. These problems are very difficult to track, unless using dedicated stress testing tools. In other words, if you want to just save time by skipping a few minutes of downloading/compiling lima-memtester and a few hours of running it unattended, then you are essentially playing a russian roulette.
A note on optimization research

You may have found reference to DRAM optimization on the Wiki, but this research should be done at a later stage as it can lead to unstable settings for different instances of the device. The DRAM Controller page provides links to start researching this topic. Note that the 'zq' settings in 'dram_para' are not properly supported in the legacy u-boot-sunxi, so these dram performance optimization experiments only make sense with the Mainline U-boot.
Power Management Unit (PMU)

There are three main PMUs used with Allwinner SoCs: AXP152, AXP209 and AXP221

The default build option is for the AXP209. So if your device uses this PMU no build option should be given in boards.cfg

For AXP152 the build option is AXP152_POWER and for AXP221 it is AXP221_POWER.

If there is no PMU then the build option is NO_AXP.
Extra options

### UART

Before building, you should check the U-Boot section in our UART howto and verify that you are using the standard UART IO pins. Failure to catch this will not give you any UART output, but might also prevent your device from booting (or worse).

### Ethernet

TODO: Someone who has done this or is doing this, should describe how to add this.

### LEDs

U-Boot can be built to light up an LED when it runs. This will indicate that the boot process has passed beyond the secondary program loader (SPL) stage and started to run U-Boot.

This build option is STATUSLED=n.

n is the LED's GPIO pin identifier converted to an integer. For example PH25 would be 249. In schematics for Allwinner SoC based devices the pin identifier is written Pxn. Where x is the port identifier (A through to S) and n is the pin number. So in the example, H is the port identifier and 24 is the pin number. Each port can have up to 32 pins. So in the example, the numeric base value for port H is 224, because H is the 8th letter of the alphabet. That is (8-1)*32 = 224. Note that the base value for port A is 0. The numeric value for PH25 then is 224 plus pin number 25 = 249.

### Build and run the new u-boot

That's it. You should now be able to compile and test u-boot. It makes sense to also get a kernel and operating system running to more completely test the u-boot dram settings before committing code.
Commit your work to the git tree and send in the patch

You can now commit your changes, and with:

```
git format-patch -M -C HEAD^
```

You will create a git mbox patch file which you can mail to our mailinglist. If you have set up git correctly, you can just run:

```
git send-email 0001-*.patch
```
