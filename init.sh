#!/bin/sh
# Copyright (c) 2016 Dyne.org Foundation
# arm-sdk is written and maintained by Ivan J. <parazyd@dyne.org>
#
# This file is part of arm-sdk
#
# This source code is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This software is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this source code. If not, see <http://www.gnu.org/licenses/>.

## This script will setup arm-sdk and make it ready for usage.

git submodule update --init
cd lib/libdevuansdk && git checkout next && cd -

armhfsha="b8e641a3837a3aeb8a9116b0a5853b1bbc26f14b2f75f6c5005fcd7e23669fd3"

mkdir -p gcc
cd gcc

## armhf toolchain
wget https://pub.parazyd.cf/mirror/armv7-devuan-linux-gnueabihf.txz
wget https://pub.parazyd.cf/mirror/armv7-devuan-linux-gnueabihf.txz.sha

sha256sum -c  armv7-devuan-linux-gnueabihf.txz.sha \
	&& tar xf armv7-devuan-linux-gnueabihf.txz \
	|| echo "WARNING: sha256sum not correct!"

cd -
