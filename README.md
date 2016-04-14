# ARM SDK

##  OS development toolkit for various ARM embedded devices

### Introduction

This set of scripts aid package maintainers to import sources from
Debian, verify signatures and stage them to be imported inside
Devuan's git repository.

The Devuan SDK is a fresh take to old tasks :^) acting as a sort of
interactive shell extension. All the instructions below should be
followed while already running in ZSh. A clear advantage is having tab
completion on commands, when running it interactively.

BEWARE this is still in development and does not addresses strictly
security issues nor wrong usage. USE AT YOUR OWN RISK and in any case
DON'T USE ON YOUR PERSONAL MACHINE.
If you try this fast and loose use a disposable system ;^)

## Requirements

This SDK is designed to be used interactively from a terminal as well
from shell scripts.

Using a Debian-based OS, install the following packages:

```
gnupg2 schroot debootstrap debhelper makedev curl rsync dpkg-dev gcc-arm-none-eabi parted kpartx qemu-user-static pinthread sudo git-core parted gcc-multilib lib32z1 u-boot-tools device-tree-compiler
```

Please note that:
 - `dpkg-dev` may be called `dpkg` or `dpkg-devtools` on other systems like Arch and Parabola.
 - `pinthread` is Devuan software and may not exist in other distros
 - `sudo` is used to elevate the sdk user to superuser privileges and should be configured accordingly

## Quick start

First clone the SDK repository:

```
git clone https://git.devuan.org/devuan/devuan-sdk.git
```

Then run ZSh. In case you have conflicting extensions on your zsh
configuration, it may be needed to run from a vanilla one, using:

```
zsh --no-rcs
```

then step inside the sdk, "source" it:

```
cd devuan-sdk

source sdk
```

Now is the time you choose the device you want to build the image for. Currently
you can choose one of the following:
* `raspi2`
* `bananapi`
* `cubieboard2`

Once initialized, you will get further instructions.

For more info, please consult the `README` included in the `arm` subdirectory.

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
