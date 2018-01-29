# Setup Nokia N900 keymap either on console or Xorg
if [ -n "$DISPLAY" ]; then
	setxkbmap -rules evdev -model nokiarx51 -layout us -variant ",qwerty"
else
	/bin/busybox loadkmap < /etc/nokia-n900.kmap
fi
