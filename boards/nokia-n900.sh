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

## kernel build script for Nokia N900

## settings & config
vars+=(device_name arch size parted_type parted_boot parted_root inittab)
vars+=(gitkernel gitbranch)
arrs+=(custmodules extra_packages)

device_name="n900"
arch="armhf"
size=1337
#inittab="T1:12345:respawn:/sbin/agetty -L ttyS0 115200 vt100"

parted_type="dos"
parted_boot="fat32 2048s 264191s"
parted_root="ext4 264192s 100%"

extra_packages=()
custmodules=()

gitkernel="https://github.com/pali/linux-n900.git"
gitbranch="v4.6-rc1-n900"

prebuild() {
	fn prebuild
	req=(device_name strapdir)
	ckreq || return 1

	notice "executing $device_name prebuild"

	write-fstab
	copy-zram-init

	mkdir -p $R/tmp/kernels/$device_name
}

postbuild() {
	fn postbuild

	notice "executing $device_name postbuild"
}

build_kernel_armhf() {
	fn build_kernel_armhf
	req=(R arch device_name gitkernel gitbranch MAKEOPTS)
	req+=(strapdir)
	req+=(loopdevice)
	ckreq || return 1

	notice "building $arch kernel"

	prebuild || zerr

	get-kernel-sources
	pushd $R/tmp/kernels/$device_name/${device_name}-linux
	#wget -O .config $linux_defconfig
	make rx51_defconfig
	make $MAKEOPTS zImage modules || zerr
	sudo -E PATH="$PATH" \
		make INSTALL_MOD_PATH=$strapdir modules_install || zerr
	popd

	sudo rm -rf $strapdir/lib/firmware
	get-kernel-firmware
	sudo cp $CPVERBOSE -ra $R/tmp/linux-firmware $strapdir/lib/firmware

	pushd $R/tmp/kernels/$device_name/${device_name}-linux
	sudo -E PATH="$PATH" \
		make INSTALL_MOD_PATH=$strapdir firmware_install
	#make mrproper
	make rx51_defconfig
	sudo -E PATH="$PATH" \
		make modules_prepare || zerr
	popd

	postbuild || zerr
}
