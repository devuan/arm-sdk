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

## kernel build script for Raspberry Pi 2/3 boards

## settings & config
vars+=(device_name arch size parted_boot parted_root inittab)
vars+=(gitkernel gitbranch rpifirmware)
arrs+=(custmodules extra_packages)

device_name="raspi"
arch="armhf"
size=1337
inittab="T0:23:respawn:/sbin/agetty -L ttyAMA0 115200 vt100"

parted_boot="fat32 0 64"
parted_root="ext4 64 -1"

extra_packages=(wpasupplicant)
custmodules=() # add the snd module here perhaps

gitkernel="https://github.com/raspberrypi/linux.git"
gitbranch="rpi-4.4.y"
rpifirmware="https://github.com/raspberrypi/firmware.git"

build_kernel_armhf() {
	fn build_kernel_armhf
	req=(R arch device_name gitkernel gitbranch MAKEOPTS rpifirmware)
	req+=(workdir strapdir)
	ckreq || return 1

	notice "building $arch kernel"

	act "grabbing kernel sources"
	mkdir -p $R/tmp/kernels/$device_name

	git clone --depth 1 \
		$gitkernel \
		-b $gitbranch \
		$R/tmp/kernels/$device_name/${device_name}-linux

	pushd $R/tmp/kernels/$device_name/${device_name}-linux
	make bcm2709_defconfig
	make $MAKEOPTS
	sudo make INSTALL_MOD_PATH=$strapdir modules_install ## this replaces make-kernel-modules
	popd

	notice "grabbing rpi-firmware..."
	git clone --depth 1 \
		$rpifirmware \
		$R/tmp/kernels/$device_name/${device_name}-firmware

	sudo cp -rfv $R/tmp/kernels/$device_name/${device_name}-firmware/boot/* $workdir/boot/

	pushd ${device_name}-linux
	sudo perl scripts/mkknlimg --dtok arch/arm/boot/zImage $workdir/boot/kernel7.img
	sudo cp -v arch/arm/boot/dts/bcm*.dtb $workdir/boot
	sudo cp -v arch/arm/boot/dts/overlays/*overlay*.dtb $workdir/boot/overlays/
	popd

	sudo rm -rf $strapdir/lib/firmware
	get-kernel-firmware
	sudo cp -ra $R/tmp/linux-firmware $strapdir/lib/firmware

	pushd $R/tmp/kernels/$device_name/${device_name}-linux
	sudo make INSTALL_MOD_PATH=$strapdir firmware_install
	#make mrproper
	#make bcm2709_defconfig
	sudo make modules_prepare
	popd

	notice "creating cmdline.txt"
	## TODO: add other .txt too
	cat <<EOF | sudo tee ${workdir}/boot/cmdline.txt
dwc_otg.fiq_fix_enable=2 console=ttyAMA0,115200 kgdboc=ttyAMA0,115200 console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4 rootwait rootflags=noload net.ifnames=0 quiet
EOF

	## TODO: remove systemd merda from raspi-config and add here

	notice "installing raspberry pi 3 firmware for bt/wifi"
	sudo mkdir -p $strapdir/lib/firmware/brcm
	sudo cp -v $R/extra/rpi3/brcmfmac43430-sdio.txt $strapdir/lib/firmware/brcm/
	sudo cp -v $R/extra/rpi3/brcmfmac43430-sdio.bin $strapdir/lib/firmware/brcm/
}