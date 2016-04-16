# ARM SDK

##  OS development toolkit for various ARM embedded devices

### Introduction

ARM SDK is a build system used to toast OS images for ARM devices.
Currently only Devuan is supported, but later on support for other distros
will be added.

## Requirements

This SDK is designed to be used interactively from a terminal as well
from shell scripts.

Using a Debian-based OS, install the following packages:

```
gnupg2 debootstrap curl rsync gcc-arm-none-eabi parted kpartx qemu-user-static sudo git-core parted gcc-multilib lib32z1 u-boot-tools device-tree-compiler cgpt
```
## Quick start

First clone the SDK repository:

```
; git clone https://github.com/dyne/arm-sdk.git
```

Then run ZSh. In case you have conflicting extensions on your zsh
configuration, it may be needed to run from a vanilla one, using:

```
; zsh --no-rcs
```

then step inside the sdk, "source" it:

```
; cd arm-sdk

; source sdk
```

Now is the time you choose the device and OS you want to build the image for. Currently
you can choose these distros:
* `devuan`  
and one of the following devices:
* `raspi2`
* `bananapi`
* `cubieboard2`
* `chromeacer`
```
; init devuan raspi2
```

Once initialized, you will get further instructions.

For more info, please consult the `README` included in the `arm` subdirectory.

## Configuration

Edit the `config` file included in the root directory of arm-sdk to your liking.
If you are using a custom toolchain, add it to the PATH as described.

## Acknowledgments

The Devuan SDK was conceived during a period of residency at the
Schumacher college in Dartington UK, greatly inspired by the laborious
and mindful atmosphere of its wonderful premises.

ARM SDK is Copyright (C) 2016 by the Dyne.org Foundation

ARM SDK is designed, written and maintained by parazyd <parazyd@dyne.org>

Inspiration taken from Devuan SDK and Kali Linux ARM buildscripts.

This source code is free software; you can redistribute it and/or
modify it under the terms of the GNU Public License as published by
the Free Software Foundation; either version 3 of the License, or (at
your option) any later version.

This source code is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  Please refer to
the GNU Public License for more details.

You should have received a copy of the GNU Public License along with
this source code; if not, write to: Free Software Foundation, Inc.,
675 Mass Ave, Cambridge, MA 02139, USA.
