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
vars+=(device_name arch size parted_type parted_boot parted_root inittab)
vars+=(gitkernel gitbranch rpifirmware)
arrs+=(custmodules extra_packages)

device_name="raspi"
arch="armhf"
size=1337
inittab="T0:23:respawn:/sbin/agetty -L ttyAMA0 115200 vt100"

parted_type="dos"
parted_boot="fat32 0 64"
parted_root="ext4 64 -1"

extra_packages=(wpasupplicant)
custmodules=() # add the snd module here perhaps

gitkernel="https://github.com/raspberrypi/linux.git"
gitbranch="rpi-4.4.y"
rpifirmware="https://github.com/raspberrypi/firmware.git"

prebuild() {
	fn prebuild
	req=(device_name strapdir)
	ckreq || return 1

	notice "executing $device_name prebuild"

	## fstab
	cat <<EOF | sudo tee ${strapdir}/etc/fstab
## <file system>  <mount point> <type> <options>           <dump><pass>
## proc
proc              /proc         proc   nodev,noexec,nosuid    0    0

## rootfs
/dev/mmcblk0p2    /             ext4   errors=remount-ro      0    1

## bootfs
/dev/mmcblk0p1    /boot         vfat   noauto                 0    0
EOF
}

postbuild() {
	fn postbuild

	notice "executing $device_name postbuild"

	cat <<EOF | sudo tee -a ${strapdir}/etc/apt/sources.list

## raspbian repositories needed for certain packages
deb http://archive.raspbian.org/raspbian jessie main contrib non-free rpi firmware
#deb-src http://archive.raspbian.org/raspbian jessie main contrib non-free rpi firmware

## for omxplayer
deb http://linux.subogero.com/deb /

deb http://pipplware.pplware.pt/pipplware/dists/jessie/main/binary /

EOF

	cat <<EOF | sudo tee ${strapdir}/postbuild
#!/bin/sh
apt-get update
apt-get upgrade
rm -f /postbuild
rm -f /usr/bin/${qemu_bin}
EOF
	chmod +x $strapdir/postbuild
	chroot $strapdir /postbuild || zerr
}

build_kernel_armhf() {
	fn build_kernel_armhf
	req=(R arch device_name gitkernel gitbranch MAKEOPTS rpifirmware)
	req+=(workdir strapdir)
	ckreq || return 1

	prebuild || zerr

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
	make mrproper
	make bcm2709_defconfig
	sudo make modules_prepare
	popd

	notice "creating cmdline.txt"
	cat <<EOF | sudo tee ${workdir}/boot/cmdline.txt
dwc_otg.fiq_fix_enable=2 console=ttyAMA0,115200 kgdboc=ttyAMA0,115200 console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4 rootwait rootflags=noload net.ifnames=0 quiet
EOF

	notice "creating config.txt"
	cat <<EOF | sudo tee ${workdir}/boot/config.txt
## memory shared with the GPU
gpu_mem=64

dtparam=audio=on

max_usb_current=1
EOF

	## TODO: remove systemd merda from raspi-config and add here

	notice "installing raspberry pi 3 firmware for bt/wifi"
	sudo mkdir -p $strapdir/lib/firmware/brcm
	sudo cp -v $R/extra/rpi3/brcmfmac43430-sdio.txt $strapdir/lib/firmware/brcm/
	sudo cp -v $R/extra/rpi3/brcmfmac43430-sdio.bin $strapdir/lib/firmware/brcm/

	postbuild || zerr
}
