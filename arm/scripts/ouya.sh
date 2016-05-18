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
# ARM SDK build script for OUYA Game console Qdevices (armhf)

# -- settings --
device_name="ouya"
arch="armhf"
size=1337
extra_packages=(libasound2 libglib2.0-0 libgstreamer-plugins-base0.10-0 libxv1)
# Ones below should not need changing
parted_boot=(fat32 2048s 264191s)
parted_root=(ext4 264192s 100%)
inittab="T0:2345:respawn:/sbin/getty -L ttyS0 115200 linux"
custmodules=()
# source common commands
workdir="$R/arm/${device_name}-build"
strapdir="${workdir}/${os}-${arch}"
source $common
image_name="${os}_${release}_${version}_${arch}_${device_name}"
# -- end settings --


${device_name}-build-kernel() {
	fn ${device_name}-build-kernel

	# This device is a bit strange, because I do not want people to flash it on
	# the device's NAND. You will brick it. Instead, we use the device's kernel
	# and boot this image from a USB flash drive.
	#
	# Consult the README (quirks part) to find out how to boot this.

	# https://github.com/kulve/tegra-debian
	# http://tuomas.kulve.fi/blog/2013/09/12/debian-on-ouya-all-systems-go/

	override_fstab=1
	notice "Writing fstab"
	cat << EOF | sudo tee ${strapdir}/etc/fstab
# <file system> <mount point> <type> <options> <dump> <pass>
/dev/sda2 / ext4 noatime,errors=remount-ro 0 1
tmpfs /tmp tmpfs defaults 0 0
EOF

	notice "Copying some more kernel modules"
	sudo cp -ra $R/arm/extra/ouya/3.1.10-tk3+ ${strapdir}/lib/modules/

	notice "Finished building kernel"
	notice "Next step is: ${device_name}-finalize"
}

# We copy the .debs needed
cp $R/arm/extra/ouya/*.deb $R/arm/extra/pkginclude/
