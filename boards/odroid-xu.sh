#!/usr/bin/env zsh
# Copyright (c) 2016-2021 Ivan J. <parazyd@dyne.org>
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

## kernel build script for ODROID XU boards

## settings & config
vars+=(device_name arch size parted_type parted_boot parted_root bootfs inittab)
vars+=(gitkernel gitbranch hosttuple)
arrs+=(custmodules extra_packages)

device_name="odroidxu"
arch="armhf"
size=1337
inittab=("T1:12345:respawn:/bin/login -f root ttySAC2 /dev/ttySAC2 2>&1")

## this is used for crosscompiling exynos5-hwcomposer.
## without it there is no framebuffer console.
hosttuple=${compiler:0:-1}

parted_type="dos"
bootfs="vfat"
rootfs="ext4"
dos_boot="fat32 2048s 264191s"
dos_root="$rootfs 264192s 100%"

extra_packages+=()
custmodules=()

gitkernel="https://github.com/hardkernel/linux.git"
gitbranch="odroidxu-3.4.y"


prebuild() {
	fn prebuild
	req=(device_name strapdir)
	ckreq || return 1

	notice "executing $device_name prebuild"

	copy-root-overlay

	mkdir -p $R/tmp/kernels/$device_name

	print "M    ttySAC2 c 5 1" | sudo tee -a $strapdir/etc/udev/links.conf
	cat <<EOF | sudo tee -a $strapdir/etc/securetty
ttySAC0
ttySAC1
ttySAC2
EOF
}

postbuild() {
	fn postbuild

	notice "executing $device_name postbuild"

	## {{{ boot txts
	notice "Writing bootinfos..."
	# 720p
	cat << EOF | sudo tee ${strapdir}/boot/boot-hdmi-720.txt
setenv initrd_high "0xffffffff"
setenv fdt_high "0xffffffff"
setenv fb_x_res "1280"
setenv fb_y_res "720"
setenv hdmi_phy_res "720"
setenv bootcmd "fatload mmc 0:1 0x40008000 zImage; fatload mmc 0:1 0x42000000 uInitrd; bootz 0x40008000 0x42000000"
setenv bootargs "console=tty1 console=ttySAC2,115200n8 vmalloc=512M fb_x_res=\${fb_x_res} fb_y_res=\${fb_y_res} hdmi_phy_res=\${hdmi_phy_res} vout=hdmi led_blink=1 fake_fb=true root=/dev/mmcblk0p2 rootwait rootfstype=ext4 rw net.ifnames=0"
boot
EOF
	# 1080p
	cat << EOF | sudo tee ${strapdir}/boot/boot-hdmi-1080.txt
setenv initrd_high "0xffffffff"
setenv fdt_high "0xffffffff"
setenv fb_x_res "1920"
setenv fb_y_res "1080"
setenv hdmi_phy_res "1080"
setenv bootcmd "fatload mmc 0:1 0x40008000 zImage; fatload mmc 0:1 0x42000000 uInitrd; bootz 0x40008000 0x42000000"
setenv bootargs "console=tty1 console=ttySAC2,115200n8 vmalloc=512M fb_x_res=\${fb_x_res} fb_y_res=\${fb_y_res} hdmi_phy_res=\${hdmi_phy_res} vout=hdmi led_blink=1 fake_fb=true root=/dev/mmcblk0p2 rootwait rw rootfstype=ext4 net.ifnames=0"
boot
EOF
	## }}}

	notice "creating u-boot script images"
	sudo mkimage -A arm -T script -C none -d $strapdir/boot/boot-hdmi-720.txt \
		$strapdir/boot/boot-720.scr
	sudo mkimage -A arm -T script -C none -d $strapdir/boot/boot-hdmi-1080.txt \
		$strapdir/boot/boot-1080.scr
	sudo cp $CPVERBOSE $strapdir/boot/boot-720.scr $strapdir/boot/boot.scr

	notice "doing u-boot magic"
	pushd $R/tmp/kernels/$device_name/${device_name}-linux/tools/hardkernel/u-boot-pre-built
	sudo sh sd_fusing.sh $loopdevice
	act " ^ not this time :)"

	postbuild-clean
}

build_kernel_armhf() {
	fn build_kernel_armhf
	req=(R arch device_name gitkernel gitbranch MAKEOPTS)
	req+=(strapdir loopdevice)
	ckreq || return 1

	notice "building $arch kernel"

	prebuild || zerr

	get-kernel-sources
	pushd $R/tmp/kernels/$device_name/${device_name}-linux
		make \
			$MAKEOPTS \
			ARCH=arm \
			CROSS_COMPILE=$compiler \
				odroidxu_ubuntu_defconfig || zerr
		make \
			$MAKEOPTS \
			ARCH=arm \
			CROSS_COMPILE=$compiler || zerr
		sudo -E PATH="$PATH" \
			make \
				$MAKEOPTS \
				ARCH=arm \
				CROSS_COMPILE=$compiler \
				INSTALL_MOD_PATH=$strapdir \
					modules_install || zerr
		sudo cp -v arch/arm/boot/zImage $strapdir/boot/
	popd

	notice "building hwcomposer"
	pushd $R/tmp/kernels/$device_name/${device_name}-linux/tools/hardkernel/exynos5-hwcomposer
	## it's quite chatty still, so we if 0 the logging, and also add a missing #define
	sed -i -e 's/if 1/if 0/g' include/log.h
	sed -i -e 's/#define ALOGD/#define ALOGD\r#define ALOGF/g' include/log.h

	./configure --prefix=/usr --build x86_64-pc-linux-gnu --host $hosttuple || zerr
	make \
		$MAKEOPTS \
		ARCH=arm \
		CROSS_COMPILE=$compiler || zerr
	sudo -E PATH="$PATH" \
		make \
			$MAKEOPTS \
			ARCH=arm \
			CROSS_COMPILE=$compiler \
			DESTDIR=$strapdir \
				install || zerr
	sudo sed -i -e \
		's:^exit 0:exynos5-hwcomposer > /dev/null 2\&1 \&\nexit 0:' \
		$strapdir/etc/rc.local

	#sudo rm -rf $strapdir/lib/firmware
	#get-kernel-firmware
	#sudo cp $CPVERBOSE -ra $R/tmp/linux-firmware $strapdir/lib/firmware

	pushd $R/tmp/kernels/$device_name/${device_name}-linux
		sudo -E PATH="$PATH" \
			make \
				$MAKEOPTS \
				ARCH=arm \
				CROSS_COMPILE=$compiler \
				INSTALL_MOD_PATH=$strapdir \
					firmware_install || zerr
		make \
			$MAKEOPTS \
			ARCH=arm \
			CROSS_COMPILE=$compiler \
				mrproper
		#copy-kernel-config
		make \
			$MAKEOPTS \
			ARCH=arm \
			CROSS_COMPILE=$compiler \
				odroidxu_ubuntu_defconfig || zerr
		sudo -E PATH="$PATH" \
			make \
				$MAKEOPTS \
				ARCH=arm \
				CROSS_COMPILE=$compiler \
					modules_prepare || zerr
	popd

	postbuild || zerr
}
