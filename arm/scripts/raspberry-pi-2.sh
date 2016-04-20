#!/usr/bin/env zsh
#
# Copyright (C) 2015-2016 Dyne.org Foundation
#
# ARM SDK is designed, written and maintained by parazyd <parazyd@dyne.org>
#
# This source code is free software; you can redistribute it and/or
# modify it under the terms of the GNU Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This source code is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  Please refer
# to the GNU Public License for more details.
#
# You should have received a copy of the GNU Public License along with
# this source code; if not, write to: Free Software Foundation, Inc.,
# 675 Mass Ave, Cambridge, MA 02139, USA.
#
# ARM SDK build script for Raspberry Pi 2 and 3 devices (armhf)

# -- settings --
device_name="raspi2"
arch="armhf"
size=1337
extra_packages=(wpasupplicant ntpdate)
# Ones below should not need changing
#enable_qemu_wrapper=1 # Uncomment this to enable qemu-wrapper (consult the readme)
parted_boot=(fat32 0 64)
parted_root=(ext4 64 -1)
inittab="T0:23:respawn:/sbin/agetty -L ttyAMA0 115200 vt100"
custmodules=()
# source common commands
source $common
workdir="$R/arm/${armdev}-build"
strapdir="${workdir}/${os}-${arch}"
image_name="${os}-${release}-${version}-${arch}-${device_name}"
# -- end settings --

${device_name}-build-kernel() {
	fn ${device_name}-build-kernel

	notice "Grabbing kernel sources"
	sudo mkdir ${strapdir}/usr/src/kernel && sudo chown $USER ${strapdir}/usr/src/kernel

	cd ${strapdir}/usr/src
	git clone --depth 1 \
		https://github.com/raspberrypi/linux \
		-b rpi-4.1.y \
		${strapdir}/usr/src/kernel

	cd ${strapdir}/usr/src/kernel

	copy-kernel-config
	make -j `grep -c processor /proc/cpuinfo`
	make-kernel-modules

	notice "Grabbing rpi-firmware..."
	git clone --depth 1 \
			https://github.com/raspberrypi/firmware.git \
			rpi-firmware

	sudo cp -rfv rpi-firmware/boot/* ${workdir}/bootp/

	sudo perl scripts/mkknlimg --dtok arch/arm/boot/zImage ${workdir}/bootp/kernel7.img
	sudo cp -v arch/arm/boot/dts/bcm*.dtb ${workdir}/bootp/
	sudo cp -v arch/arm/boot/dts/overlays/*overlay*.dtb ${workdir}/bootp/overlays/

	sudo rm -rfv ${strapdir}/lib/firmware

	get-kernel-firmware
	sudo chown $USER ${strapdir}/lib
	cp -ra $R/tmp/firmware ${strapdir}/lib/firmware

	cd $strapdir/usr/src/kernel

	make INSTALL_MOD_PATH=${strapdir} firmware_install
	make mrproper

	cp -v ../${device_name}.config .config
	make modules_prepare

	notice "Creating cmdline.txt..."
	cat <<EOF | sudo tee ${workdir}/bootp/cmdline.txt
dwc_otg.fiq_fix_enable=2 console=ttyAMA0,115200 kgdboc=ttyAMA0,115200 console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4 rootwait rootflags=noload net.ifnames=0
EOF

	sudo rm -rf rpi-firmware && notice "Removed rpi-firmware leftovers"
	cd ${workdir}

	notice "Installing raspi-config..."
	sudo cp ${workdir}/../extra/rpi-conf/raspi-config ${strapdir}/usr/bin/raspi-config \
		&& notice "RPi-config: Installed script"
	sudo mkdir ${strapdir}/usr/lib/raspi-config
	sudo cp ${workdir}/../extra/rpi-conf/init_resize.sh ${strapdir}/usr/lib/raspi-config/init_resize.sh \
		&& notice "RPi-config: Installed init_resize"
	sudo cp ${workdir}/../extra/rpi-conf/raspi-config-init ${strapdir}/etc/init.d/raspi-config
	pushd ${strapdir}/etc/rcS.d
		sudo ln -s ../init.d/raspi-config S18raspi-config \
		&& notice "RPi-config: Installed governor initscript"
	popd

	notice "Installing RaspberryPi3 firmware for bt/wifi"
	sudo mkdir -p ${strapdir}/lib/firmware/brcm
	sudo cp -v ${workdir}/../extra/rpi3/brcmfmac43430-sdio.txt ${strapdir}/lib/firmware/brcm/
	sudo cp -v ${workdir}/../extra/rpi3/brcmfmac43430-sdio.bin ${strapdir}/lib/firmware/brcm/

	notice "Finished building kernel."
	notice "Next step is: ${device_name}-finalize"
}
