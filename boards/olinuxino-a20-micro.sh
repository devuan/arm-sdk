#!/usr/bin/env zsh
# Copyright (c) 2017 Dyne.org Foundation
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

## kernel build script for Olimex A20 OLinuXino-Micro boards
##  http://linux-sunxi.org/Olimex_A20_OLinuXino-Micro

## settings & config
vars+=(device_name arch size parted_type parted_boot parted_root inittab)
vars+=(gitkernel gitbranch)
arrs+=(custmodules)

device_name="micro"
arch="armhf"
size=1891
inittab="T1:12345:respawn:/sbin/agetty -L ttyS0 115200 vt100"

parted_type="dos"
parted_boot="fat32 2048s 264191s"
parted_root="ext4 264192s 100%"

extra_packages+=()
custmodules=()

gitkernel="git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git"
gitbranch="linux-4.10.y"

uboot=mainline
sunxi_uboot="git://git.denx.de/u-boot.git"

prebuild() {
	fn prebuild
    req=(device_name strapdir)
    ckreq || return 1

    notice "executing $device_name prebuild"

	copy-root-overlay

	mkdir -p $R/tmp/kernels/$device_name
}

    fn postbuild

    notice "executing $device_name postbuild"

    copy-root-overlay

    notice "building u-boot"
    clone-git $sunxi_uboot "$R/tmp/kernels/$device_name/u-boot" || zerr
    pushd $R/tmp/kernels/$device_name/u-boot
        make distclean
        make \
			$MAKEOPTS \
			ARCH=arm \
			CROSS_COMPILE=$compiler \
				A20-OLinuXino-MICRO_defconfig
        make \
			$MAKEOPTS \
			ARCH=arm \
			CROSS_COMPILE=$compiler || zerr

        act "dd-ing to image..."
        sudo dd if=u-boot-sunxi-with-spl.bin of=$loopdevice bs=1024 seek=8 || zerr
    popd

    notice "creating boot.cmd"
    cat <<EOF | sudo tee ${strapdir}/boot/boot.cmd
setenv bootargs console=ttyS0,115200 root=/dev/mmcblk0p2 rootwait panic=10
load mmc 0:1 0x43000000 \${fdtfile} || load mmc 0:1 0x43000000 boot/\${fdtfile}
load mmc 0:1 0x42000000 zImage || load mmc 0:1 0x42000000 boot/zImage
bootz 0x42000000 - 0x43000000
EOF

    notice "creating u-boot script image"
    sudo mkimage -A arm -T script -C none -d $strapdir/boot/boot.cmd $strapdir/boot/boot.scr || zer
r

    postbuild-clean
}

build_kernel_armhf() {
    fn build_kernel_armhf
    req=(R arch device_name gitkernel gitbranch MAKEOPTS)
    req+=(strapdir sunxi_uboot)
    req+=(loopdevice)
    ckreq || return 1

    notice "building $arch kernel"

    prebuild || zerr

    get-kernel-sources
    pushd $R/tmp/kernels/$device_name/${device_name}-linux
        copy-kernel-config
        make \
			$MAKEOPTS \
            ARCH=arm \
			CROSS_COMPILE=$compiler \
				zImage dtbs modules || zerr
        sudo -E PATH="$PATH" \
            make \
				$MAKEOPTS \
				ARCH=arm \
				CROSS_COMPILE=$compiler \
				INSTALL_MOD_PATH=$strapdir \
					modules_install || zerr

        sudo cp -v arch/arm/boot/zImage $strapdir/boot/ || zerr
        sudo cp -v arch/arm/boot/dts/sun7i-a20-olinuxino-micro.dtb $strapdir/boot/ || zerr
    popd

    postbuild || zerr
}
