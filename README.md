arm-sdk
=======

arm-sdk is simple distro build system aimed at embedded ARM devices. It was
first conceived as a component of the Devuan SDK, but now it aims to
support multiple Linux distributions.

## Requirements

arm-sdk is designed to be used interactively from a terminal, as well as
from shell scripts. It requires the following packages to be installed, as well
as [libdevuansdk dependencies](https://github.com/parazyd/libdevuansdk/blob/master/README.md#requirements):


### Devuan

```
curl git wget qemu-user-static build-essential rsync gcc-arm-none-eabi gcc-multilib lib32z1 u-boot-tools device-tree-compiler lzop dosfstools vboot-utils vboot-kernel-utils libftdi-dev libfdt-dev swig libpython-dev bc bison flex libssl-dev
```

### Gentoo
```
net-misc/curl net-misc/wget sys-boot/vboot-utils app-emulation/qemu(static-user) net-misc/rsync sys-libs/zlib dev-embedded/u-boot-tools sys-apps/dtc app-arch/lzop sys-fs/dosfstools sys-devel/flex sys-devel/bison
```

`sudo` permissions are required for the user that is running the build.


## Quick start

Edit the `config` file to match your crosscompile toolchains.  Then run
zsh. In case you have conflicting extensions on your zsh configuration,
safest way would be to run a vanilla one, using:

```
; zsh -f
```

then step inside the sdk, "source" it:

```
; cd arm-sdk && source sdk
```

Now is the time you choose the device and OS you want to build the image for.

### Currently supported distros

* `devuan`

### Currently supported boards

* `beagleboneblack` - BeagleBone Black
* `chromeacer` - Acer ARM Chromebook
* `chromeveyron` - Veyron ARM Chromebook (RK3288)
* `n900` - Nokia N900
* `n950` - Nokia N950
* `n9` - Nokia N9
* `droid` - Motorola Droid 4
* `bionic` - Motorola Droid Bionic
* `odroidxu` - ODROID-XU
* `odroidxu4` - ODROID-XU4
* `ouya` - OUYA gaming console
* `raspi1` - Raspberry Pi 1 and 0 (armel)
* `raspi2` - Raspberry Pi 2 and 3
* `raspi3` - Raspberry Pi 3 (64bit)
* `raspi4` - Raspberry Pi 4 (64bit)
* `rock64` - Rock64 (64bit) (EXPERIMENTAL)
* `pinephone-dontbeevil` - Pinephone Dontbeevil devkit
* `pinephone` - Pine64 Pinephone
* `pinetab` - Pine64 Pinetab
* `sunxi` - Allwinner-based boards
* `turbox-twister` - TurboX Twister tablet

```
; load devuan sunxi
```

Once initialized, you can run the helper command:

```
; build_image_dist
```

The image will automatically be build for you. Once finished, you will be
able to find it in the `dist/` directory in arm-sdk's root.

For more info, see the `doc/` directory.
