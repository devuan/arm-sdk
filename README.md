arm-sdk
=======

arm-sdk is simple distro build system aimed at embedded ARM devices. It was
first conceived as a component of the Devuan SDK, but now it aims to
support multiple Linux distributions.

## Requirements

arm-sdk is designed to be used interactively from a terminal, as well as
from shell scripts. It requires the following packages to be installed, as well
as [libdevuansdk dependencies](https://github.com/dyne/libdevuansdk/blob/master/README.md#requirements):


### Devuan

```
curl git wget qemu-user-static build-essential rsync gcc-arm-none-eabi gcc-multilib lib32z1 u-boot-tools device-tree-compiler lzop dosfstools vboot-utils vboot-kernel-utils libftdi-dev libfdt-dev swig libpython-dev bc
```

### Gentoo
```
net-misc/curl net-misc/wget sys-boot/vboot-utils app-emulation/qemu(static-user) net-misc/rsync sys-libs/zlib dev-embedded/u-boot-tools sys-apps/dtc app-arch/lzop sys-fs/dosfstools
```

`sudo` permissions are required for the user that is running the build.

## Initial setup

By executing `init.sh` which is found in the base directory of arm-sdk, it
will initialize all git submodules and gcc toolchains that are needed for
arm-sdk to properly function.

Do it with:

```
; ./init.sh
```

## Quick start

Edit the `config` file to match your crosscompile toolchain. `init.sh` will
provide you with precompiled ones. Then run zsh. In case you have conflicting
extensions on your zsh configuration, safest way would be to run a vanilla one,
using:

```
; zsh -f
```

then step inside the sdk, "source" it:

```
; cd arm-sdk && source sdk
```

Now is the time you choose the device and OS you want to build the image for.

### Currently supported distros

* `devuan`

### Currently supported boards

* `beagleboneblack` - BeagleBone Black
* `chromeacer` - Acer ARM Chromebook
* `chromeveyron` - Veyron ARM Chromebook (RK3288)
* `n900` - Nokia N900
* `n950` - Nokia N950
* `n9` - Nokia N9
* `odroidxu` - ODROID-XU
* `odroidxu4` - ODROID-XU4
* `ouya` - OUYA gaming console
* `raspi1` - Raspberry Pi 1 and 0 (armel)
* `raspi2` - Raspberry Pi 2 and 3
* `raspi3` - Raspberry Pi 3 (64bit)
* `rock64` - Rock64 (64bit) (EXPERIMENTAL)
* `sunxi` - Allwinner-based boards

```
; load devuan sunxi
```

Once initialized, you can run the helper command:

```
; build_image_dist
```

The image will automatically be build for you. Once finished, you will be
able to find it in the `dist/` directory in arm-sdk's root.

For more info, see the `doc/` directory.

## Acknowledgments

Devuan's SDK was originally conceived during a period of residency at the
Schumacher college in Dartington, UK. Greatly inspired by the laborious and
mindful atmosphere of its wonderful premises.

The Devuan SDK is Copyright (c) 2015-2017 by the Dyne.org Foundation

Devuan SDK components were designed, and are written and maintained by:

- Ivan J. <parazyd@dyne.org>
- Denis Roio <jaromil@dyne.org>
- Enzo Nicosia <katolaz@freaknet.org>

This source code is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option)
any later version.

This software is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along
with this source code. If not, see <http://www.gnu.org/licenses/>.
