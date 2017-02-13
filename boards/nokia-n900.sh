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
arrs+=(custmodules)

device_name="n900"
arch="armhf"
size=666
#inittab=""

parted_type="dos"
parted_boot="fat32 2048s 264191s"
parted_root="ext4 264192s 100%"

extra_packages+=()
custmodules=()

gitkernel="git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git"
gitbranch="linux-4.8.y"


prebuild() {
	fn prebuild
	req=(device_name strapdir)
	ckreq || return 1

	notice "executing $device_name prebuild"

	enablessh
	write-fstab
	copy-zram-init
	install-custom-packages

	mkdir -p $R/tmp/kernels/$device_name

	## the wl1251 driver generates a random MAC address on every boot
	## this "fixes" udev so it does not autoincrement the interface number each
	## time the device boots
	## NOTE: comment the below line for having a random wifi MAC address every time :)
	print "#" | sudo tee $strapdir/etc/udev/rules.d/75-persistent-net-generator.rules >/dev/null
}

postbuild() {
	fn postbuild

	notice "executing $device_name postbuild"

	sudo mkdir -p $strapdir/usr/share/keymaps/
	sudo ${=cp} $R/extra/n900/nokia-n900.kmap $strapdir/etc/
	sudo ${=cp} $R/extra/n900/nokia-n900-keymap.sh $strapdir/etc/profile.d/
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
	copy-kernel-config
	make $MAKEOPTS zImage modules omap3-n900.dtb || zerr
	cat arch/arm/boot/zImage arch/arm/boot/dts/omap3-n900.dtb > zImage || zerr
	sudo -E PATH="$PATH" \
		make INSTALL_MOD_PATH=$strapdir INSTALL_MOD_STRIP=1 modules_install || zerr

	mkimage -A arm -O linux -T kernel -C none -a 80008000 -e 80008000 -n zImage -d zImage uImage
	sudo cp $CPVERBOSE uImage $strapdir/boot/
	popd

	#sudo rm -rf $strapdir/lib/firmware
	#get-kernel-firmware
	#sudo cp $CPVERBOSE -ra $R/tmp/linux-firmware $strapdir/lib/firmware

	pushd $R/tmp/kernels/$device_name/${device_name}-linux
	sudo -E PATH="$PATH" \
		make INSTALL_MOD_PATH=$strapdir firmware_install
	sudo -E PATH="$PATH" \
		make modules_prepare || zerr
	popd

	postbuild || zerr
}
