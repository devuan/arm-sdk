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
# ARM SDK build script for Acer Chromebook devices (armhf)

# -- settings --
device_name="chromeacer"
arch="armhf"
size=1730
extra_packages=(wpasupplicant abootimg cgpt fake-hwclock u-boot-tools ntpdate)
extra_packages+=(vboot-utils vboot-kernel-utils)
extra_packages+=(laptop-mode-tools usbutils sudo vim)
# Ones below should not need changing
gpt=1
#parted_boot=(fat32 2048s 264191s)
#parted_root=(ext4 264192s 100%)
#inittab="T1:12345:respawn:/sbin/agetty -L ttyS0 115200 vt100"
custmodules=()
# source common commands
workdir="$R/arm/${device_name}-build"
strapdir="${workdir}/${os}-${arch}"
source $common
image_name="${os}-${release}-${version}-${arch}-${device_name}"
# -- end settings --

${device_name}-build-kernel() {
	fn ${device_name}-build-kernel

	notice "Grabbing kernel sources"

	get-kernel-firmware
	cd ${workdir}
	sudo mkdir ${strapdir}/usr/src/kernel && sudo chown $USER ${strapdir}/usr/src/kernel
	git clone --depth 1 https://chromium.googlesource.com/chromiumos/third_party/kernel -b chromeos-3.10 ${strapdir}/usr/src/kernel
	mkdir -p ${strapdir}/usr/src/kernel/firmware/nvidia/tegra124/

	copy-kernel-config

	sudo chown $USER ${strapdir}/lib
	cp -ra $R/tmp/firmware ${strapdir}/lib/firmware

	cp ${strapdir}/lib/firmware/nvidia/tegra124/xusb.bin firmware/nvidia/tegra124/

	make WIFIVERSION="-3.8" -j $(grep -c processor /proc/cpuinfo)
	make WIFIVERSION="-3.8" dtbs
	make WIFIVERSION="-3.8" modules_install INSTALL_MOD_PATH=${strapdir}

	cat << EOF | sudo tee ${strapdir}/usr/src/kernel/arch/arm/boot/kernel-nyan.its
/dts-v1/;
/ {
	description = "Chrome OS kernel image with one or more FDT blobs";
	#address-cells = <1>;
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
			description = "tegra124-nyan-big-rev0_2.dtb";
			data = /incbin/("dts/tegra124-nyan-big-rev0_2.dtb");
			type = "flat_dt";
			arch = "arm";
			compression = "none";
			hash@1{
				algo = "sha1";
			};
		};
		fdt@2{
			description = "tegra124-nyan-big-rev3_7.dtb";
			data = /incbin/("dts/tegra124-nyan-big-rev3_7.dtb");
			type = "flat_dt";
			arch = "arm";
			compression = "none";
			hash@1{
				algo = "sha1";
			};
		};
		fdt@3{
			description = "tegra124-nyan-big-rev8_9.dtb";
			data = /incbin/("dts/tegra124-nyan-big-rev8_9.dtb");
			type = "flat_dt";
			arch = "arm";
			compression = "none";
			hash@1{
				algo = "sha1";
			};
		};
		fdt@4{
			description = "tegra124-nyan-blaze.dtb";
			data = /incbin/("dts/tegra124-nyan-blaze.dtb");
			type = "flat_dt";
			arch = "arm";
			compression = "none";
			hash@1{
				algo = "sha1";
			};
		};
		fdt@5{
			description = "tegra124-nyan-rev0.dtb";
			data = /incbin/("dts/tegra124-nyan-rev0.dtb");
			type = "flat_dt";
			arch = "arm";
			compression = "none";
			hash@1{
				algo = "sha1";
			};
		};
		fdt@6{
			description = "tegra124-nyan-rev1.dtb";
			data = /incbin/("dts/tegra124-nyan-rev1.dtb");
			type = "flat_dt";
			arch = "arm";
			compression = "none";
			hash@1{
				algo = "sha1";
			};
		};
		fdt@7{
			description = "tegra124-nyan-kitty-rev0_3.dtb";
			data = /incbin/("dts/tegra124-nyan-kitty-rev0_3.dtb");
			type = "flat_dt";
			arch = "arm";
			compression = "none";
			hash@1{
				algo = "sha1";
			};
		};
		fdt@8{
			description = "tegra124-nyan-kitty-rev8.dtb";
			data = /incbin/("dts/tegra124-nyan-kitty-rev8.dtb");
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
	};
};
EOF

	cd ${strapdir}/usr/src/kernel/arch/arm/boot
	mkimage -f kernel-nyan.its nyan-big-kernel

	# BEHOLD THE POWER OF PARTUUID/PARTNROFF
	print "noinitrd console=tty1 quiet root=PARTUUID=%U/PARTNROFF=1 rootwait rw lsm.module_locking=0 net.ifnames=0 rootfstype=ext4" > cmdline

	sudo $DD if=/dev/zero of=bootloader.bin bs=512 count=1

	vbutil_kernel --arch arm --pack ${workdir}/kernel.bin \
		--keyblock /usr/share/vboot/devkeys/kernel.keyblock \
		--signprivate /usr/share/vboot/devkeys/kernel_data_key.vbprivk \
		--version 1 \
		--config cmdline \
		--bootloader bootloader.bin \
		--vmlinuz nyan-big-kernel

	cd ${strapdir}/usr/src/kernel

	make WIFIVERSION="-3.8" mrproper
	cp -v ../${device_name}.config .config
	make WIFIVERSION="-3.8" modules_prepare

	cd ${workdir}

	# lid switch
	cat << EOF | sudo tee ${strapdir}/etc/udev/rules.d/99-tegra-lid-switch.rules
ACTION=="remove", GOTO="tegra_lid_switch_end"
SUBSYSTEM=="input", KERNEL=="event*", SUBSYSTEMS=="platform", KERNELS=="gpio-keys.4", TAG+="power-switch"
LABEL="tegra_lid_switch_end"
EOF

	# hack
	cat << EOF | sudo tee ${strapdir}/etc/udev/rules.d/99-hide-emmc-partitions.rules
KERNEL=="mmcblk0*", ENV{UDISKS_IGNORE}="1"
EOF

	# nvidia device nodes
	cat << EOF | sudo tee ${strapdir}/lib/udev/rules.d/51-nvrm.rules
KERNEL=="knvmap", GROUP="video", MODE="0660"
KERNEL=="nvhdcp1", GROUP="video", MODE="0660"
KERNEL=="nvhost-as-gpu", GROUP="video", MODE="0660"
KERNEL=="nvhost-ctrl", GROUP="video", MODE="0660"
KERNEL=="nvhost-ctrl-gpu", GROUP="video", MODE="0660"
KERNEL=="nvhost-dbg-gpu", GROUP="video", MODE="0660"
KERNEL=="nvhost-gpu", GROUP="video", MODE="0660"
KERNEL=="nvhost-msenc", GROUP="video", MODE=0660"
KERNEL=="nvhost-prof-gpu", GROUP="video", MODE=0660"
KERNEL=="nvhost-tsec", GROUP="video", MODE="0660"
KERNEL=="nvhost-vic", GROUP="video", MODE="0660"
KERNEL=="nvmap", GROUP="video", MODE="0660"
KERNEL=="tegra_dc_0", GROUP="video", MODE="0660"
KERNEL=="tegra_dc_1", GROUP="video", MODE="0660"
KERNEL=="tegra_dc_ctrl", GROUP="video", MODE="0660"
EOF

	sudo mkdir -p ${strapdir}/etc/X11/xorg.conf.d
	cat <<EOF | sudo tee ${strapdir}/etc/X11/xorg.conf.d/10-synaptics-chromebook.conf
Section "InputClass"
	Identifier "touchpad"
	MatchIsTouchpad "on"
	Driver "synaptics"
	Option "TapButton1"    "1"
	Option "TapButton2"    "3"
	Option "TapButton3"    "2"
	Option "FingerLow"     "15"
	Option "FingerHigh"    "20"
	Option "FingerPress"   "256"
EndSection
EOF

	cd ${workdir}
	notice "Getting some coreboot stuff"
	git clone https://chromium.googlesource.com/chromiumos/third_party/coreboot
	cd ${workdir}/coreboot
	git checkout 071167b667685c26106641e6899984c7bd91e84b

	make -C src/soc/nvidia/tegra124/lp0 GCC_PREFIX=${compiler}
	mkdir -p ${strapdir}/lib/firmware/tegra12x
	cp -v src/soc/nvidia/tegra124/lp0/tegra_lp0_resume.fw ${strapdir}/lib/firmware/tegra12x/

	cd ${workdir}

	sudo $DD if=${workdir}/kernel.bin of=${bootpart}

	notice "Finished building kernel"
	notice "Next step is: ${device_name}-finalize"
}
