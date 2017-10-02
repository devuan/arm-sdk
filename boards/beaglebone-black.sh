#!/usr/bin/env zsh
# Copyright (c) 2016-2017 Dyne.org Foundation
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

## kernel build script for BeagleBone Black boards

## settings & config
vars+=(device_name arch size inittab)
vars+=(parted_type parted_boot parted_root bootable_part bootfs)
vars+=(gitkernel gitbranch)
arrs+=(custmodules)

device_name="beagleboneblack"
arch="armhf"
size=1666
inittab=("T0:12345:respawn:/sbin/getty -L ttyS0 115200 vt100")

parted_type="dos"
parted_boot="fat32 2048s 264191s"
parted_root="ext4 264192s 100%"
bootable_part="1"
bootfs="vfat"

extra_packages+=()
custmodules=()

gitkernel="https://github.com/beagleboard/linux"
gitbranch="4.9"


prebuild() {
	fn prebuild
	req=(device_name strapdir)
	ckreq || return 1

	notice "executing $device_name prebuild"

	copy-root-overlay

	mkdir -p $R/tmp/kernels/$device_name
}

postbuild() {
	fn postbuild

	notice "executing $device_name postbuild"

	notice "building u-boot"

	pushd $R/extra/u-boot

	git checkout -b build "v2017.05"
	wget "https://rcn-ee.com/repos/git/u-boot-patches/v2017.05/0001-am335x_evm-uEnv.txt-bootz-n-fixes.patch"
	patch -p1 < "0001-am335x_evm-uEnv.txt-bootz-n-fixes.patch"

	make distclean
	make $MAKEOPTS ARCH=arm CROSS_COMPILE=$compiler am335x_evm_defconfig
	make $MAKEOPTS ARCH=arm CROSS_COMPILE=$compiler || zerr

	sudo cp -v MLO u-boot.img "$strapdir"/boot/

	git reset --hard
	git checkout -
	git branch -D build

	popd

	## {{{ uEnv.txt
	notice "creating uEnv.txt file"
	cat <<EOF | sudo tee ${strapdir}/boot/uEnv.txt
#u-boot eMMC specific overrides; Angstrom Distribution (BeagleBone Black) 2013-06-20
kernel_file=zImage
initrd_file=uInitrd

loadaddr=0x82000000
fdtaddr=0x88000000
initrd_addr=0x88080000

loadzimage=load mmc \${mmcdev}:\${mmcpart} \${loadaddr} \${kernel_file}
loadinitrd=load mmc \${mmcdev}:\${mmcpart} \${initrd_addr} \${initrd_file}; setenv initrd_size \${filesize}
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

#zImage + uInitrd: where uInitrd has to be generated on the running system
#boot_fdt=run loadzimage; run loadinitrd; run loadfdt
#uenvcmd=run boot_fdt; run mmcargs; bootz \${loadaddr} \${initrd_addr}:\${initrd_size} \${fdtaddr}
EOF
	## }}}
	## {{{ xorg.conf
	notice "writing xorg.conf for future use"
	cat <<EOF | sudo tee ${strapdir}/root/xorg.conf
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
	## }}}

	notice "grabbing script for using usb as ethernet device"
	sudo wget -c \
		https://raw.github.com/RobertCNelson/tools/master/scripts/beaglebone-black-g-ether-load.sh \
		-O $strapdir/root/bbb-ether-load.sh

	postbuild-clean
}

build_kernel_armhf() {
	fn build_kernel_armhf
	req=(R arch device_name gitkernel gitbranch MAKEOPTS)
	req+=(strapdir)
	req+=(loopdevice)
	ckreq || return 1

	notice "building $arch kernel"

	prebuild || zerr

	get-kernel-sources
	pushd $R/tmp/kernels/$device_name/${device_name}-linux
		ARCH=arm make bb.org_defconfig
		make $MAKEOPTS || zerr
		sudo cp $CPVERBOSE arch/arm/boot/zImage $strapdir/boot/zImage
		sudo mkdir -p $strapdir/boot/dtbs
		sudo cp $CPVERBOSE arch/arm/boot/dts/*.dtb $strapdir/boot/dtbs/
		sudo -E PATH="$PATH" \
			make INSTALL_MOD_PATH=$strapdir modules_install || zerr
	popd

	pushd $R/tmp/kernels/$device_name/${device_name}-linux
		sudo -E PATH="$PATH" \
			make INSTALL_MOD_PATH=$strapdir firmware_install || zerr
		make mrproper
		ARCH=arm make bb.org_defconfig
		sudo -E PATH="$PATH" \
			make modules_prepare || zerr
	popd

	postbuild || zerr
}
