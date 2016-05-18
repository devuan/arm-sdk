# ARM SDK

##  OS development toolkit for various ARM embedded devices

### Introduction

ARM SDK is a build system used to toast OS images for ARM devices.
Currently only Devuan is supported, but later on support for other distros
will be added.

## Requirements

This SDK is designed to be used interactively from a terminal as well
from shell scripts.

For a Debian-based OS, install the following packages:

```
build-essential gnupg2 debootstrap curl rsync gcc-arm-none-eabi parted kpartx qemu-user-static sudo git-core parted gcc-multilib lib32z1 u-boot-tools device-tree-compiler cgpt xz-utils lzop
```

On any other, find the equivalents of the aforementioned packages.

## Quick start

```
; git clone https://github.com/dyne/arm-sdk.git
# OR
; git clone https://git.devuan.org/devuan/arm-sdk.git
```
If you have cloned the repository before, please do a `git pull` in order
to update to the latest versions. Your experience will be better.

Edit the `config` file to match your crosscompile toolchain. Consult
`arm/README.md` if you're in a need of a precompiled one, then
run zsh. In case you have conflicting extensions on your zsh
configuration, safest way would be to run a vanilla one, using:

```
; zsh -f
```

then step inside the sdk, "source" it:

```
; cd arm-sdk && source sdk
```

Now is the time you choose the device and OS you want to build the image for. Currently
you can choose between these distros:

* `devuan`

and one of the following devices:

* `raspi2` - Raspberry Pi 2 and 3
* `bananapi` - Banana Pi
* `bananapro` - Banana Pi Pro
* `cubieboard2` - Cubieboard 2
* `cubietruck` - Cubietruck
* `chromeacer` - Acer ARM Chromebook
* `chromeveyron` - Veyron ARM Chromebook (RK3288)
* `odroidxu` - ODROID-XU
* `bbb`- BeagleBone Black
* `ouya` - OUYA gaming console

```
; init devuan raspi2
```

Once initialized, you will get further instructions.

For more info, please consult the `README` included in the `arm` subdirectory.

After the image is built, you will find it compressed, along with its sha256 sum
in the `arm/finished/` directory. The default root password is `devuan` and SSH
with permitted root login is enabled on startup, along with DHCP to get you up
and running headless if you require it.

## Configuration

Edit the `config` file included in the root directory of arm-sdk to your liking.
If you are using a custom toolchain, add it to the PATH as described.

## Notes and quirks for specific devices

### ODROID-XU
* The kernel refuses to build with Devuan's default toolchain `arm-none-eabi`.
  Use `arm-linux-gnueabi-4.7` that I provide on https://pub.parazyd.cf/mirror
  instead.

### Raspberry Pi 2
* This build script will create an image that works on the Raspberry Pi 3 as
  well. It also includes the required firmware for getting onboard Wifi/Bluetooth
  working.

### Acer Chromebook
* The Chromebook I tested this image on names the wireless interface `mlan0`, so
  please keep note of it when you try connecting to an access point.

### BeagleBone Black
* The kernel refuses to build with Devuan's default toolchain `arm-none-eabi`.
  Use `arm-linux-gnueabi-4.7` that I provide on https://pub.parazyd.cf/mirror
  instead.
* In `/root/` you will find the `xorg.conf` needed to run X properly. You will
  also find a shell script that allows you to use USB as an ethernet device

### OUYA Gaming console
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

## Acknowledgments

The Devuan SDK was conceived during a period of residency at the
Schumacher college in Dartington UK, greatly inspired by the laborious
and mindful atmosphere of its wonderful premises.

ARM SDK is Copyright (c) 2016 by the Dyne.org Foundation

ARM SDK is designed, written and maintained by parazyd <parazyd@dyne.org>

The ARM SDK also uses code from Devuan SDK and Kali Linux ARM buildscripts.

This source code is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this source code. If not, see <http://www.gnu.org/licenses/>.
