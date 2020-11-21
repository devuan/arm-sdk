#!/usr/bin/env zsh
# Copyright (c) 2020 Dyne.org Foundation
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


## settings & config
vars+=(device_name arch size parted_type parted_boot parted_root bootfs inittab)
vars+=(gitkernel gitbranch atfgit crustgit crustbranch ubootgit ubootbranch)
arrs+=(custmodules)

device_name="pinephone"
arch="arm64"
size=1891
inittab=("T1:12345:respawn:/sbin/agetty -L ttyS0 115200 vt100")

parted_type="dos"
bootfs="ext2"
rootfs="ext4"
dos_boot="$bootfs 2048s 264191s"
dos_root="$rootfs 264192s 100%"

extra_packages+=()
custmodules=()

gitkernel="https://github.com/maemo-leste/pine64-kernel"
gitbranch="pine64-kernel-5.4.0"

atfgit="https://github.com/ARM-software/arm-trusted-firmware.git"

crustgit="https://github.com/crust-firmware/crust.git"
crustbranch="master"

ubootgit="https://gitlab.com/pine64-org/u-boot"
ubootbranch="master"

prebuild() {
	fn prebuild
	req=(device_name)
	ckreq || return 1

	notice "executing $device_name prebuild"

	mkdir -p $R/tmp/kernels/$device_name
}

postbuild() {
	fn postbuild
	req=(device_name compiler loopdevice or1ktc)
	ckreq || return 1

	notice "executing $device_name postbuild"

	copy-root-overlay

	notice "building arm-trusted-firmware"
	git clone --depth 1 "$atfgit" "$R/tmp/kernels/arm-trusted-firmware" || zerr
	pushd "$R/tmp/kernels/arm-trusted-firmware"
		make $MAKEOPTS CROSS_COMPILE=$compiler PLAT=sun50i_a64 DEBUG=1 bl31 || zerr
	popd

	notice "building crust"
	git clone --depth 1 "$crustgit" -b "$crustbranch" "$R/tmp/kernels/crust" || zerr
	pushd "$R/tmp/kernels/crust"
		make $MAKEOPTS CROSS_COMPILE="$or1ktc" pinephone_defconfig || zerr
		make $MAKEOPTS CROSS_COMPILE="$or1ktc" scp || zerr
	popd

	notice "building u-boot"
	git clone --depth 1 "$ubootgit" -b "$ubootbranch" "$R/tmp/kernels/u-boot-pinephone" || zerr
	pushd "$R/tmp/kernels/u-boot-pinephone"
		make $MAKEOPTS \
			BL31="$R/tmp/kernels/arm-trusted-firmware/build/sun50i_a64/debug/bl31.bin" \
			SCP="$R/tmp/kernels/crust/build/scp/scp.bin" \
			pinephone_defconfig || zerr
		make $MAKEOPTS \
			BL31="$R/tmp/kernels/arm-trusted-firmware/build/sun50i_a64/debug/bl31.bin" \
			SCP="$R/tmp/kernels/crust/build/scp/scp.bin" \
			ARCH=arm CROSS_COMPILE=$compiler || zerr
		mkdir -p "$R/dist"
		cp u-boot-sunxi-with-spl.bin "$R/dist/u-boot-sunxi-with-spl-pinephone.bin"
	popd

	cat <<EOF | sudo tee "${strapdir}/boot/boot.txt"
setenv bootargs console=tty0 console=\${console} root=/dev/mmcblk0p2 rw rootwait rootfstype=ext4 fbcon=rotate:1
setenv kernel_addr_z 0x44080000

if load \${devtype} \${devnum}:\${distro_bootpart} \${kernel_addr_z} Image.gz; then
  unzip \${kernel_addr_z} \${kernel_addr_r}
  if load \${devtype} \${devnum}:\${distro_bootpart} \${fdt_addr_r} \${fdtfile}; then
    booti \${kernel_addr_r} - \${fdt_addr_r};
  fi;
fi
EOF
	pushd "${strapdir}/boot"
		sudo mkimage -C none -A arm -T script -d boot.txt boot.scr
	popd

	sudo dd if="$R/dist/u-boot-sunxi-with-spl-pinephone.bin" of="${loopdevice}" seek=8 \
		bs=1024 conv=notrunc,nocreat

	postbuild-clean
}

build_kernel_arm64() {
	fn build_kernel_arm64
	req=(R arch device_name gitkernel gitbranch MAKEOPTS)
	req+=(strapdir)
	ckreq || return 1

	notice "building $arch kernel"

	prebuild || zerr

	get-kernel-sources
	pushd $R/tmp/kernels/$device_name/${device_name}-linux
		wget -O- https://github.com/maemo-leste/pine64-kernel/raw/maemo/ascii-devel/debian/patches/0001-Include-rtl8723cs-staging-driver.patch | patch -p1

		copy-kernel-config

		# compile kernel and modules
		make \
			$MAKEOPTS \
			ARCH=arm64 \
			CROSS_COMPILE=$compiler \
			Image.gz modules allwinner/sun50i-a64-pinephone.dtb || zerr

		# install kernel modules
		sudo -E PATH="$PATH" \
			make \
				$MAKEOPTS \
				ARCH=arm \
				CROSS_COMPILE=$compiler \
				INSTALL_MOD_PATH=$strapdir \
					modules_install || zerr

		sudo cp -v arch/arm64/boot/Image $strapdir/boot/ || zerr
		sudo cp -v arch/arm64/boot/dts/allwinner/sun50i-a64-pinephone.dtb \
			"$strapdir/boot/" || zerr
	popd

	postbuild || zerr
}
