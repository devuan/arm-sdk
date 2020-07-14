#!/bin/sh
# Copyright (c) 2016-2020 Dyne.org Foundation
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

## This script will setup arm-sdk and make it ready for usage.

set -e

git submodule update --init --recursive --checkout
mkdir -p gcc
cd gcc

or1ktc="or1k-linux-musl"
or1kurl="http://musl.cc/or1k-linux-musl-cross.tgz"

wget "$or1kurl"
tar xf "$(basename "$or1kurl")"
mv or1k-linux-musl-cross "$or1ktc"
rm -f "$(basename "$or1kurl")"

cd -

cat <<EOM

All done! Make sure you also install the required dependencies listed in
README.md. You can use the following oneliner as well:

$ grep '^curl ' README.md | xargs sudo apt --yes --force-yes install
EOM
