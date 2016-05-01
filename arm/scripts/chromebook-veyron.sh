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

# {{{ pulseaudio
	# proper audio with pulse
	sudo mkdir -p ${strapdir}/var/lib/alsa/
	cat << EOF | sudo tee ${strapdir}/var/lib/alsa/asound.state
state.ROCKCHIPI2S {
	control.1 {
		iface MIXER
		name 'MIC Bias VCM Bandgap'
		value 'High Performance'
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 'Low Power'
			item.1 'High Performance'
		}
	}
	control.2 {
		iface MIXER
		name 'DMIC MIC Comp Filter Config'
		value 6
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 15'
		}
	}
	control.3 {
		iface MIXER
		name 'MIC1 Boost Volume'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 2'
			dbmin 0
			dbmax 3000
			dbvalue.0 0
		}
	}
	control.4 {
		iface MIXER
		name 'MIC2 Boost Volume'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 2'
			dbmin 0
			dbmax 3000
			dbvalue.0 0
		}
	}
	control.5 {
		iface MIXER
		name 'MIC1 Volume'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 20'
			dbmin 0
			dbmax 2000
			dbvalue.0 0
		}
	}
	control.6 {
		iface MIXER
		name 'MIC2 Volume'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 20'
			dbmin 0
			dbmax 2000
			dbvalue.0 0
		}
	}
	control.7 {
		iface MIXER
		name 'LINEA Single Ended Volume'
		value 1
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 1'
			dbmin -600
			dbmax 0
			dbvalue.0 0
		}
	}
	control.8 {
		iface MIXER
		name 'LINEB Single Ended Volume'
		value 1
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 1'
			dbmin -600
			dbmax 0
			dbvalue.0 0
		}
	}
	control.9 {
		iface MIXER
		name 'LINEA Volume'
		value 2
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 5'
			dbmin -600
			dbmax 2000
			dbvalue.0 0
		}
	}
	control.10 {
		iface MIXER
		name 'LINEB Volume'
		value 2
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 5'
			dbmin -600
			dbmax 2000
			dbvalue.0 0
		}
	}
	control.11 {
		iface MIXER
		name 'LINEA Ext Resistor Gain Mode'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.12 {
		iface MIXER
		name 'LINEB Ext Resistor Gain Mode'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.13 {
		iface MIXER
		name 'ADCL Boost Volume'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 7'
			dbmin 0
			dbmax 4200
			dbvalue.0 0
		}
	}
	control.14 {
		iface MIXER
		name 'ADCR Boost Volume'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 7'
			dbmin 0
			dbmax 4200
			dbvalue.0 0
		}
	}
	control.15 {
		iface MIXER
		name 'ADCL Volume'
		value 12
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 15'
			dbmin -1200
			dbmax 300
			dbvalue.0 0
		}
	}
	control.16 {
		iface MIXER
		name 'ADCR Volume'
		value 12
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 15'
			dbmin -1200
			dbmax 300
			dbvalue.0 0
		}
	}
	control.17 {
		iface MIXER
		name 'ADC Oversampling Rate'
		value '128*fs'
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 '64*fs'
			item.1 '128*fs'
		}
	}
	control.18 {
		iface MIXER
		name 'ADC Quantizer Dither'
		value true
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.19 {
		iface MIXER
		name 'ADC High Performance Mode'
		value 'High Performance'
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 'Low Power'
			item.1 'High Performance'
		}
	}
	control.20 {
		iface MIXER
		name 'DAC Mono Mode'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
			}
		}
	control.21 {
		iface MIXER
		name 'SDIN Mode'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.22 {
		iface MIXER
		name 'SDOUT Mode'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.23 {
		iface MIXER
		name 'SDOUT Hi-Z Mode'
		value true
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.24 {
		iface MIXER
		name 'Filter Mode'
		value Music
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 Voice
			item.1 Music
		}
	}
	control.25 {
		iface MIXER
		name 'Record Path DC Blocking'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.26 {
		iface MIXER
		name 'Playback Path DC Blocking'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.27 {
		iface MIXER
		name 'Digital BQ Volume'
		value 15
		comment {
			access 'read write'
			type INTEGER
			rount 1
			range '0 - 15'
			dbmin -1500
			dbmax 0
			dbvalue.0 0
		}
	}
	control.28 {
		iface MIXER
		name 'Digital Sidetone Volume'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 30'
			dbmin 0
			dbmax 3000
			dbvalue.0 0
		}
	}
	control.29 {
		iface MIXER
		name 'Digital Coarse Volume'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 3'
			dbmin 0
			dbmax 1800
			dbvalue.0 0
		}
	}
	control.30 {
		iface MIXER
		name 'Digital Volume'
		value 15
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 15'
			dbmin -1500
			dbmax 0
			dbvalue.0 0
		}
	}
	control.31 {
		iface MIXER
		name 'EQ Coefficients'
		value '000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'
		comment {
			access 'read write'
			type BYTES
			count 105
		}
	}
	control.32 {
		iface MIXER
		name 'Digital EQ 3 Band Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.33 {
		iface MIXER
		name 'Digital EQ 5 Band Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.34 {
		iface MIXER
		name 'Digital EQ 7 Band Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.35 {
		iface MIXER
		name 'Digital EQ Clipping Detection'
		value true
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.36 {
		iface MIXER
		name 'Digital EQ Volume'
		value 15
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 15'
			dbmin -1500
			dbmax 0
			dbvalue.0 0
		}
	}
	control.37 {
		iface MIXER
		name 'ALC Enable'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.38 {
		iface MIXER
		name 'ALC Attack Time'
		value '0.5ms'
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 '0.5ms'
			item.1 '1ms'
			item.2 '5ms'
			item.3 '10ms'
			item.4 '25ms'
			item.5 '50ms'
			item.6 '100ms'
			item.7 '200ms'
		}
	}
	control.39 {
		iface MIXER
		name 'ALC Release Time'
		value '8s'
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 '8s'
			item.1 '4s'
			item.2 '2s'
			item.3 '1s'
			item.4 '0.5s'
			item.5 '0.25s'
			item.6 '0.125s'
			item.7 '0.0625s'
		}
	}
	control.40 {
		iface MIXER
		name 'ALC Make Up Volume'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 12'
			dbmin 0
			dbmax 1200
			dbvalue.0 0
		}
	}
	control.41 {
		iface MIXER
		name 'ALC Compression Ratio'
		value '1:1'
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 '1:1'
			item.1 '1:1.5'
			item.2 '1:2'
			item.3 '1:4'
			item.4 '1:INF'
		}
	}
	control.42 {
		iface MIXER
		name 'ALC Expansion Ratio'
		value '1:1'
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 '1:1'
			item.1 '2:1'
			item.2 '3:1'
		}
	}
	control.43 {
		iface MIXER
		name 'ALC Compression Threshold Volume'
		value 31
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 31'
			dbmin -3100
			dbmax 0
			dbvalue.0 0
		}
	}
	control.44 {
		iface MIXER
		name 'ALC Expansion Threshold Volume'
		value 31
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 31'
			dbmin -6600
			dbmax -3500
			dbvalue.0 -3500
		}
	}
	control.45 {
		iface MIXER
		name 'DAC HP Playback Performance Mode'
		value 'High Performance'
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 'High Performance'
			item.1 'Low Power'
		}
	}
	control.46 {
		iface MIXER
		name 'DAC High Performance Mode'
		value 'High Performance'
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 'Low Power'
			item.1 'High Performance'
		}
	}
	control.47 {
		iface MIXER
		name 'Headphone Left Mixer Volume'
		value 3
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 3'
			dbmin -1200
			dbmax 0
			dbvalue.0 0
		}
	}
	control.48 {
		iface MIXER
		name 'Headphone Right Mixer Volume'
		value 3
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 3'
			dbmin -1200
			dbmax 0
			dbvalue.0 0
		}
	}
	control.49 {
		iface MIXER
		name 'Speaker Left Mixer Volume'
		value 3
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 3'
			dbmin -1200
			dbmax 0
			dbvalue.0 0
		}
	}
	control.50 {
		iface MIXER
		name 'Speaker Right Mixer Volume'
		value 3
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 3'
			dbmin -1200
			dbmax 0
			dbvalue.0 0
		}
	}
	control.51 {
		iface MIXER
		name 'Receiver Left Mixer Volume'
		value 3
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 3'
			dbmin -1200
			dbmax 0
			dbvalue.0 0
		}
	}
	control.52 {
		iface MIXER
		name 'Receiver Right Mixer Volume'
		value 3
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 3'
			dbmin -1200
			dbmax 0
			dbvalue.0 0
		}
	}
	control.53 {
		iface MIXER
		name 'Headphone Volume'
		value.0 0
		value.1 0
		comment {
			access 'read write'
			type INTEGER
			count 2
			range '0 - 31'
			dbmin -6700
			dbmax 300
			dbvalue.0 -6700
			dbvalue.1 -6700
		}
	}
	control.54 {
		iface MIXER
		name 'Speaker Volume'
		value.0 39
		value.1 39
		comment {
			access 'read write'
			type INTEGER
			count 2
			range '0 - 39'
			dbmin -4800
			dbmax 1400
			dbvalue.0 1400
			dbvalue.1 1400
		}
	}
	control.55 {
		iface MIXER
		name 'Receiver Volume'
		value.0 21
		value.1 21
		comment {
			access 'read write'
			type INTEGER
			count 2
			range '0 - 31'
			dbmin -6200
			dbmax 800
			dbvalue.0 0
			dbvalue.1 0
		}
	}
	control.56 {
		iface MIXER
		name 'Headphone Left Switch'
		value true
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.57 {
		iface MIXER
		name 'Headphone Right Switch'
		value true
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.58 {
		iface MIXER
		name 'Speaker Left Switch'
		value true
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.59 {
		iface MIXER
		name 'Speaker Right Switch'
		value true
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.60 {
		iface MIXER
		name 'Receiver Left Switch'
		value true
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.61 {
		iface MIXER
		name 'Receiver Right Switch'
		value true
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.62 {
		iface MIXER
		name 'Zero-Crossing Detection'
		value true
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.63 {
		iface MIXER
		name 'Enhanced Vol Smoothing'
		value true
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.64 {
		iface MIXER
		name 'Volume Adjustment Smoothing'
		value true
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.65 {
		iface MIXER
		name 'Biquad Coefficients'
		value '000000000000000000000000000000'
		comment {
			access 'read write'
			type BYTES
			count 15
		}
	}
	control.66 {
		iface MIXER
		name 'Biquad Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.67 {
		iface MIXER
		name 'Headphone Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.68 {
		iface MIXER
		name 'Headset Mic Switch'
		value true
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.69 {
		iface MIXER
		name 'Int Mic Switch'
		value true
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.70 {
		iface MIXER
		name 'Speaker Switch'
		value true
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.71 {
		iface MIXER
		name 'MIXHPRSEL Mux'
		value 'DAC Only'
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 'DAC Only'
			item.1 'HP Mixer'
		}
	}
	control.72 {
	iface MIXER
		name 'MIXHPLSEL Mux'
		value 'DAC Only'
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 'DAC Only'
			item.1 'HP Mixer'
		}
	}
	control.73 {
		iface MIXER
		name 'LINMOD Mux'
		value 'Left Only'
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 'Left Only'
			item.1 'Left and Right'
		}
	}
	control.74 {
		iface MIXER
		name 'Right Receiver Mixer Left DAC Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.75 {
		iface MIXER
		name 'Right Receiver Mixer Right DAC Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.76 {
		iface MIXER
		name 'Right Receiver Mixer LINEA Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.77 {
		iface MIXER
		name 'Right Receiver Mixer LINEB Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.78 {
		iface MIXER
		name 'Right Receiver Mixer MIC1 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.79 {
		iface MIXER
		name 'Right Receiver Mixer MIC2 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.80 {
		iface MIXER
		name 'Left Receiver Mixer Left DAC Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.81 {
		iface MIXER
		name 'Left Receiver Mixer Right DAC Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.82 {
		iface MIXER
		name 'Left Receiver Mixer LINEA Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.83 {
		iface MIXER
		name 'Left Receiver Mixer LINEB Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.84 {
		iface MIXER
		name 'Left Receiver Mixer MIC1 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.85 {
		iface MIXER
		name 'Left Receiver Mixer MIC2 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.86 {
		iface MIXER
		name 'Right Speaker Mixer Left DAC Switch'
		value true
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.87 {
		iface MIXER
		name 'Right Speaker Mixer Right DAC Switch'
		value true
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.88 {
		iface MIXER
		name 'Right Speaker Mixer LINEA Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.89 {
		iface MIXER
		name 'Right Speaker Mixer LINEB Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.90 {
		iface MIXER
		name 'Right Speaker Mixer MIC1 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.91 {
		iface MIXER
		name 'Right Speaker Mixer MIC2 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.92 {
		iface MIXER
		name 'Left Speaker Mixer Left DAC Switch'
		value true
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.93 {
		iface MIXER
		name 'Left Speaker Mixer Right DAC Switch'
		value true
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.94 {
		iface MIXER
		name 'Left Speaker Mixer LINEA Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.95 {
		iface MIXER
		name 'Left Speaker Mixer LINEB Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.96 {
		iface MIXER
		name 'Left Speaker Mixer MIC1 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.97 {
		iface MIXER
		name 'Left Speaker Mixer MIC2 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.98 {
		iface MIXER
		name 'Right Headphone Mixer Left DAC Switch'
		value true
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.99 {
		iface MIXER
		name 'Right Headphone Mixer Right DAC Switch'
		value true
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.100 {
		iface MIXER
		name 'Right Headphone Mixer LINEA Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.101 {
		iface MIXER
		name 'Right Headphone Mixer LINEB Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.102 {
		iface MIXER
		name 'Right Headphone Mixer MIC1 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.103 {
		iface MIXER
		name 'Right Headphone Mixer MIC2 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.104 {
		iface MIXER
		name 'Left Headphone Mixer Left DAC Switch'
		value true
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.105 {
		iface MIXER
		name 'Left Headphone Mixer Right DAC Switch'
		value true
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.106 {
		iface MIXER
		name 'Left Headphone Mixer LINEA Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.107 {
		iface MIXER
		name 'Left Headphone Mixer LINEB Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.108 {
		iface MIXER
		name 'Left Headphone Mixer MIC1 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.109 {
		iface MIXER
		name 'Left Headphone Mixer MIC2 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.110 {
		iface MIXER
		name 'STENR Mux'
		value Normal
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 Normal
			item.1 'Sidetone Right'
		}
	}
	control.111 {
		iface MIXER
		name 'STENL Mux'
		value Normal
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 Normal
			item.1 'Sidetone Left'
		}
	}
	control.112 {
		iface MIXER
		name 'LTENR Mux'
		value Normal
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 Normal
			item.1 Loopthrough
		}
	}
	control.113 {
		iface MIXER
		name 'LTENL Mux'
		value Normal
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 Normal
			item.1 Loopthrough
		}
	}
	control.114 {
		iface MIXER
		name 'LBENR Mux'
		value Normal
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 Normal
			item.1 Loopback
		}
	}
	control.115 {
		iface MIXER
		name 'LBENL Mux'
		value Normal
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 Normal
			item.1 Loopback
		}
	}
	control.116 {
		iface MIXER
		name 'Right ADC Mixer IN12 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.117 {
		iface MIXER
		name 'Right ADC Mixer IN34 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.118 {
		iface MIXER
		name 'Right ADC Mixer IN56 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.119 {
		iface MIXER
		name 'Right ADC Mixer LINEA Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.120 {
		iface MIXER
		name 'Right ADC Mixer LINEB Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.121 {
		iface MIXER
		name 'Right ADC Mixer MIC1 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.122 {
		iface MIXER
		name 'Right ADC Mixer MIC2 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.123 {
		iface MIXER
		name 'Left ADC Mixer IN12 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.124 {
		iface MIXER
		name 'Left ADC Mixer IN34 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.125 {
		iface MIXER
		name 'Left ADC Mixer IN56 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.126 {
		iface MIXER
		name 'Left ADC Mixer LINEA Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.127 {
		iface MIXER
		name 'Left ADC Mixer LINEB Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.128 {
		iface MIXER
		name 'Left ADC Mixer MIC1 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.129 {
		iface MIXER
		name 'Left ADC Mixer MIC2 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.130 {
		iface MIXER
		name 'LINEB Mixer IN2 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.131 {
		iface MIXER
		name 'LINEB Mixer IN4 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.132 {
		iface MIXER
		name 'LINEB Mixer IN6 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.133 {
		iface MIXER
		name 'LINEB Mixer IN56 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.134 {
		iface MIXER
		name 'LINEA Mixer IN1 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.135 {
	iface MIXER
		name 'LINEA Mixer IN3 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.136 {
	iface MIXER
		name 'LINEA Mixer IN5 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.137 {
	iface MIXER
		name 'LINEA Mixer IN34 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.138 {
		iface MIXER
		name 'DMIC Mux'
		value ADC
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 ADC
			item.1 DMIC
		}
	}
	control.139 {
		iface MIXER
		name 'MIC2 Mux'
		value IN34
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 IN34
			item.1 IN56
		}
	}
	control.140 {
		iface MIXER
		name 'MIC1 Mux'
		value IN12
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 IN12
			item.1 IN56
		}
	}
}
state.RockchipHDMI {
control {
	}
}
EOF

	sudo mkdir -p ${strapdir}/etc/pulse
	cat << EOF | sudo tee ${strapdir}/etc/pulse/default.pa
#!/usr/bin/pulseaudio -nF
#
# This file is part of PulseAudio.
#
# PulseAudio is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# PulseAudio is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with PulseAudio; if not, see <http://www.gnu.org/licenses/>.
# This startup script is used only if PulseAudio is started per-user
# (i.e. not in system mode)

.nofail

### Load something into the sample cache
#load-sample-lazy x11-bell /usr/share/sounds/freedesktop/stereo/bell.oga
#load-sample-lazy pulse-hotplug /usr/share/sounds/freedesktop/stereo/device-added.oga
#load-sample-lazy pulse-coldplug /usr/share/sounds/freedesktop/stereo/device-added.oga
#load-sample-lazy pulse-access /usr/share/sounds/freedesktop/stereo/message.oga

.fail

### Automatically restore the volume of streams and devices
load-module module-device-restore
load-module module-stream-restore
load-module module-card-restore

### Automatically augment property information from .desktop files
### stored in /usr/share/application
load-module module-augment-properties

### Should be after module-*-restore but before module-*-detect
load-module module-switch-on-port-available

### Load audio drivers statically
### (it's probably better to not load these drivers manually, but instead
### use module-udev-detect -- see below -- for doing this automatically)
load-module module-alsa-sink device=plughw:0,0
#load-module module-alsa-source device=hw:1,0
#load-module module-oss device="/dev/dsp" sink_name=output source_name=input
#load-module module-oss-mmap device="/dev/dsp" sink_name=output source_name=input
#load-module module-null-sink
#load-module module-pipe-sink

### Automatically load driver modules depending on the hardware available
.ifexists module-udev-detect.so
load-module module-udev-detect
.else
### Use the static hardware detection module (for systems that lack udev support)
load-module module-detect
.endif

### Automatically connect sink and source if JACK server is present
.ifexists module-jackdbus-detect.so
.nofail
load-module module-jackdbus-detect channels=2
.fail
.endif

### Automatically load driver modules for Bluetooth hardware
.ifexists module-bluetooth-policy.so
load-module module-bluetooth-policy
.endif
.ifexists module-bluetooth-discover.so
load-module module-bluetooth-discover
.endif

### Load several protocols
.ifexists module-esound-protocol-unix.so
load-module module-esound-protocol-unix
.endif
load-module module-native-protocol-unix

### Network access (may be configured with paprefs, so leave this commented
### here if you plan to use paprefs)
#load-module module-esound-protocol-tcp
#load-module module-native-protocol-tcp
#load-module module-zeroconf-publish

### Load the RTP receiver module (also configured via paprefs, see above)
#load-module module-rtp-recv

### Load the RTP sender module (also configured via paprefs, see above)
#load-module module-null-sink sink_name=rtp format=s16be channels=2 rate=44100 sink_properties="device.description='RTP Multicast Sink'"
#load-module module-rtp-send source=rtp.monitor

### Load additional modules from GConf settings. This can be configured with the paprefs tool.
### Please keep in mind that the modules configured by paprefs might conflict with manually
### loaded modules.
.ifexists module-gconf.so
.nofail
load-module module-gconf
.fail
.endif

### Automatically restore the default sink/source when changed by the user
### during runtime
### NOTE: This should be loaded as early as possible so that subsequent modules
### that look up the default sink/source get the right value
load-module module-default-device-restore

### Automatically move streams to the default sink if the sink they are
### connected to dies, similar for sources
load-module module-rescue-streams

### Make sure we always have a sink around, even if it is a null sink.
load-module module-always-sink

### Honour intended role device property
load-module module-intended-roles

### Automatically suspend sinks/sources that become idle for too long
load-module module-suspend-on-idle

### If autoexit on idle is enabled we want to make sure we only quit
### when no local session needs us anymore.
.ifexists module-console-kit.so
load-module module-console-kit
.endif
.ifexists module-systemd-login.so
load-module module-systemd-login
.endif

### Enable positioned event sounds
load-module module-position-event-sounds

### Cork music/video streams when a phone stream is active
load-module module-role-cork

### Modules to allow autoloading of filters (such as echo cancellation)
### on demand. module-filter-heuristics tries to determine what filters
### make sense, and module-filter-apply does the heavy-lifting of
### loading modules and rerouting streams.

load-module module-filter-heuristics
load-module module-filter-apply

# X11 modules should not be started from default.pa so that one daemon
# can be shared by multiple sessions.

### Load X11 bell module
#load-module module-x11-bell sample=x11-bell

### Register ourselves in the X11 session manager
#load-module module-x11-xsmp

### Publish connection data in the X11 root window
#.ifexists module-x11-publish.so
#.nofail
#load-module module-x11-publish
#.fail
#.endif

### Make some devices default
set-default-sink 0
#set-default-source input
EOF
# }}}

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
