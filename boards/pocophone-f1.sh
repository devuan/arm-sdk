#!/usr/bin/env zsh
# Copyright (c) 2016-2021 Ivan J. <parazyd@dyne.org>
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

vars+=(device_name arch size parted_type parted_boot parted_root bootfs inittab)
vars+=(gitkernel gitbranch)
arrs+=(custmodules)

device_name="pocophone-f1"
arch="arm64"
size=1891
inittab=("T0:23:respawn:/sbin/agetty -L ttyMSM0 115200n8 vt100")

parted_type="dos"
bootfs="vfat"
rootfs="ext4"
dos_boot="fat32 2048s 264191s"
dos_root="$rootfs 264192s 100%"

extra_packages+=()
custmodules=()

gitkernel="https://gitlab.com/venji10/linux-beryllium"
gitbranch="beryllium-panel-ebbg"

prebuild() {
	fn prebuild
	req=(device_name strapdir)
	ckreq || return 1

	notice "Executing $device_name prebuild"

	mkdir -p "$R/tmp/kernels/$device_name"
}

postbuild() {
	fn postbuild

	notice "Executing $device_name postbuild"

	copy-root-overlay
	
	pushd "$R/tmp/kernels/$device_name/${device_name}-linux"
	
	cat arch/arm64/boot/Image.gz \
		arch/arm64/boot/dts/qcom/sdm845-xiaomi-beryllium-ebbg.dtb \
		> Image.gz-dtb || { zerr; return 1; }

	mkdir -p "$R/dist"
	mkbootimg \
        --kernel Image.gz-dtb \
        --base 0x00000000 \
        --second_offset 0x00f00000 \
        --kernel_offset 0x00008000 \
        --ramdisk_offset 0x01000000 \
        --tags_offset 0x00000100 \
        --pagesize 4096 \
        --cmdline "root=/dev/mmcblk0p2 rootfstype=$rootfs rootwait rw audit=0" \
        -o $R/dist/pocophone-f1-boot.img || { zerr; return 1; }
	
	popd
}

build_kernel_arm64() {
	fn build_kernel_arm64
	req=(R arch device_name gitkernel gitbranch strapdir)
	ckreq || return 1

	notice "Building $arch kernel"

	prebuild || { zerr; return 1; }

	get-kernel-sources || { zerr; return 1; }

	pushd "$R/tmp/kernels/$device_name/${device_name}-linux"
		make \
			$MAKEOPTS \
			ARCH=arm64 \
			CROSS_COMPILE=$compiler \
			beryllium_defconfig || { zerr; return 1; }

		make \
			$MAKEOPTS \
			ARCH=arm64 \
			CROSS_COMPILE=$compiler \
			Image.gz modules qcom/sdm845-xiaomi-beryllium-ebbg.dtb || { zerr; return 1; }

		sudo -E PATH="$PATH" make \
			$MAKEOPTS \
			ARCH=arm64 \
			CROSS_COMPILE=$compiler \
			INSTALL_MOD_PATH="$strapdir" \
			modules_install || { zerr; return 1; }

	popd

	postbuild || { zerr; return 1; }
}
