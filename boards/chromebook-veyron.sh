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

## kernel build script for Acer Chromebook boards

## settings & config
vars+=(device_name arch size parted_type)
vars+=(gitkernel gitbranch)
arrs+=(custmodules)
arrs+=(gpt_root gpt_boot bootfs)

device_name="chromeveyron"
arch="armhf"
size=1730
#inittab=""

parted_type="gpt"
bootpart="vfat"
rootpart="ext4"
gpt_boot=(8192 32768)
gpt_root=(40960)
bootfs="none"

extra_packages+=(abootimg cgpt u-boot-tools)
extra_packages+=(vboot-utils vboot-kernel-utils)
extra_packages+=(laptop-mode-tools usbutils)
custmodules=()

gitkernel="https://chromium.googlesource.com/chromiumos/third_party/kernel"
gitbranch="chromeos-3.14"


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

	sudo dd if=$workdir/kernel.bin of=$bootpart || { die "unable to dd to $bootpart"; zerr }

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

		notice "patching kernel"
		for i in $R/extra/patches/linux-chromeveyron-patches/*.patch ; do
			patch -p1 < "$i"
		done

		#WIFIVERSION="-3.8" make multi_v7_defconfig || zerr
		copy-kernel-config
		make \
			$MAKEOPTS \
			ARCH=arm \
			CROSS_COMPILE=$compiler \
			WIFIVERSION="-3.8"
		make \
			$MAKEOPTS \
			ARCH=arm \
			CROSS_COMPILE=$compiler \
			WIFIVERSION="-3.8" \
				dtbs || zerr
		sudo -E PATH="$PATH" \
			make \
				ARCH=arm \
				CROSS_COMPILE=$compiler \
				WIFIVERSION="-3.8" \
				INSTALL_MOD_PATH=$strapdir \
					modules_install || zerr
	popd

	#sudo rm -rf $strapdir/lib/firmware
	#get-kernel-firmware
	#sudo cp -rav $R/tmp/linux-firmware $strapdir/lib/firmware

	pushd $R/tmp/kernels/$device_name/${device_name}-linux/arch/arm/boot
# {{{ kernel-veyron.its
	cat << EOF | sudo tee kernel-veyron.its >/dev/null
/dts-v1/;
/ {
	description = "Chrome OS kernel image with one or more FDT blobs";
	images {
		kernel@1{
			description = "kernel";
			data = /incbin/("zImage");
			type = "kernel_noload";
			arch = "arm";
			os = "linux";
			compression = "none";
			load = <0>;
			entry = <0>;
		};
		fdt@1{
			description = "rk3288-brain-rev0.dtb";
			data = /incbin/("dts/rk3288-brain-rev0.dtb");
			type = "flat_dt";
			arch = "arm";
			compression = "none";
			hash@1{
				algo = "sha1";
			};
		};
		fdt@2{
			description = "rk3288-jaq-rev1.dtb";
			data = /incbin/("dts/rk3288-jaq-rev1.dtb");
			type = "flat_dt";
			arch = "arm";
			compression = "none";
			hash@1{
				algo = "sha1";
			};
		};
		fdt@3{
			description = "rk3288-nicky-rev0.dtb";
			data = /incbin/("dts/rk3288-nicky-rev0.dtb");
			type = "flat_dt";
			arch = "arm";
			compression = "none";
			hash@1{
				algo = "sha1";
			};
		};
		fdt@4{
			description = "rk3288-danger-rev0.dtb";
			data = /incbin/("dts/rk3288-danger-rev0.dtb");
			type = "flat_dt";
			arch = "arm";
			compression = "none";
			hash@1{
				algo = "sha1";
			};
		};
		fdt@5{
			description = "rk3288-jerry-rev2.dtb";
			data = /incbin/("dts/rk3288-jerry-rev2.dtb");
			type = "flat_dt";
			arch = "arm";
			compression = "none";
			hash@1{
				algo = "sha1";
			};
		};
		fdt@6{
			description = "rk3288-rialto-rev0.dtb";
			data = /incbin/("dts/rk3288-rialto-rev0.dtb");
			type = "flat_dt";
			arch = "arm";
			compression = "none";
			hash@1{
				algo = "sha1";
			};
		};
		fdt@7{
			description = "rk3288-danger-rev1.dtb";
			data = /incbin/("dts/rk3288-danger-rev1.dtb");
			type = "flat_dt";
			arch = "arm";
			compression = "none";
			hash@1{
				algo = "sha1";
			};
		};
		fdt@8{
			description = "rk3288-jerry-rev3.dtb";
			data = /incbin/("dts/rk3288-jerry-rev3.dtb");
			type = "flat_dt";
			arch = "arm";
			compression = "none";
			hash@1{
				algo = "sha1";
			};
		};
		fdt@9{
			description = "rk3288-speedy.dtb";
			data = /incbin/("dts/rk3288-speedy.dtb");
			type = "flat_dt";
			arch = "arm";
			compression = "none";
			hash@1{
				algo = "sha1";
			};
		};
		fdt@10{
			description = "rk3288-evb-act8846.dtb";
			data = /incbin/("dts/rk3288-evb-act8846.dtb");
			type = "flat_dt";
			arch = "arm";
			compression = "none";
			hash@1{
				algo = "sha1";
			};
		};
		fdt@11{
			description = "rk3288-mickey-rev0.dtb";
			data = /incbin/("dts/rk3288-mickey-rev0.dtb");
			type = "flat_dt";
			arch = "arm";
			compression = "none";
			hash@1{
				algo = "sha1";
			};
		};
		fdt@12{
			description = "rk3288-speedy-rev1.dtb";
			data = /incbin/("dts/rk3288-speedy-rev1.dtb");
			type = "flat_dt";
			arch = "arm";
			compression = "none";
			hash@1{
				algo = "sha1";
			};
		};
		fdt@13{
			description = "rk3288-evb-rk808.dtb";
			data = /incbin/("dts/rk3288-evb-rk808.dtb");
			type = "flat_dt";
			arch = "arm";
			compression = "none";
			hash@1{
				algo = "sha1";
			};
		};
		fdt@14{
			description = "rk3288-mighty-rev1.dtb";
			data = /incbin/("dts/rk3288-mighty-rev1.dtb");
			type = "flat_dt";
			arch = "arm";
			compression = "none";
			hash@1{
				algo = "sha1";
			};
		};
		fdt@15{
			description = "rk3288-thea-rev0.dtb";
			data = /incbin/("dts/rk3288-thea-rev0.dtb");
			type = "flat_dt";
			arch = "arm";
			compression = "none";
			hash@1{
				algo = "sha1";
			};
		};
		fdt@16{
			description = "rk3288-gus-rev1.dtb";
			data = /incbin/("dts/rk3288-gus-rev1.dtb");
			type = "flat_dt";
			arch = "arm";
			compression = "none";
			hash@1{
				algo = "sha1";
			};
		};
		fdt@17{
			description = "rk3288-minnie-rev0.dtb";
			data = /incbin/("dts/rk3288-minnie-rev0.dtb");
			type = "flat_dt";
			arch = "arm";
			compression = "none";
			hash@1{
				algo = "sha1";
			};
		};

	};
	configurations {
		default = "conf@1";
		conf@1{
			kernel = "kernel@1";
			fdt = "fdt@1";
		};
		conf@2{
			kernel = "kernel@1";
			fdt = "fdt@2";
		};
		conf@3{
			kernel = "kernel@1";
			fdt = "fdt@3";
		};
		conf@4{
			kernel = "kernel@1";
			fdt = "fdt@4";
		};
		conf@5{
			kernel = "kernel@1";
			fdt = "fdt@5";
		};
		conf@6{
			kernel = "kernel@1";
			fdt = "fdt@6";
		};
		conf@7{
			kernel = "kernel@1";
			fdt = "fdt@7";
		};
		conf@8{
			kernel = "kernel@1";
			fdt = "fdt@8";
		};
		conf@9{
			kernel = "kernel@1";
			fdt = "fdt@9";
		};
		conf@10{
			kernel = "kernel@1";
			fdt = "fdt@10";
		};
		conf@11{
			kernel = "kernel@1";
			fdt = "fdt@11";
		};
		conf@12{
			kernel = "kernel@1";
			fdt = "fdt@12";
		};
		conf@13{
			kernel = "kernel@1:";
			fdt = "fdt@13";
		};
		conf@14{
			kernel = "kernel@1";
			fdt = "fdt@14";
		};
		conf@15{
			kernel = "kernel@1";
			fdt = "fdt@15";
		};
		conf@16{
			kernel = "kernel@1";
			fdt = "fdt@16";
		};
		conf@17{
			kernel = "kernel@1";
			fdt = "fdt@17";
		};
	};
};
EOF
# }}}
	notice "making veyron-kernel image"
	mkimage -D "-I dts -O dtb -p 2048" -f kernel-veyron.its veyron-kernel || zerr

	## BEHOLD THE POWER OF PARTUUID/PARTNROFF
	print "noinitrd console=tty1 quiet root=PARTUUID=%U/PARTNROFF=1 rootwait rw lsm.module_locking=0 net.ifnames=0 rootfstype=ext4" > cmdline

	sudo dd if=/dev/zero of=bootloader.bin bs=512 count=1 || { die "unable to dd bootloader"; zerr }

	vbutil_kernel \
		--arch arm \
		--pack $workdir/kernel.bin \
		--keyblock /usr/share/vboot/devkeys/kernel.keyblock \
		--signprivate /usr/share/vboot/devkeys/kernel_data_key.vbprivk \
		--version 1 \
		--config cmdline \
		--bootloader bootloader.bin \
		--vmlinuz veyron-kernel || zerr
	popd

	pushd $R/tmp/kernels/$device_name/${device_name}-linux
		make mrproper
		#WIFIVERSION="-3.8" make multi_v7_defconfig || zerr
		copy-kernel-config
		sudo -E PATH="$PATH" \
			make \
				$MAKEOPTS \
				ARCH=arm \
				CROSS_COMPILE=$compiler \
				WIFIVERSION="-3.8" \
					modules_prepare || zerr
	popd

	postbuild || zerr
}
