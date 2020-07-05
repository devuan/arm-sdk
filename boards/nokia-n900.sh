#!/usr/bin/env zsh
# Copyright (c) 2016-2018 Dyne.org Foundation
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
vars+=(device_name arch size parted_type parted_boot parted_root bootfs inittab)
vars+=(gitkernel gitbranch)
arrs+=(custmodules)

device_name="n900"
arch="armhf"
size=1337
inittab=("T0:23:respawn:/sbin/getty -L ttyS2 115200 vt100")

parted_type="dos"
parted_boot="ext2 8192s 270335s"
parted_root="ext4 270336s 100%"
bootfs="ext2"

extra_packages+=(firmware-ti-connectivity)
custmodules=()

gitkernel="https://github.com/maemo-leste/n9xx-linux/"
gitbranch="pvr-wip"


postbuild() {
	fn postbuild

	notice "executing $device_name postbuild"

	copy-root-overlay

	notice "building u-boot"
	pushd "$R/extra/u-boot"
		make distclean
		make \
			$MAKEOPTS \
			ARCH=arm \
			CROSS_COMPILE=$compiler \
			nokia_rx51_defconfig
		make \
			$MAKEOPTS \
			ARCH=arm \
			CROSS_COMPILE=$compiler || {
				zerr
				return 1
			}

		mv -v u-boot.img "$R/dist/n900-u-boot.img"
	popd
}

build_kernel_${arch}() {
	fn build_kernel_${arch}
	req=(R arch device_name gitkernel gitbranch MAKEOPTS)
	req+=(strapdir)
	req+=(loopdevice)
	ckreq || return 1

	notice "building $arch kernel"

	mkdir -p $R/tmp/kernels/$device_name

	get-kernel-sources
	pushd $R/tmp/kernels/$device_name/${device_name}-linux
	#copy-kernel-config
	make \
		$MAKEOPTS \
		ARCH=arm \
		CROSS_COMPILE=$compiler \
			rx51_defconfig || zerr

	# compile kernel and modules
	make \
		$MAKEOPTS \
		ARCH=arm \
		CROSS_COMPILE=$compiler \
			zImage modules omap3-n900.dtb || zerr
	cat arch/arm/boot/zImage arch/arm/boot/dts/omap3-n900.dtb > zImage || zerr

	# install kernel modules
	sudo -E PATH="$PATH" \
		make \
			$MAKEOPTS \
			ARCH=arm \
			CROSS_COMPILE=$compiler \
			INSTALL_MOD_PATH=$strapdir \
			INSTALL_MOD_STRIP=1 \
				modules_install || zerr

	mkimage -A arm -O linux -T kernel -C none -a 80008000 -e 80008000 -n zImage -d zImage uImage
	sudo cp -v zImage uImage $strapdir/boot/
	popd

	postbuild || zerr
}
