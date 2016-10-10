Using crosstool-ng to make your own toolchains
==============================================

If the Devuan provided toolchain does not compile the kernel for your board, you
can then use [crosstool-ng](https://github.com/crosstool-ng/crosstool-ng.git) to
help you create your own GCC toolchain. Here are the basic steps to get a
working toolchain:

* Create a new directory in `$HOME` called `build`

```
; cd $HOME; mkdir build; cd build
```

* Clone the crosstool-ng git repository

```
; git clone https://github.com/crosstool-ng/crosstool-ng && cd crosstool-ng
```

* Install the required dependencies for using ct-ng

```
; sudo apt-get install build-essential autoconf automake ncurses-dev gperf flex texinfo help2man libtool-bin bison gawk
```
* Compile crosstool-ng

```
; ./bootstrap
; ./configure --prefix=$HOME/.local
; make
; make install
```

Now you have installed crosstool-ng. Now let's create an armhf toolchain!
Go grab some beer and drink it until it's done compiling...

```
; export PATH="$HOME/.local/bin:$PATH"
; mkdir -p $HOME/tc/armv7-rpi2-linux-gnueabihf
; cd $HOME/tc/armv7-rpi2-linux-gnueabihf
; ct-ng armv7-rpi2-linux-gnueabihf
; ct-ng build
```

Congrats! You've built a GCC toolchain and perhaps got drunk in the meantime :)

Be sure to check out `ct-ng list-samples` to see what other toolchains are
offered, or perhaps even configure your own with `menuconfig`
