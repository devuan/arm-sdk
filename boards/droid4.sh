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

## kernel build script for Motorola DROID4

## settings & config
vars+=(device_name arch size parted_type parted_boot parted_root bootfs inittab)
vars+=(gitkernel gitbranch)
arrs+=(custmodules)

device_name="droid4"
arch="armhf"
size=1337
inittab=("s0:12345:respawn:/sbin/agetty -L ttyS2 115200 vt100")

parted_type="dos"
parted_boot="8192s 270335s"
parted_root="ext4 270336s 100%"
bootfs="ext2"

extra_packages+=(firmware-ti-connectivity)
custmodules=()

#gitkernel="https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git"
#gitbranch="v4.16-rc1"
gitkernel="https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git"
gitbranch="linux-4.14.y"


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

	if [[ -e "$strapdir/boot/boot/boot.cfg" ]]; then
		sudo sed -e "s/@release@/${release}/" -i "$strapdir/boot/boot/boot.cfg"
	fi
}

build_kernel_${arch}() {
	fn build_kernel_${arch}
	req=(R arch device_name gitkernel gitbranch MAKEOPTS)
	req+=(strapdir)
	req+=(loopdevice)
	ckreq || return 1

	notice "building $arch kernel"

	prebuild || zerr

	get-kernel-sources
	pushd $R/tmp/kernels/$device_name/${device_name}-linux
	git checkout -- .
	copy-kernel-config

	_patchdir="$R/extra/patches/linux-droid4-patches"
	_patchset="$(find ${_patchdir} -name '*.patch' | sort)"
	for i in "${=_patchset}"; do
		patch -p1 < "$i"
	done

	# compile kernel and modules
	make \
		$MAKEOPTS \
		ARCH=arm \
		CROSS_COMPILE=$compiler \
			zImage modules omap4-droid4-xt894.dtb || zerr
	sudo mkdir -p "$strapdir/boot/boot/"
	sudo cp -v arch/arm/boot/zImage "$strapdir/boot/boot" || zerr
	sudo cp -v arch/arm/boot/dts/omap4-droid4-xt894.dtb "$strapdir/boot/boot" || zerr

	# install kernel modules
	sudo -E PATH="$PATH" \
		make \
			$MAKEOPTS \
			ARCH=arm \
			CROSS_COMPILE=$compiler \
			INSTALL_MOD_PATH=$strapdir \
			INSTALL_MOD_STRIP=1 \
				modules_install || zerr
	popd

	postbuild || zerr
}
