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

## kernel build script for OUYA Game console

## settings & config
vars+=(device_name arch size parted_boot parted_root inittab)
vars+=(gitkernel gitbranch)
arrs+=(custmodules extra_packages)

device_name="ouya"
arch="armhf"
size=1337

inittab="T0:2345:respawn:/sbin/getty -L ttyS0 115200 linux"

## partition scheme for parted to use
parted_boot="fat32 2048s 264191s"
parted_root="ext4 264192s 100%"

extra_packages=(libasound2 libglib2.0-0 libgstreamer-plugins-base0.10-0 libxv1)
custmodules=()

postinst() {
	fn postinst
	req=(strapdir)
	ckreq || return 1

	sudo mkdir -p $strapdir/ouya
	sudo cp $R/extra/ouya/*.deb $strapdir/ouya/

	cat <<EOF | sudo tee ${strapdir}/ouya.sh
#!/bin/sh
for deb in /ouya/*.deb; do
	dpkg -i $deb
done
rm -rf /ouya
rm -f /ouya.sh
EOF

	sudo chmod +x $strapdir/ouya.sh
	sudo chroot $strapdir /ouya.sh
}

build_kernel_armhf() {
	fn build_kernel_armhf
	req+=(workdir strapdir)
	ckreq || return 1

	# This device is a bit strange, because I do not want people to flash it on
	# the device's NAND. You will brick it. Instead, we use the device's kernel
	# and boot this image from a USB flash drive.
	#
	# Consult doc/quirks.md to find out how to boot this.
	#
	# https://github.com/kulve/tegra-debian
	# http://tuomas.kulve.fi/blog/2013/09/12/debian-on-ouya-all-systems-go/

	cat <<EOF | sudo tee ${strapdir}/etc/fstab
# <file system> <mount point> <type> <options> <dump> <pass>
/dev/sda2 / ext4 noatime,errors=remount-ro 0 1
tmpfs /tmp tmpfs defaults 0 0
EOF

	notice "copying some kernel modules"
	sudo cp -ra $R/extra/ouya/3.1.10-tk3+ $strapdir/lib/modules/
}
