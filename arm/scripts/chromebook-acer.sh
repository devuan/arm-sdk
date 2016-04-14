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
# ARM SDK build script for Acer Chromebook devices (armhf)

# -- settings --
device_name="chromeacer"
arch="armhf"
image_name="${os}-${release}-${version}-${arch}-${device_name}"
size=1337
extra_packages=(wpasupplicant abootimg cgpt fake-hwclock u-boot-tools ntpdate)
extra_packages+=(vboot-tools vboot-utils vboot-kernel utils)
extra_packages+=(laptop-mode-tools usbutils dhcpcd5)
# Ones below should not need changing
workdir="$R/arm/${device_name}-build"
strapdir="${workdir}/${os}-${arch}"
qemu_bin="/usr/bin/qemu-arm-static" # Devuan
#qemu_bin="/usr/bin/qemu-arm" # Gentoo
parted_boot=(fat32 2048s 264191s)
parted_root=(ext4 264192s 100%)
inittab="T1:12345:respawn:/sbin/agetty -L ttyS0 115200 vt100"
custmodules=()
# -- end settings --

# source common commands and add toolchain to PATH
source $common

${device_name}-build-kernel() {
	fn ${device_name}-build-kernel

	notice "Grabbing kernel sources"

	

	notice "Finished building kernel"
	notice "Next step is: ${device_name}-finalize"
}
