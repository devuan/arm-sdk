#!/bin/sh
# Copyright (c) 2016 Dyne.org Foundation
# arm-sdk is written and maintained by parazyd <parazyd@dyne.org>
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

armelsha="28d4c9fcd738faf295bda5ae837cf1ca67b221cf6c4c0e062b66b6892fab6553"
armhfsha="f320388b574a311d71a78437f508deabd5c38f8b37ec8f1f048d08df3e4e1c44"
arm64sha="d843aa7ec71c94d72663c42c21a509d549fe88ca5847ac392e6734b18a6acdcc"

mkdir gcc
cd gcc

## armhf toolchain
wget https://pub.parazyd.cf/mirror/gcc-arm-linux-gnueabihf-4.7.txz
wget https://pub.parazyd.cf/mirror/gcc-arm-linux-gnueabihf-4.7.txz.sha

sha256sum -c  gcc-arm-linux-gnueabihf-4.7.txz.sha \
	&& tar xf gcc-arm-linux-gnueabihf-4.7.txz \
	|| echo "WARNING: sha256sum not correct!"

cd -
