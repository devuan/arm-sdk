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

## kernel build script for the turbox twister a33 tablet
## https://leste.maemo.org/A33-TurboX-Twister

## settings & config
vars+=(device_name arch size parted_type parted_boot parted_root bootfs inittab)
vars+=(gitkernel gitbranch)
arrs+=(custmodules)

device_name="turbox-twister"
arch="armhf"
size=1891
inittab=("T1:12345:respawn:/sbin/agetty -L ttyS0 115200 vt100")

parted_type="dos"
bootfs="ext4"
rootfs="ext4"
dos_boot="$bootfs 2048s 264191s"
dos_root="$rootfs 264192s 100%"

extra_packages+=()
custmodules=()

gitkernel="https://github.com/maemo-leste/lime2-linux"
gitbranch="lime2-and-twister"


prebuild() {
	fn prebuild
	req=(device_name)
	ckreq || return 1

	notice "executing $device_name prebuild"

	copy-root-overlay

	mkdir -p $R/tmp/kernels/$device_name
}

postbuild() {
	fn postbuild
	req=(uboot_configs device_name compiler)
	ckreq || return 1

	notice "executing $device_name postbuild"

	notice "building u-boot"
	mkdir -p $R/dist/u-boot
	pushd $R/extra/u-boot
		local board="q8_a33_tablet_1024x600_defconfig"
		notice "building u-boot for $board"

		make distclean
		make \
			$MAKEOPTS \
			ARCH=arm \
			CROSS_COMPILE=$compiler \
				$board
		make \
			$MAKEOPTS \
			ARCH=arm \
			CROSS_COMPILE=$compiler || {
				zerr
				return 1
			}

		mv -v u-boot-sunxi-with-spl.bin $R/dist/u-boot/${board}.bin
	popd

	notice "creating boot.cmd"
	cat <<EOF | sudo tee ${strapdir}/boot/boot.cmd
setenv bootargs console=ttyS0,115200 root=/dev/mmcblk0p2 rootwait panic=10 \${extra}
load mmc 0:1 0x43000000 dtbs/\${fdtfile} || load mmc 0:1 0x43000000 boot/dtbs/\${fdtfile}
load mmc 0:1 0x42000000 zImage || load mmc 0:1 0x42000000 boot/zImage
bootz 0x42000000 - 0x43000000
EOF

	notice "creating u-boot script image"
	sudo mkimage -A arm -T script -C none \
		-d $strapdir/boot/boot.cmd $strapdir/boot/boot.scr || zerr


	#notice "building mali"
	#export CROSS_COMPILE=$compiler
	#export KDIR="$R/tmp/kernels/$device_name/${device_name}-linux"
	#clone-git "$sunxi_mali" "$R/tmp/kernels/${device_name}/sunxi-mali"
	#pushd "$R/tmp/kernels/${device_name}/sunxi-mali"
	#	git checkout -- .
	#	git clean -xdf
	#	./build.sh -r r6p2 -b || zerr
	#	sudo cp mali.ko ${strapdir}/lib/modules/*/kernel/drivers/gpu
	#popd

	postbuild-clean
}

build_kernel_armhf() {
	fn build_kernel_armhf
	req=(R arch device_name gitkernel gitbranch MAKEOPTS)
	req+=(strapdir)
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
				zImage sun8i-a33-q8-tablet.dtb modules || zerr

		# install kernel modules
		sudo -E PATH="$PATH" \
			make \
				$MAKEOPTS \
				ARCH=arm \
				CROSS_COMPILE=$compiler \
				INSTALL_MOD_PATH=$strapdir \
					modules_install || zerr

		sudo cp -v arch/arm/boot/zImage $strapdir/boot/ || zerr
		sudo mkdir -p $strapdir/boot/dtbs
		sudo cp -v arch/arm/boot/dts/sun8i-a33-q8-tablet.dtb $strapdir/boot/dtbs/ || zerr
	popd

	postbuild || zerr
}
