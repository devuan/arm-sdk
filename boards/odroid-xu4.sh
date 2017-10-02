#!/usr/bin/env zsh
# Copyright (c) 2017 Dyne.org Foundation
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

## kernel build script for ODROID XU4 boards
## https://lastlog.de/blog/posts/odroid_xu4_with_nixos.html

## settings & config
vars+=(device_name arch size parted_type parted_boot parted_root bootfs inittab)
vars+=(gitkernel gitbranch hosttuple)
arrs+=(custmodules extra_packages)

device_name="odroidxu4"
arch="armhf"
size=1337
inittab=("T1:12345:respawn:/sbin/agetty -L ttyS0 115200 vt100")

parted_type="dos"
parted_boot="fat32 2048s 264191s"
parted_root="ext4 264192s 100%"
bootfs="vfat"

extra_packages+=()
custmodules=()

gitkernel="https://github.com/tobetter/linux"
gitbranch="odroidxu4-v4.8"


prebuild() {
	fn prebuild
	req=(device_name strapdir)
	ckreq || return 1

	notice "executing $device_name prebuild"

	copy-root-overlay

	mkdir -p $R/tmp/kernels/$device_name
}

postbuild() {
	fn postbuild

	notice "executing $device_name postbuild"

	notice "building u-boot"
	pushd "$R/extra/u-boot-hardkernel"
		act "patching"
		git checkout -- .
		patch -p1 < "$R/extra/patches/uboothardkernel-tftp-path-len-bigger.patch" \
			|| zerr

		make distclean
		make \
			$MAKEOPTS \
			ARCH=arm \
			CROSS_COMPILE=$compiler \
				odroid_config || zerr
		make \
			$MAKEOPTS \
			ARCH=arm \
			CROSS_COMPILE=$compiler || zerr

		notice "dd-ing blobs and u-boot to the image"
		sudo dd if=/dev/zero bs=512 count=4000 of=$loopdevice
		sudo dd if=sd_fuse/hardkernel_1mb_uboot/bl1.bin.hardkernel \
			bs=512 seek=1 of=$loopdevice
		sudo dd if=sd_fuse/hardkernel_1mb_uboot/bl2.bin.hardkernel.1mb_uboot \
			bs=512 seek=31 of=$loopdevice
		sudo dd if=u-boot-dtb.bin bs=512 seek=63 of=$loopdevice
		sudo dd if=sd_fuse/hardkernel_1mb_uboot/tzsw.bin.hardkernel \
			bs=512 seek=2111 of=$loopdevice
	popd


	postbuild-clean
}

build_kernel_armhf() {
	fn build_kernel_armhf
	req=(R arch device_name gitkernel gitbranch MAKEOPTS)
	req+=(strapdir loopdevice)
	ckreq || return 1

	notice "building $arch kernel"

	prebuild || zerr

	get-kernel-sources
	pushd $R/tmp/kernels/$device_name/${device_name}-linux
		make \
			$MAKEOPTS \
			ARCH=arm \
			CROSS_COMPILE=$compiler \
				odroidxu4_defconfig || zerr
		make \
			$MAKEOPTS \
			ARCH=arm \
			CROSS_COMPILE=$compiler || zerr
		sudo -E PATH="$PATH" \
			make \
				$MAKEOPTS \
				ARCH=arm \
				CROSS_COMPILE=$compiler \
				INSTALL_MOD_PATH=$strapdir \
					modules_install || zerr
		sudo cp -v arch/arm/boot/zImage $strapdir/boot/
	popd

	pushd $R/tmp/kernels/$device_name/${device_name}-linux
		sudo -E PATH="$PATH" \
			make \
				$MAKEOPTS \
				ARCH=arm \
				CROSS_COMPILE=$compiler \
				INSTALL_MOD_PATH=$strapdir \
					firmware_install || zerr
		make \
			$MAKEOPTS \
			ARCH=arm \
			CROSS_COMPILE=$compiler \
				mrproper
		make \
			$MAKEOPTS \
			ARCH=arm \
			CROSS_COMPILE=$compiler \
				odroidxu4_defconfig || zerr
		sudo -E PATH="$PATH" \
			make \
				$MAKEOPTS \
				ARCH=arm \
				CROSS_COMPILE=$compiler \
					modules_prepare || zerr
	popd

	postbuild || zerr
}
