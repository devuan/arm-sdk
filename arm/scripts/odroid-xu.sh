#!/usr/bin/env zsh
#
# ARM SDK
#
# Copyright (C) 2016 Dyne.org Foundation
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
# ARM SDK build script for ODROID XU devices (armhf)

# -- settings --
device_name="odroidxu"
arch="armhf"
size=1337
extra_packages=()
# This is used for crosscompiling exynos5-hwcomposer
# Without it there is no framebuffer console.
# Set according to your compiler.
hosttuple=arm-linux-gnueabihf
# Ones below should not need changing
parted_boot=(fat32 2048s 264191s)
parted_root=(ext4 264192s 100%)
inittab="T1:12345:respawn:/bin/login -f root ttySAC2 /dev/ttySAC2 2>&1"
custmodules=()
# source common commands
workdir="$R/arm/${device_name}-build"
strapdir="${workdir}/${os}-${arch}"
source $common
image_name="${os}-${release}-${version}-${arch}-${device_name}"
# -- end settings --


${device_name}-build-kernel() {
	fn ${device_name}-build-kernel

	cd ${workdir}

	cat << EOF | sudo tee -a ${strapdir}/etc/udev/links.conf
M    ttySAC2 c 5 1
EOF

	cat << EOF | sudo tee -a ${strapdir}/etc/securetty
ttySAC0
ttySAC1
ttySAC2
EOF

	sudo cp ${strapdir}/etc/skel/.profile ${strapdir}/root/.bash_profile

	write-sources-list

	notice "Grabbing kernel sources"
	sudo mkdir -p ${strapdir}/usr/src/kernel && sudo chown $UID:$GID ${strapdir}/usr/src/kernel
	git clone --depth 1 https://github.com/hardkernel/linux.git -b odroidxu-3.4.y ${strapdir}/usr/src/kernel

	cd ${strapdir}/usr/src/kernel
	copy-kernel-config

	make -j `grep -c processor /proc/cpuinfo`
	make-kernel-modules

	sudo cp arch/arm/boot/zImage ${workdir}/bootp

	notice "Building the hwcomposer"
	cd ${strapdir}/usr/src/kernel/tools/hardkernel/exynos5-hwcomposer
	# It's quite chatty still, so we if 0 the logging, and also add a missing #define
	sed -i -e 's/if 1/if 0/g' include/log.h
	sed -i -e 's/#define ALOGD/#define ALOGD\r#define ALOGF/g' include/log.h

	./configure --prefix=/usr --build x86_64-pc-linux-gnu --host $hosttuple
	make
	sudo make DESTDIR=${strapdir} install

	sudo sed -i -e 's~^exit 0~exynos5-hwcomposer > /dev/null 2>\&1 \&\nexit 0~' ${strapdir}/etc/rc.local

	cd ${strapdir}/usr/src/kernel
	make mrproper
	cp -v ../${device_name}.config .config
	make modules_prepare
	cd ${workdir}

	notice "Writing bootinfos..."
	# 720p
	cat << EOF | sudo tee ${workdir}/bootp/boot-hdmi-720.txt
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
	cat << EOF | sudo tee ${workdir}/bootp/boot-hdmi-1080.txt
setenv initrd_high "0xffffffff"
setenv fdt_high "0xffffffff"
setenv fb_x_res "1920"
setenv fb_y_res "1080"
setenv hdmi_phy_res "1080"
setenv bootcmd "fatload mmc 0:1 0x40008000 zImage; fatload mmc 0:1 0x42000000 uInitrd; bootz 0x40008000 0x42000000"
setenv bootargs "console=tty1 console=ttySAC2,115200n8 vmalloc=512M fb_x_res=\${fb_x_res} fb_y_res=\${fb_y_res} hdmi_phy_res=\${hdmi_phy_res} vout=hdmi led_blink=1 fake_fb=true root=/dev/mmcblk0p2 rootwait rw rootfstype=ext4 net.ifnames=0"
boot
EOF

	notice "Making bootimgs..."
	sudo mkimage -A arm -T script -C none -d ${basedir}/bootp/boot-hdmi-720.txt ${basedir}/bootp/boot-720.scr
	sudo mkimage -A arm -T script -C none -d ${basedir}/bootp/boot-hdmi-1080.txt ${basedir}/bootp/boot-1080.scr
	sudo cp ${workdir}/bootp/boot-720.scr ${workdir}/bootp/boot.scr

	notice "Getting firmware..."
	sudo rm -r ${strapdir}/lib/firmware
	sudo chown $USER ${strapdir}/lib
	get-kernel-firmware
	cp -ra $R/tmp/firmware ${strapdir}/lib/firmware

	notice "Doing u-boot magic"
	cd ${strapdir}/usr/src/kernel/tools/hardkernel/u-boot-pre-built
	sudo sh sd_fusing.sh $loopdevice

	notice "Finished building kernel"
	notice "Next step is: ${device_name}-finalize"
}
