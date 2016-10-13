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

boards=()

for board in boards/*.sh; do
	name=$(grep 'device_name=' $board)
	[[ $name =~ myboard ]] && continue
	name=${name[(ws:=:)2]}
	boards+=(${(Q)name})
done

distro="$1"

[[ -n $distro ]] || { print "(!!) os not declared"; exit 1 }

for board in $boards; do

	## odroid wants the devuan packaged toolchain
	[[ $board = odroidxu ]] && {
		sed -i -e '36,37s/#//' -e '31,32s/^/#/' ./config && \
		zsh -f -c "source ./sdk && load $distro $board && build_image_dist && exit" && \
		sed -i -e '36,37s/^/#/' -e '31,32s/#//' ./config
		continue
	}

	## raspi3 wants the arm64 toolchain and qemu
	[[ $board = raspi3 ]] && {
		sed -i -e '42,43s/#//' -e '31,32s/^/#/' ./config && \
		sed -i -e '47s/^/#/' -e '48s/#//' ./config && \
		zsh -f -c "source ./sdk && load $distro $board && build_image_dist && exit" && \
		sed -i -e '42,43s/^/#/' -e '31,32s/#//' ./config && \
		sed -i -e '47s/#//' -e '48s/^/#/' ./config
		continue
	}

	zsh -f -c "source ./sdk && load $distro $board && build_image_dist && exit"
done
