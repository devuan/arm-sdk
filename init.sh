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
	printf "(!!) this distro is unsupported. check and install the dependencies manually\n"
fi

git submodule update --init --recursive --checkout
mkdir -p gcc
#cd lib/libdevuansdk && git checkout next && cd -

## =================
## linaro toolchains
## =================

gettc() {
	cd gcc
	wget -O "$(basename $1)" "$1" && \
	tar xfp "$(basename $1)" && \
	mv "$(basename -s .tar.xz $1)" "linaro-${2}"
	cd -
}

_hostarch="$(uname -m)"

armeltc=arm-linux-gnueabi
armhftc=arm-linux-gnueabihf
arm64tc=aarch64-linux-gnu

linarover="7.1.1-2017.08"
linarourl="https://releases.linaro.org/components/toolchain/binaries/7.1-2017.08"

tc="${linarourl}/${armeltc}/gcc-linaro-${linarover}-${_hostarch}_${armeltc}.tar.xz"
gettc "$tc" "armel"

tc="${linarourl}/${armhftc}/gcc-linaro-${linarover}-${_hostarch}_${armhftc}.tar.xz"
gettc "$tc" "armhf"

tc="${linarourl}/${arm64tc}/gcc-linaro-${linarover}-${_hostarch}_${arm64tc}.tar.xz"
gettc "$tc" "arm64"
