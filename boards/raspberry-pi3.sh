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

## kernel build script for Raspberry Pi 3 boards

## settings & config
vars+=(device_name arch size parted_type parted_boot parted_root inittab)
vars+=(gitkernel gitbranch rpifirmware)
arrs+=(custmodules)

device_name="raspi3"
arch="arm64"
size=1337
inittab="T0:23:respawn:/sbin/agetty -L ttyAMA0 115200 vt100"

parted_type="dos"
parted_boot="fat32 0 64"
parted_root="ext4 64 -1"

extra_packages+=()
custmodules=(snd_bcm2835)

gitkernel="https://github.com/Electron752/linux.git"
gitbranch="rpi-4.6.y+rpi364"
rpifirmware="https://github.com/raspberrypi/firmware.git"


prebuild() {
	fn prebuild
	req=(device_name strapdir)
	ckreq || return 1

	notice "executing $device_name prebuild"

	export ARCH=arm64
	enablessh
	write-fstab
	copy-zram-init
	rdate-to-rclocal

	mkdir -p $R/tmp/kernels/$device_name
}

postbuild() {
	fn postbuild

	notice "executing $device_name postbuild"

	## {{{ boot txts
	notice "creating cmdline.txt"
	cat <<EOF | sudo tee ${strapdir}/boot/cmdline.txt
dwc_otg.fiq_fix_enable=2 console=ttyAMA0,115200 kgdboc=ttyAMA0,115200 console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4 rootwait rootflags=noload net.ifnames=0 quiet
EOF

	notice "creating config.txt"
	cat <<EOF | sudo tee ${strapdir}/boot/config.txt
## memory shared with the GPU
gpu_mem=64

## always audio
dtparam=audio=on

## maximum amps on usb ports
max_usb_current=1
EOF
	## }}}

	## TODO: remove systemd merda from raspi-config and add here

	notice "installing raspberry pi 3 firmware for bt/wifi"
	sudo mkdir -p $strapdir/lib/firmware/brcm
	sudo cp $CPVERBOSE $R/extra/rpi3/brcmfmac43430-sdio.txt $strapdir/lib/firmware/brcm/
	sudo cp $CPVERBOSE $R/extra/rpi3/brcmfmac43430-sdio.bin $strapdir/lib/firmware/brcm/

	postbuild-clean
}

build_kernel_arm64() {
	fn build_kernel_armhf
	req=(R arch device_name gitkernel gitbranch MAKEOPTS rpifirmware)
	req+=(strapdir)
	ckreq || return 1

	notice "building $arch kernel"

	prebuild || zerr

	get-kernel-sources
	pushd $R/tmp/kernels/$device_name/${device_name}-linux
		make ARCH=arm64 bcmrpi3_defconfig
		make ARCH=arm64 $MAKEOPTS || zerr
		sudo -E PATH="$PATH" \
			make \
				ARCH=arm64 \
				INSTALL_MOD_PATH=$strapdir modules_install || zerr
	popd

	clone-git $rpifirmware "$R/tmp/kernels/$device_name/${device_name}-firmware"
	sudo cp $CPVERBOSE -rf  $R/tmp/kernels/$device_name/${device_name}-firmware/boot/* $strapdir/boot/

	pushd $R/tmp/kernels/$device_name/${device_name}-linux
	#sudo perl scripts/mkknlimg --dtok arch/arm/boot/zImage       $strapdir/boot/kernel7.img
	sudo cp $CPVERBOSE arch/arm64/boot/Image                     $strapdir/boot/kernel8.img
	#sudo cp $CPVERBOSE arch/arm64/boot/dts/bcm*.dtb                $strapdir/boot/
	sudo cp $CPVERBOSE arch/arm64/boot/dts/broadcom/bcm2710-rpi-3-b.dtb $strapdir/boot/
	sudo cp $CPVERBOSE arch/arm64/boot/dts/overlays/*.dtbo $strapdir/boot/overlays/
	sudo cp $CPVERBOSE arch/arm64/boot/dts/overlays/README $strapdir/boot/overlays/
	popd

	#sudo rm -rf $strapdir/lib/firmware
	#get-kernel-firmware
	#sudo cp $CPVERBOSE -ra $R/tmp/linux-firmware $strapdir/lib/firmware

	pushd $R/tmp/kernels/$device_name/${device_name}-linux
		sudo -E PATH="$PATH" \
			make \
				ARCH=arm64 \
				INSTALL_MOD_PATH=$strapdir firmware_install || zerr
		make mrproper
		make ARCH=arm64 bcmrpi3_defconfig
		sudo -E PATH="$PATH" \
			make ARCH=arm64 modules_prepare || zerr
	popd

	postbuild || zerr
}
