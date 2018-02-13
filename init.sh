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


git submodule update --init --recursive --checkout
mkdir -p gcc
#cd lib/libdevuansdk && git checkout next && cd -

## =================
## linaro toolchains
## =================

gettc() {
	cd gcc
	[ -d "linaro-$2" ] && return 0
	echo "Downloading $1" && \
	wget -q -O "$(basename $1)" "$1" && \
	echo "Extracting $(basename $1)" && \
	tar xfp "$(basename $1)" && \
	mv "$(basename -s .tar.xz $1)" "linaro-${2}" || \
	return 1
	cd -
}

_hostarch="$(uname -m)"

armeltc=arm-linux-gnueabi
armhftc=arm-linux-gnueabihf
arm64tc=aarch64-linux-gnu

linarover="7.1.1-2017.08"
linarourl="https://releases.linaro.org/components/toolchain/binaries/7.1-2017.08"

tc="${linarourl}/${armeltc}/gcc-linaro-${linarover}-${_hostarch}_${armeltc}.tar.xz"
gettc "$tc" "armel" || {
	echo "Something went wrong while downloading the armel toolchain."
	exit 1
}

tc="${linarourl}/${armhftc}/gcc-linaro-${linarover}-${_hostarch}_${armhftc}.tar.xz"
gettc "$tc" "armhf" || {
	echo "Something went wrong while downloading the armhf toolchain."
	exit 1
}

tc="${linarourl}/${arm64tc}/gcc-linaro-${linarover}-${_hostarch}_${arm64tc}.tar.xz"
gettc "$tc" "arm64" || {
	echo "Something went wrong while downloading the arm64 toolchain."
	exit 1
}

damnunicorncompanyver="4.9.4-2017.01"
damnunicorncompanyurl="https://releases.linaro.org/components/toolchain/binaries/4.9-2017.01"

tc="${damnunicorncompanyurl}/${armhftc}/gcc-linaro-${damnunicorncompanyver}-${_hostarch}_${armhftc}.tar.xz"
gettc "$tc" "armhf-unicorns" || {
	echo "Something went wrong while downloading the toolchain for the damn
	unicorn company kernels."
	exit 1
}

cat <<EOM

All done! Make sure you also install the required dependencies listed in
README.md. You can use the following oneliner as well:

$ grep '^curl ' README.md | xargs sudo apt --yes --force-yes install
EOM
