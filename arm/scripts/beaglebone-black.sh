#!/usr/bin/env zsh
#
# Copyright (c) 2016 Dyne.org Foundation
# ARM SDK is written and maintained by parazyd <parazyd@dyne.org>
#
# This file is part of ARM SDK
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
#
# ARM SDK build script for BeagleBone Black devices (armhf)

# -- settings --
device_name="beagleboneblack"
arch="armhf"
size=1337
extra_packages=()
# Ones below should not need changing
parted_boot=(fat32 2048s 264191s)
parted_root=(ext4 264192s 100%)
inittab="T1:12345:respawn:/sbin/agetty 115200 ttyO0 vt100"
custmodules=()
# source common commands
workdir="$R/arm/${device_name}-build"
strapdir="${workdir}/${os}-${arch}"
source $common
image_name="${os}_${release}_${version}_${arch}_${device_name}"
# -- end settings --


${device_name}-build-kernel() {
	fn ${device_name}-build-kernel

	notice "Grabbing kernel sources"

	cd ${workdir}
	sudo mkdir ${strapdir}/usr/src/kernel && sudo chown $USER ${strapdir}/usr/src/kernel
	git clone https://github.com/beagleboard/linux -b 4.1 --depth 1 ${strapdir}/usr/src/kernel

	notice "Compiling kernel"
	cd ${strapdir}/usr/src/kernel
	ARCH=arm make bb.org_defconfig
	make -j $(grep -c processor /proc/cpuinfo)
	sudo cp arch/arm/boot/zImage ${workdir}/bootp/zImage
	sudo mkdir -p ${workdir}/bootp/dtbs
	sudo cp arch/arm/boot/dts/*.dtb ${workdir}/bootp/dtbs/
	notice "Installing kernel modules"
	sudo chown $USER ${strapdir}/lib
	make INSTALL_MOD_PATH=${strapdir} modules_install
	sudo chown root ${strapdir}/lib

	notice "Creating uEnv.txt file"
	cat << EOF | sudo tee ${workdir}/bootp/uEnv.txt
#u-boot eMMC specific overrides; Angstrom Distribution (BeagleBone Black) 2013-06-20
kernel_file=zImage
initrd_file=uInitrd

loadzimage=load mmc \${mmcdev}:\${mmcpart} \${loadaddr} \${kernel_file}
loadinitrd=load mmc \${mmcdev}:\${mmcpart} 0x81000000 \${initrd_file}; setenv initrd_size \${filesize}
loadfdt=load mmc \${mmcdev}:\${mmcpart} \${fdtaddr} /dtbs/\${fdtfile}
#

console=ttyO0,115200n8
mmcroot=/dev/mmcblk0p2 rw net.ifnames=0
mmcrootfstype=ext4 rootwait fixrtc

##To disable HDMI/eMMC...
#optargs=capemgr.disable_partno=BB-BONELT-HDMI,BB-BONELT-HDMIN,BB-BONE-EMMC-2G

##3.1MP Camera Cape
#optargs=capemgr.disable_partno=BB-BONE-EMMC-2G

mmcargs=setenv bootargs console=\${console} root=\${mmcroot} rootfstype=\${mmcrootfstype} \${optargs}

#zImage:
uenvcmd=run loadzimage; run loadfdt; run mmcargs; bootz \${loadaddr} - \${fdtaddr}

#zImage + uInitrd: where uInitrd has to be generated on the running system.
#boot_fdt=run loadzimage; run loadinitrd; run loadfdt
#uenvcmd=run boot_fdt; run mmcargs; bootz \${loadaddr} 0x81000000:\${initrd_size} \${fdtaddr}
EOF

	notice "Writing Xorg conf for future use"
	cat << EOF | sudo tee ${strapdir}/root/xorg.conf
# For using Xorg, move this file to /etc/X11/xorg.conf
Section "Monitor"
	Identifier    "Builtin Default Monitor"
EndSection

Section "Device"
	Identifier    "Builtin Default fbdev Device 0"
	Driver        "fbdev"
	Option        "SWCursor" "true"
EndSection

Section "Screen"
	Identifier    "Builtin Default fbdev Screen 0"
	Device        "Builtin Default fbdev Device 0"
	Monitor       "Builtin Default Monitor"
	DefaultDepth  16
	# Comment out the above and uncomment the below if using a
	# bbb-view or bbb-exp
	#DefaultDepth  24
EndSection

Section "ServerLayout"
	Identifier    "Builtin Default Layout"
	Screen        "Builtin Default fbdev Screen 0"
EndSection
EOF

	notice "Installing firmware..."
	sudo rm -r ${strapdir}/lib/firmware
	sudo chown $USER ${strapdir}/lib
	get-kernel-firmware
	cp -ra $R/tmp/firmware ${strapdir}/lib/firmware
	cd ${strapdir}/usr/src/kernel
	make INSTALL_MOD_PATH=${strapdir} firmware_install
	make mrproper
	ARCH=arm make bb.org_defconfig
	make modules_prepare

	notice "Grabbing script for using usb as an ethernet device"
	sudo wget -c \
		https://raw.github.com/RobertCNelson/tools/master/scripts/beaglebone-black-g-ether-load.sh \
		-O ${strapdir}/root/beaglebone-black-g-ether-load.sh

	cd ${workdir}

	notice "Finished building kernel"
	notice "Next step is: ${device_name}-finalize"
}
