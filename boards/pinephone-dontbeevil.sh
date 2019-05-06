#!/usr/bin/env zsh
# Copyright (c) 2019 Dyne.org Foundation
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

## generic kernel build script for sunxi allwinner boards
##  http://linux-sunxi.org

## settings & config
vars+=(device_name arch size parted_type parted_boot parted_root bootfs inittab)
vars+=(gitkernel gitbranch)
arrs+=(custmodules)

device_name="pinephone-dontbeevil"
arch="arm64"
size=1891
inittab=("T1:12345:respawn:/sbin/agetty -L ttyS0 115200 vt100")

parted_type="dos"
parted_boot="ext2 2048s 264191s"
parted_root="ext4 264192s 100%"
bootfs="ext2"

extra_packages+=()
custmodules=()

gitkernel="https://gitlab.com/pine64-org/linux.git"
gitbranch="pinephone-dontbeevil-5.1-rc7"

atfgit="https://github.com/ARM-software/arm-trusted-firmware.git"
ubootgit="https://gitlab.com/pine64-org/u-boot.git"

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

	notice "building arm-trusted-firmware"
	git clone --depth 1 "$atfgit" "$R/tmp/kernels/arm-trusted-firmware" || zerr
	pushd "$R/tmp/kernels/arm-trusted-firmware"
		make CROSS_COMPILE=$compiler PLAT=sun50i_a64 DEBUG=1 bl31 || zerr
	popd

	notice "building u-boot"
	git clone --depth 1 "$ubootgit" "$R/tmp/kernels/u-boot-pinephone" || zerr
	pushd "$R/tmp/kernels/u-boot-pinephone"
		make $MAKEOPTS sopine_baseboard_defconfig
		cp "$R/tmp/kernels/arm-trusted-firmware/build/sun50i_a64/debug/bl31.bin" .
		make $MAKEOPTS ARCH=arm CROSS_COMPILE=$compiler || zerr
		mkdir -p "$R/dist"
		cat spl/sunxi-spl.bin u-boot.itb > "$R/dist"
	popd

	cat <<EOF | sudo tee "${strapdir}/boot/boot.txt"
setenv bootargs console=tty0 console=${console} root=/dev/mmcblk0p2 rw rootwait rootfstype=ext4 fbcon=rotate:1
setenv kernel_addr_z 0x44080000

if load ${devtype} ${devnum}:${distro_bootpart} ${kernel_addr_z} Image.gz; then
  unzip ${kernel_addr_z} ${kernel_addr_r}
  if load ${devtype} ${devnum}:${distro_bootpart} ${fdt_addr_r} sun50i-a64-dontbeevil.dtb; then
    booti ${kernel_addr_r} - ${fdt_addr_r};
  fi;
fi
EOF
	pushd "${strapdir}/boot"
		sudo mkimage -C none -A arm -T script -d boot.txt boot.scr
	popd

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
			ARCH=arm64 \
			CROSS_COMPILE=$compiler \
			Image modules sun50i-a64-dontbeevil.dtb || zerr

		# install kernel modules
		sudo -E PATH="$PATH" \
			make \
				$MAKEOPTS \
				ARCH=arm \
				CROSS_COMPILE=$compiler \
				INSTALL_MOD_PATH=$strapdir \
					modules_install || zerr

		sudo cp -v arch/arm64/boot/Image $strapdir/boot/ || zerr
		pushd "$strapdir/boot"
		sudo gzip Image
		popd
		sudo mkdir -p $strapdir/boot/dtbs
		sudo cp -v arch/arm64/boot/dts/allwinner/sun50i-a64-dontbeevil.dtb \
			$strapdir/boot/dtbs/ || zerr
	popd

	postbuild || zerr
}
