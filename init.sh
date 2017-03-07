#!/bin/sh
# Copyright (c) 2016-2017 Dyne.org Foundation
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

if test $(which apt-get); then
deps=$(grep '^sudo' ./README.md)

	for dep in $deps; do
		dpkg -l $dep >/dev/null || {
			printf "(!!) '%s' not installed\nplease install and retry\n" $dep
			exit 1
		}
	done
else
	printf "(!!) this distro is unsupported. check and install the dependencies manually"
fi

git submodule update --init
mkdir -p gcc
#cd lib/libdevuansdk && git checkout next && cd -

## ===============
## armhf toolchain
## ===============
armhfurldl=https://pub.parazyd.cf/mirror/armv7-devuan-linux-gnueabihf.txz
armhfshahc=b8e641a3837a3aeb8a9116b0a5853b1bbc26f14b2f75f6c5005fcd7e23669fd3
armhfshadl=$(curl -s ${armhfurldl}.sha | awk '{print $1}')

test $armhfshahc = $armhfshadl || {
	printf "(!!) armhf sha256sum doesn't match with hardcoded one\n"
	exit 1
}

cd gcc
	curl -O ${armhfurldl} && \
	curl -O ${armhfurldl}.sha && \
	sha256sum   -c $(basename $armhfurldl).sha \
		&& tar xfp $(basename $armhfurldl)
cd -

## ===============
## armel toolchain
## ===============
armelurldl=https://pub.parazyd.cf/mirror/armv6-devuan-linux-gnueabi.txz
armelshahc=9aa5095f6587fea4e79e8894557044879e98917be5fa37000cf2f474c00d451f
armelshadl=$(curl -s ${armelurldl}.sha | awk '{print $1}')

test $armelshahc = $armelshadl || {
	printf "(!!) armel sha256sum doesn't match with hardcoded one\n"
	exit 1
}

cd gcc
	curl -O ${armelurldl} && \
	curl -O ${armelurldl}.sha && \
	sha256sum   -c $(basename $armelurldl).sha \
		&& tar xfp $(basename $armelurldl)
cd -

## ===============
## arm64 toolchain
## ===============
arm64urldl=https://pub.parazyd.cf/mirror/aarch64-devuan-linux-gnueabi.txz
arm64shahc=80ffad79dd8d9bf8cbd20b3e9f5914f5172d1d5252be8ad4eef078243206fe8f
arm64shadl=$(curl -s ${arm64urldl}.sha | awk '{print $1}')

test $arm64shahc = $arm64shadl || {
	printf "(!!) arm64 sha256sum doesn't match with hardcoded one\n"
	exit 1
}

cd gcc
	curl -O ${arm64urldl} && \
	curl -O ${arm64urldl}.sha && \
	sha256sum   -c $(basename $arm64urldl).sha \
		&& tar xfp $(basename $arm64urldl)
cd -
