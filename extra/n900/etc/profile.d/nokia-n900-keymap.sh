# Setup Nokia N900 keymap either on console.
if ! [ -n "$DISPLAY" ]; then
	/bin/busybox loadkmap < /etc/nokia-n900.kmap
fi
