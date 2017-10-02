#!/usr/bin/env zsh
# Copyright (c) 2017 Johny Mattsson <johny.mattsson+github@gmail.com>
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

## kernel build script for Rock64 boards

vars+=(device_name arch size inittab parted_type gpt_boot gpt_root bootfs)
vars+=(gitkernel gitbranch)

device_name="rock64"
arch="arm64"
size=1891
inittab=("T1:12345:respawn:/sbin/agetty -L ttyS2 1500000 vt100")

# There's a lot of reserved areas at the start, see:
#   http://opensource.rock-chips.com/wiki_Partitions
parted_type="gpt"
gpt_boot=(32768 229376)
gpt_root=(262144)
bootfs="vfat"

gitkernel=mainline
gitbranch="linux-4.14-rc2"

# Mainline u-boot does not yet have full Rock64 support, so have to fetch this
rock64uboot=https://github.com/ayufan-rock64/linux-u-boot.git
rock64ubootbr=mainline-master
rock64ubootdir="$R/tmp/u-boot/${device_name}-u-boot"
# Likewise, no u-boot SPL support for the 3288 yet, so need binary loader
rkbin=https://github.com/rockchip-linux/rkbin
rkbindir="$R/tmp/rkbin"

expr "${qemu_bin}" : ".*aarch.*" >/dev/null || {
  error "qemu_bin needs to be arm64 variety (a.k.a. aarch, aarch64)"
  return 1
}

expr "${compiler}" : ".*aarch64.*" >/dev/null || {
  error "compiler needs to be arm64 variety (a.k.a. aarch64)"
  return 1
}

get_rock64_uboot_sources() {
	fn get_rock64_uboot_sources
	req=(rock64uboot rock64ubootdir rock64ubootbr)
	ckreq || return 1

	clone-git "${rock64uboot}" "${rock64ubootdir}" "${rock64ubootbr}"
}

get_rkbin() {
	fn get_rkbin
	req=(rkbin rkbindir)
	ckreq || return 1

	clone-git "${rkbin}" "${rkbindir}"
}

build_uboot_rock64() {
	fn build_uboot_rock64
	req=(rock64ubootdir rock64ubootbuild compiler MAKEOPTS)
	ckreq || return 1

	notice "building u-boot for Rock64"
	pushd "${rock64ubootdir}"
		make O="${rock64ubootbuild}" distclean
		make $MAKEOPTS \
			ARCH=arm CROSS_COMPILE=$compiler \
			O="${rock64ubootbuild}" rock64-rk3328_defconfig || zerr
		make $MAKEOPTS \
			ARCH=arm CROSS_COMPILE=$compiler \
			O="${rock64ubootbuild}" all || zerr
	popd
}

build_loader_rock64() {
	fn build_loader_rock64
	req=(rkbindir rock64ubootbuild)
	ckreq || return 1

	notice "assembling loader images"
	pushd "${rock64ubootbuild}"
		act "creating idbloader.img"
		dd if="${rkbindir}/rk33/rk3328_ddr_786MHz_v1.06.bin" of=ddr.bin bs=4 skip=1 status=none || zerr
		tools/mkimage -n rk3328 -T rksd -d ddr.bin idbloader.img || zerr
		rm -f ddr.bin
		cat "${rkbindir}/rk33/rk3328_miniloader_v2.43.bin" >> idbloader.img

		act "repacking u-boot for idbloader into uboot.img"
		"${rkbindir}/tools/loaderimage" --pack --uboot u-boot-dtb.bin uboot.img 0x200000 || zerr

		act "generating trust.img"
		cat > trust.ini <<EOF
[VERSION]
MAJOR=1
MINOR=2
[BL30_OPTION]
SEC=0
[BL31_OPTION]
SEC=1
PATH=${rkbindir}/rk33/rk3328_bl31_v1.34.bin
ADDR=0x10000
[BL32_OPTION]
SEC=0
[BL33_OPTION]
SEC=0
[OUTPUT]
PATH=trust.img
EOF
		"${rkbindir}/tools/trust_merger" trust.ini
	popd
}

prebuild() {
	fn prebuild
    req=(device_name strapdir)
    ckreq || return 1

    notice "executing $device_name prebuild"

	copy-root-overlay

	cat << EOF | sudo tee -a "${strapdir}/etc/motd"

To expand the root partition, run:
  parted /dev/mmcblk0 resizepart 2 100%
  resize2fs /dev/mmcblk0p2

EOF

	mkdir -p "$R/tmp/kernels/${device_name}"
}

postbuild() {
    fn postbuild
	req=(strapdir loopdevice)
	ckreq || return 1

    notice "executing $device_name postbuild"

	rock64ubootbuild="${workdir}/${device_name}-build-u-boot"

	get_rock64_uboot_sources || zerr
	get_rkbin || zerr

	build_uboot_rock64 || zerr
	build_loader_rock64 || zerr

	notice "dd'ing loaders to the image"
	pushd "${rock64ubootbuild}"
		sudo dd if=idbloader.img bs=512 seek=64 of="${loopdevice}" status=none conv=notrunc || zerr
		sudo dd if=uboot.img bs=512 seek=16384 of="${loopdevice}" status=none conv=notrunc || zerr
		sudo dd if=trust.img bs=512 seek=24576 of="${loopdevice}" status=none conv=notrunc || zerr
    popd

	notice "touching up partition names and flags"
	sudo parted -s "${loopdevice}" name 1 "boot" || zerr
	sudo parted -s "${loopdevice}" name 2 "root" || zerr
	sudo parted -s "${loopdevice}" set 1 legacy_boot on || zerr
	sudo parted -s "${loopdevice}" set 2 msftdata off || zerr

	notice "setting up extlinux.conf"
	sudo mkdir -p "${strapdir}/boot/extlinux"
	cat << EOF | sudo tee "${strapdir}/boot/extlinux/extlinux.conf" >/dev/null
label main
	kernel /Image
	fdt /dtbs/rk3328-rock64.dtb
	append earlycon=uart8250,mmio32,0xff130000 coherent_pool=1M ethaddr=\${ethaddr} eth1addr=\${eth1addr} serial=\${serial#} rw root=/dev/mmcblk0p2 rootwait
EOF

    postbuild-clean
}

build_kernel_arm64() {
    fn build_kernel_arm64
    req=(R arch device_name gitkernel gitbranch MAKEOPTS)
    req+=(strapdir ubootmainline)
    req+=(loopdevice)
    ckreq || return 1

    notice "building $arch kernel"

    prebuild || zerr

    get-kernel-sources
    pushd "$R/tmp/kernels/${device_name}/${device_name}-linux"
        copy-kernel-config

        make \
			$MAKEOPTS \
            ARCH=arm64 \
			CROSS_COMPILE=$compiler \
				Image dtbs modules || zerr
        sudo -E PATH="$PATH" \
            make \
				$MAKEOPTS \
				ARCH=arm64 \
				CROSS_COMPILE=$compiler \
				INSTALL_MOD_PATH="$strapdir" \
					modules_install || zerr

        sudo cp -v arch/arm64/boot/Image "${strapdir}/boot/" || zerr
		sudo mkdir -p "${strapdir}/boot/dtbs"
		dtb="rk3328-rock64.dtb"
		sudo cp -v arch/arm64/boot/dts/rockchip/${dtb} "${strapdir}/boot/dtbs/" || zerr
    popd

    postbuild || zerr
}
