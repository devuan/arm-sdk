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

## kernel build script for Banana Pi boards

## settings & config
vars+=(device_name arch size parted_type parted_boot parted_root inittab)
vars+=(gitkernel gitbranch sunxi_tools sunxi_uboot sunxi_boards)
arrs+=(custmodules)

device_name="bananapi"
arch="armhf"
size=1337
inittab="T1:12345:respawn:/sbin/agetty -L ttyS0 115200 vt100"

parted_type="dos"
parted_boot="fat32 2048s 264191s"
parted_root="ext4 264192s 100%"

extra_packages+=()
custmodules=(sunxi_emac)

gitkernel="https://github.com/LeMaker/linux-sunxi.git"
gitbranch="lemaker-3.4"
sunxi_tools="https://github.com/linux-sunxi/sunxi-tools.git"
sunxi_uboot="https://github.com/LeMaker/u-boot-bananapi.git"
sunxi_boards="https://github.com/LeMaker/sunxi-boards.git"


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

	clone-git $sunxi_boards "$R/tmp/kernels/$device_name/sunxi-boards" || zerr
	clone-git $sunxi_tools  "$R/tmp/kernels/$device_name/sunxi-tools"  || zerr
	clone-git $sunxi_uboot  "$R/tmp/kernels/$device_name/sunxi-uboot"  || zerr

	pushd $R/tmp/kernels/$device_name/sunxi-tools
		act "running fex2bin"
		make fex2bin || zerr
		sudo ./fex2bin \
			$R/tmp/kernels/$device_name/sunxi-boards/sys_config/a20/BananaPi.fex \
			$strapdir/boot/script.bin || zerr
	popd
}

postbuild() {
	fn postbuild

	notice "executing $device_name postbuild"

	notice "building u-boot"
	pushd $R/tmp/kernels/$device_name/sunxi-uboot
		make distclean
		make BananaPi_config
		make $MAKEOPTS || zerr
		act "dd-ing to image..."
		sudo dd if=u-boot-sunxi-with-spl.bin of=$loopdevice bs=1024 seek=8 || zerr
	popd

	## {{{ boot txts
	notice "creating boot.cmd"
	cat <<EOF | sudo tee ${strapdir}/boot/boot.cmd
setenv bootm_boot_mode sec
setenv bootargs console=ttyS0,115200 root=/dev/mmcblk0p2 rootwait panic=10 ${extra} rw rootfstype=ext4 net.ifnames=0
fatload mmc 0 0x43000000 script.bin
fatload mmc 0 0x48000000 uImage
bootm 0x48000000
EOF
	## }}}

	notice "creating u-boot script image"
	sudo mkimage -A arm -T script -C none -d $strapdir/boot/boot.cmd $strapdir/boot/boot.scr || zerr

	postbuild-clean
}

build_kernel_armhf() {
	fn build_kernel_armhf
	req=(R arch device_name gitkernel gitbranch MAKEOPTS)
	req+=(strapdir sunxi_tools sunxi_uboot sunxi_boards)
	req+=(loopdevice)
	ckreq || return 1

	notice "building $arch kernel"

	prebuild || zerr

	get-kernel-sources
	pushd $R/tmp/kernels/$device_name/${device_name}-linux
		make sun7i_defconfig
		make $MAKEOPTS uImage modules || zerr
		sudo -E PATH="$PATH" \
			make INSTALL_MOD_PATH=$strapdir modules_install || zerr
	popd

	#sudo rm -rf $strapdir/lib/firmware
	#get-kernel-firmware
	#sudo cp $CPVERBOSE -ra $R/tmp/linux-firmware $strapdir/lib/firmware

	pushd $R/tmp/kernels/$device_name/${device_name}-linux
		sudo -E PATH="$PATH" \
			make INSTALL_MOD_PATH=$strapdir firmware_install || zerr
		sudo cp $CPVERBOSE arch/arm/boot/uImage $strapdir/boot/
		make mrproper
		make sun7i_defconfig
		sudo -E PATH="$PATH" \
			make modules_prepare || zerr
	popd

	postbuild || zerr
}
