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
# ARM SDK build script for Acer Chromebook devices (armhf)

# -- settings --
device_name="chromeveyron"
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
image_name="${os}_${release}_${version}_${arch}_${device_name}"
# -- end settings --

${device_name}-build-kernel() {
	fn ${device_name}-build-kernel

	notice "Grabbing kernel sources"

	get-kernel-firmware
	cd ${workdir}
	sudo mkdir ${strapdir}/usr/src/kernel && sudo chown $USER ${strapdir}/usr/src/kernel
	git clone --depth 1 https://chromium.googlesource.com/chromiumos/third_party/kernel -b chromeos-3.14 ${strapdir}/usr/src/kernel

	copy-kernel-config

	# patching
	notice "Patching kernel..."
	patch -p1 --no-backup-if-mismatch < $R/arm/extra/patches/0001-UPSTREAM-soc-rockchip-add-handler-for-usb-uart-funct.patch
	patch -p1 --no-backup-if-mismatch < $R/arm/extra/patches/0002-fix-brcmfmac-oops-and-race-condition.patch

	make WIFIVERSION="-3.8" -j $(grep -c processor /proc/cpuinfo)
	make WIFIVERSION="-3.8" dtbs
	sudo mkdir -p ${strapdir}/lib/modules && sudo chown $USER ${strapdir}/lib/modules
	make WIFIVERSION="-3.8" modules_install INSTALL_MOD_PATH=${strapdir}
	sudo chown root ${strapdir}/lib/modules

# {{{ kernel-veyron.its
	cat << EOF | sudo tee ${strapdir}/usr/src/kernel/arch/arm/boot/kernel-veyron.its
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

	cd ${strapdir}/usr/src/kernel/arch/arm/boot
	mkimage -D "-I dts -O dtb -p 2048" -f kernel-veyron.its veyron-kernel

	# BEHOLD THE POWER OF PARTUUID/PARTNROFF
	print 'noinitrd console=tty1 quiet root=PARTUUID=%U/PARTNROFF=1 rootwait rw lsm.module_locking=0 net.ifnames=0 rootfstype=ext4' > cmdline

	sudo $DD if=/dev/zero of=bootloader.bin bs=512 count=1

	vbutil_kernel \
		--arch arm \
		--pack ${workdir}/kernel.bin \
		--keyblock /usr/share/vboot/devkeys/kernel.keyblock \
		--signprivate /usr/share/vboot/devkeys/kernel_data_key.vbprivk \
		--version 1 \
		--config cmdline \
		--bootloader bootloader.bin \
		--vmlinuz veyron-kernel

	cd ${strapdir}/usr/src/kernel

	make WIFIVERSION="-3.8" mrproper
	cp -v ../${device_name}.config .config
	make WIFIVERSION="-3.8" modules_prepare

	cd ${workdir}

	# hack to hide emmc from xfce
	cat << EOF | sudo tee ${strapdir}/etc/udev/rules.d/99-hide-emmc-partitions.rules
KERNEL=="mmcblk0*", ENV{UDISKS_IGNORE}="1"
EOF

	# proper audio config (with pulse)
	notice "Copying (pulse)audio config"
	sudo mkdir -p ${strapdir}/var/lib/alsa
	sudo cp -v $R/arm/extra/veyron-audio.cfg ${strapdir}/var/lib/alsa/asound.state
	sudo mkdir -p ${strapdir}/etc/pulse
	sudo cp -v $R/arm/extra/veyron-pulse.cfg ${strapdir}/etc/pulse/default.pa

	# mali rules so users can access the mali0 driver
	notice "Configuring mali0"
	cat << EOF | sudo tee ${strapdir}/etc/udev/rules.d/50-mali.rules
KERNEL=="mali0", MODE="0660", GROUP="video"
EOF

	# Video rules aka media-rules package in ChromeOS
	notice "Making video udev rules (media-rules)"
	cat << EOF | sudo tee ${strapdir}/etc/udev/rules.d/50-media.rules
ATTR{name}=="s5p-mfc-dec", SYMLINK+="video-dec"
ATTR{name}=="s5p-mfc-enc", SYMLINK+="video-enc"
ATTR{name}=="s5p-jpeg-dec", SYMLINK+="jpeg-dec"
ATTR{name}=="exynos-gsc.0*", SYMLINK+="image-proc0"
ATTR{name}=="exynos-gsc.1*", SYMLINK+="image-proc1"
ATTR{name}=="exynos-gsc.2*", SYMLINK+="image-proc2"
ATTR{name}=="exynos-gsc.3*", SYMLINK+="image-proc3"
ATTR{name}=="rk3288-vpu-dec", SYMLINK+="video-dec"
ATTR{name}=="rk3288-vpu-enc", SYMLINK+="video-enc"
ATTR{name}=="go2001-dec", SYMLINK+="video-dec"
ATTR{name}=="go2001-enc", SYMLINK+="video-enc"
ATTR{name}=="mt81xx-vcodec-dec", SYMLINK+="video-dec"
ATTR{name}=="mt81xx-vcodec-enc", SYMLINK+="video-enc"
ATTR{name}=="mt81xx-image-proc", SYMLINK+="image-proc0"
EOF

	# Touchpad config
	notice "Making touchpad config"
	sudo mkdir -p ${strapdir}/etc/X11/xorg.conf.d
	cat << EOF | sudo tee ${strapdir}/etc/X11/xorg.conf.d/10-synaptics-chromebook.conf
Section "InputClass"
	Identifier        "touchpad"
	MatchIsTouchpad   "on"
	Driver            "synaptics"
	Option            "TapButton1"    "1"
	Option            "TapButton2"	  "3"
	Option            "TapButton3"	  "2"
	Option            "FingerLow"	  "15"
	Option            "FingerHigh"	  "20"
	Option            "FingerPress"	  "256"
EndSection
EOF

	notice "Configuring firmware"
	sudo chown $USER ${strapdir}/lib
	act "Linux firmware..."
	cp -ra $R/tmp/firmware ${strapdir}/lib/firmware
	act "Broadcom firmware..."
	mkdir -p ${strapdir}/lib/firmware/brcm/
	cp -v $R/arm/extra/brcm/* ${strapdir}/lib/firmware/brcm/
	act "Elan firmware..."
	cp -v $R/arm/extra/elan* ${strapdir}/lib/firmware/
	act "Max firmware..."
	cp -v $R/arm/extra/max* ${strapdir}/lib/firmware/

	cd ${workdir}

	# We need to kick start the sdio chip to get bluetooth/wifi going. This is ugly
	# but bear with me
	sudo cp $R/arm/extra/bins/* ${strapdir}/usr/sbin/
	cat << EOF | sudo tee ${strapdir}/etc/udev/rules.d/80-brcm-sdio-added.rules
ACTION=="add", SUBSYSTEM=="sdio", ENV{SDIO_CLASS}=="02", ENV{SDIO_ID}=="02D0:4354", RUN+="/usr/sbin/brcm_patchram_plus -d --patchram /lib/firmware/brcm/BCM4354_003.001.012.0306.0659.hcd --no2bytes --enable_hci --enable_lpm --scopcm=1,2,0,1,1,0,0,0,0,0 --baudrate 3000000 --use_baudrate_for_download --tosleep=50000 /dev/ttyS0"
EOF

	cd ${workdir}

	sudo $DD if=${workdir}/kernel.bin of=${bootpart}

	notice "Finished building kernel"
	notice "Next step is: ${device_name}-finalize"
}
