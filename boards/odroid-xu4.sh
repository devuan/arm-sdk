#!/usr/bin/env zsh
# Copyright (c) 2016-2020 Dyne.org Foundation
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
size=1891
inittab=("T1:12345:respawn:/sbin/agetty -L ttySAC2 115200 vt100")

parted_type="dos"
bootfs="vfat"
rootfs="ext4"
dos_boot="$bootfs 2048s 264191s"
dos_root="$rootfs 264192s 100%"

extra_packages+=()
custmodules=()

gitkernel="https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git"
gitbranch="linux-4.14.y"


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
	req=(loopdevice)
	ckreq || return 1

	notice "executing $device_name postbuild"

	notice "building u-boot"
	pushd $R/extra/u-boot
		make distclean
		make \
			$MAKEOPTS \
			ARCH=arm \
			CROSS_COMPILE=$compiler \
				odroid-xu3_config

		make \
			$MAKEOPTS \
			ARCH=arm \
			CROSS_COMPILE=$compiler || {
				zerr
				return 1
			}
		mkdir -p "$R/tmp/xu4-uboot"
		cp -v u-boot-dtb.bin "$R/tmp/xu4-uboot"
	popd
	pushd $R/extra/u-boot-hardkernel/sd_fuse
		git checkout odroidxu4-v2017.05
		cp -v * "$R/tmp/xu4-uboot"
	popd
	pushd $R/tmp/xu4-uboot
		chmod +x sd_fusing.sh
		sudo ./sd_fusing.sh $loopdevice
	popd
	rm -rf $R/tmp/xu4-uboot

	notice "creating boot.cmd"
	cat <<EOF | sudo tee ${strapdir}/boot/boot.cmd
setenv bootargs console=tty0 console=ttySAC2,115200n8 verbose earlyprintk debug root=/dev/mmcblk1p2 init=/sbin/init ro \${extra}
load mmc 0 0x43000000 \${fdtfile}
load mmc 0 0x41000000 zImage
#load mmc 0 0x50000000 uInitrd
#setenv initrd_high 0xffffffff
#bootz 0x41000000 0x50000000 0x43000000
bootz 0x41000000 - 0x43000000
EOF
	notice "creating u-boot script image"
	sudo mkimage -A arm -T script -C none \
		-d $strapdir/boot/boot.cmd $strapdir/boot/boot.scr || zerr

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
		copy-kernel-config

		# compile kernel and modules
		make \
			$MAKEOPTS \
			ARCH=arm \
			CROSS_COMPILE=$compiler \
				zImage dtbs modules || zerr

		# install kernel modules
		sudo -E PATH="$PATH" \
			make \
				$MAKEOPTS \
				ARCH=arm \
				CROSS_COMPILE=$compiler \
				INSTALL_MOD_PATH=$strapdir \
					modules_install || zerr

		sudo cp -v arch/arm/boot/zImage $strapdir/boot/ || zerr
		sudo cp -v arch/arm/boot/dts/exynos5422-odroidxu4.dtb $strapdir/boot/ || zerr
	popd

	postbuild || zerr
}
