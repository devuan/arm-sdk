Notes and quirks for specific devices
=====================================

## Olimex A20-OLinuXino-MICRO Rev. J
* This one has an issue with ethernet. To make it work properly, you can issue
  the following as root:

```
ifconfig eth0 down
echo 17 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio17/direction
echo 0 > /sys/class/gpio/gpio17/value
ifconfig eth0 up
```

## Lamobo R1 (BananaPi Router)
* https://github.com/igorpecovnik/lib/issues/511#issuecomment-262571252
* https://github.com/hknaack/lib/commit/485f48957df5de317a04943ffaeeb259b78604e7

## Raspberry Pi 2
* This build script will create an image that works on the Raspberry Pi 3 as
  well. It also includes the required firmware for getting onboard Wifi/Bluetooth
  working.
* To get a serial console: https://git.devuan.org/sdk/arm-sdk/issues/4

## Acer Chromebook
* The Chromebook I tested this image on names the wireless interface `mlan0`, so
  please keep note of it when you try connecting to an access point.

## BeagleBone Black
* In `/root/` you will find the `xorg.conf` needed to run X properly. You will
  also find a shell script that allows you to use USB as an ethernet device

## OUYA Gaming console
* This image is intended to be booted from a USB stick and the kernel to be run
  from memory. dd the image on a USB flash drive.
* You will need android tools
* Run the bootloader

```
adb reboot-bootloader
```

* Load the kernel that's in `arm/extra/ouya` with:

```
fastboot boot zImage-3.1.10-tk*
```
## Nokia N900
* To boot, dd the image to a microSD card, and in the uboot console, type: `run sdboot`
* [https://parazyd.org/pub/N900/merlijnsdocs.txt](https://parazyd.org/pub/N900/merlijnsdocs.txt)
* [https://talk.maemo.org/showthread.php?t=81613](https://talk.maemo.org/showthread.php?t=81613)
