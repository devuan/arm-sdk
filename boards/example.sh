#!/usr/bin/env zsh
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

## example kernel build script

## settings & config
vars+=(device_name arch size parted_boot parted_root inittab)
vars+=(gitkernel gitbranch)
arrs+=(custmodules extra_packages)

## name of your board
device_name="myboard"
## cpu architecture of the board
arch="armhf"
## size of the image file in MB
size=1337
## board-specific inittab entry
inittab="T0:23:respawn:/sbin/agetty -L ttyAMA0 115200 vt100"

## partition scheme for parted to use
parted_boot="fat32 0 64"
parted_root="ext4 64 -1"

## extra packages you want installed
extra_packages=(wpasupplicant)
## modules you want loaded at boot
custmodules=() # add the snd module here perhaps

## git repository of the kernel you want
gitkernel="https://github.com/raspberrypi/linux.git"
gitbranch="rpi-4.4.y"

## things you need to do before building the kernel
prebuild() {
	fn prebuild
	notice "executing $device_name prebuild"
	return 0
}

## things you need to do after building the kernel
postbuild() {
	fn postbuild
	notice "executing $device_name postbuild"
	return 0
}

## kernel build function
build_kernel_armhf() {
	fn build_kernel_armhf
	req=(R arch device_name gitkernel gitbranch MAKEOPTS rpifirmware)
	req+=(workdir strapdir)
	ckreq || return 1

	prebuild

	notice "building $arch kernel"

	act "grabbing kernel sources"
	mkdir -p $R/tmp/kernels/$device_name

	git clone --depth 1 \
		$gitkernel \
		-b $gitbranch \
		$R/tmp/kernels/$device_name/${device_name}-linux

	pushd $R/tmp/kernels/$device_name/${device_name}-linux
	make bcm2709_defconfig ## take care of your .config file here
	make $MAKEOPTS
	sudo make INSTALL_MOD_PATH=$strapdir modules_install
	popd
are

	sudo rm -rf $strapdir/lib/firmware
	get-kernel-firmware
	sudo cp -ra $R/tmp/linux-firmware $strapdir/lib/firmware

	postbuild
}
