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

## kernel build script for Raspberry Pi 3 boards

## settings & config
vars+=(device_name arch size parted_type parted_boot parted_root bootfs inittab)
vars+=(gitkernel gitbranch rpifirmware)
arrs+=(custmodules)

device_name="raspi3"
arch="arm64"
size=1891
inittab=("T0:23:respawn:/sbin/agetty -L ttyAMA0 115200 vt100")

parted_type="dos"
parted_boot="fat32 2048s 264191s"
parted_root="ext4 264192s 100%"
bootfs="vfat"

extra_packages+=()
custmodules=(snd_bcm2835)

gitkernel="https://github.com/raspberrypi/linux"
gitbranch="rpi-4.14.y"
rpifirmware="https://github.com/raspberrypi/firmware.git"


prebuild() {
	fn prebuild
	req=(device_name strapdir)
	ckreq || return 1

	notice "executing $device_name prebuild"

	mkdir -p $R/tmp/kernels/$device_name
}

postbuild() {
	fn postbuild

	notice "executing $device_name postbuild"

	copy-root-overlay

	notice "downloading broadcom firmware for bt/wifi"
	sudo mkdir -p $strapdir/lib/firmware/brcm
	# https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/tree/brcm
	sudo wget -q -O "$strapdir/lib/firmware/brcm/brcmfmac43430-sdio.bin" \
		https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/plain/brcm/brcmfmac43430-sdio.bin

	postbuild-clean
}

build_kernel_arm64() {
	fn build_kernel_armhf
	req=(R arch device_name gitkernel gitbranch rpifirmware)
	req+=(strapdir)
	ckreq || return 1

	notice "building $arch kernel"

	prebuild || zerr

	get-kernel-sources || zerr
	pushd $R/tmp/kernels/$device_name/${device_name}-linux
		# pi3 defconfig
		make \
			$MAKEOPTS \
			ARCH=arm64 \
			CROSS_COMPILE=$compiler \
				bcmrpi3_defconfig || zerr

		# compile kernel and modules
		make \
			$MAKEOPTS \
			ARCH=arm64 \
			CROSS_COMPILE=$compiler || zerr

		# install kernel modules
		sudo -E PATH="$PATH" \
			make \
				$MAKEOPTS \
				ARCH=arm64 \
				CROSS_COMPILE=$compiler \
				INSTALL_MOD_PATH=$strapdir \
					modules_install || zerr
	popd

	clone-git "$rpifirmware" "$R/tmp/kernels/$device_name/${device_name}-firmware"
	sudo cp -rf  $R/tmp/kernels/$device_name/${device_name}-firmware/boot/* $strapdir/boot/

	pushd $R/tmp/kernels/$device_name/${device_name}-linux
	#	sudo perl scripts/mkknlimg --dtok arch/arm64/boot/Image.gz $strapdir/boot/kernel8.img
		sudo cp arch/arm64/boot/Image                 $strapdir/boot/kernel8.img
		sudo cp arch/arm64/boot/dts/broadcom/bcm*.dtb $strapdir/boot/
		sudo cp arch/arm64/boot/dts/overlays/*.dtbo   $strapdir/boot/overlays/
		sudo cp arch/arm64/boot/dts/overlays/README   $strapdir/boot/overlays/
	popd

	postbuild || zerr
}
