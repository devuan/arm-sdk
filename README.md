arm-sdk
=======

# This branch is very unstable! Use at your own risk, I won't fix your shit!

arm-sdk is simple distro build system aimed at embedded ARM devices. It was
first conceived as a component of the Devuan SDK, but now it aims to
support multiple Linux distributions.

## Requirements

arm-sdk is designed to be used interactively from a terminal, as well as
from shell scripts. It requires the following packages to be installed:

```
zsh sudo xz-utils qemu-user-static git-core curl wget perl
```

It also uses the [Zuper](https://github.com/dyne/zuper) zsh library, which
needs the following:

```
zsh curl sed awk hexdump
```

### Specific distro requirements

For Devuan, which is using `libdevuansdk`, additional packages are needed:

```
debootstrap cgpt xz-utils kpartx
```

## Initial setup

By executing `init.sh` which is found in the base directory of arm-sdk, it
will initialize all git submodules and gcc toolchains that are needed for
arm-sdk to properly function.

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

* `raspi` - Raspberry Pi 2 and 3
* `bananapi` - Banana Pi
* `bananapro` - Banana Pi Pro
* `cubieboard2` - Cubieboard 2
* `cubietruck` - Cubietruck
* `chromeacer` - Acer ARM Chromebook
* `chromeveyron` - Veyron ARM Chromebook (RK3288)
* `odroidxu` - ODROID-XU
* `bbb` - BeagleBone Black
* `ouya` - OUYA gaming console

```
; init devuan cubietruck
```

Once initialized, you can run the helper command:

```
; build_image_dist
```

and the image will automatically be build for you. Once finished, you will be
able to find it in the `dist/` directory in arm-sdk's root.

For more info, see the `doc/` directory.

## Acknowledgments

Devuan's SDK was originally conceived during a period of residency at the
Schumacher college in Dartington, UK. Greatly inspired by the laborious and
mindful atmosphere of its wonderful premises.

The Devuan SDK is Copyright (c) 2015-2016 by the Dyne.org Foundation

Devuan SDK components are designed, written and maintained by:

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
