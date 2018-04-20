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

## kernel build script for Nokia N950

## settings & config
vars+=(device_name arch size parted_type parted_boot parted_root bootfs inittab)
vars+=(gitkernel gitbranch)
arrs+=(custmodules)

device_name="n950"
arch="armhf"
size=1337

parted_type="dos"
parted_boot="fat32 8192s 270335s"
parted_root="ext4 270336s 100%"
bootfs="none"

extra_packages+=(firmware-ti-connectivity)
custmodules=()

gitkernel="https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git"
gitbranch="linux-4.16.y"

postbuild() {
	fn postbuild

	notice "executing $device_name postbuild"

	copy-root-overlay
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
	git checkout -- .
	copy-kernel-config

	notice "applying patches"
	_patchdir="$R/extra/patches/linux-n950-patches"
	_patchset="$(find ${_patchdir} -name '*.patch' | sort)"
	for i in "${=_patchset}"; do
		patch -p1 < "$i"
	done

	# Atmel maXTouch configuration
	cp $_patchdir/RM-680_Himalaya_AUO_V1_1.raw firmware/maxtouch.cfg

	# remove "-dirty" from kernel version tag
	touch .scmversion

	# compile kernel and modules
	make \
		$MAKEOPTS \
		ARCH=arm \
		CROSS_COMPILE=$compiler \
			zImage modules omap3-n950.dtb || zerr
	cat arch/arm/boot/zImage arch/arm/boot/dts/omap3-n950.dtb > zImage || zerr

	# install kernel modules
	sudo -E PATH="$PATH" \
		make \
			$MAKEOPTS \
			ARCH=arm \
			CROSS_COMPILE=$compiler \
			INSTALL_MOD_PATH=$strapdir \
			INSTALL_MOD_STRIP=1 \
				modules_install || zerr
	sudo cp -v zImage $strapdir/boot
	popd

	postbuild || zerr
}
