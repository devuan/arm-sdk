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

device_name="n9"
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

# patch series from linux-omap patchwork
# [PATCHv2 0/8] omapdrm: DSI command mode panel support
patchids=(
	10207753 # [PATCHv2,1/8] drm/omap: add framedone interrupt support
	10207763 # [PATCHv2,2/8] drm/omap: add manual update detection helper
	10207759 # [PATCHv2,3/8] drm/omap: add support for manually updated displays
	10207749 # [PATCHv2,4/8] dt-bindings: panel: common: document orientation property
	10207733 # [PATCHv2,5/8] drm/omap: add support for orientation hints from display drivers
	10207747 # [PATCHv2,6/8] drm/omap: panel-dsi-cm: add orientation support
	10207755 # [PATCHv2,7/8] ARM: dts: omap4-droid4: Add LCD panel orientation property
	10207743 # [PATCHv2,8/8] drm/omap: plane: update fifo size on ovl setup
)
pwclient=$R/extra/pwclient/pwclient

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

	notice "applying patches from patchwork"
	cp $R/extra/pwclient/.pwclientrc ~
	$pwclient git-am -p linux-omap $patchids

	notice "applying addtional patches"
	_patchdir="$R/extra/patches/linux-n9-patches"
	_patchset="$(find ${_patchdir} -name '*.patch' | sort)"
	for i in "${=_patchset}"; do
		patch -p1 < "$i"
	done

	# Atmel maXTouch configuration
	cp $_patchdir/RM-696_Pyrenees_SMD_V1_6.raw firmware/maxtouch.cfg

	# remove "-dirty" from kernel version tag
	touch .scmversion

	# compile kernel and modules
	make \
		$MAKEOPTS \
		ARCH=arm \
		CROSS_COMPILE=$compiler \
			zImage modules omap3-n9.dtb || zerr
	cat arch/arm/boot/zImage arch/arm/boot/dts/omap3-n9.dtb > zImage || zerr

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
