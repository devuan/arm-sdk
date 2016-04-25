/*
 * Copyright (c) 2016 Dyne.org Foundation
 * ARM SDK is written and maintained by parazyd <parazyd@dyne.org>
 *
 * This file is part of ARM SDK
 *
 * This source code is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this source code. If not, see <http://www.gnu.org/licenses/>.
 */

#include <string.h>
#include <unistd.h>

int main(int argc, char **argv, char **envp) {
	char *newargv[argc + 3];

	newargv[0] = argv[0];
	newargv[1] = "-cpu";
	newargv[2] = "cortex-a8"; /* here you can set the cpu you are building for */

	memcpy(&newargv[3], &argv[1], sizeof(*argv) * (argc -1));
	newargv[argc + 2] = NULL;
	return execve("/usr/bin/qemu-arm", newargv, envp);
}
