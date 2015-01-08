QEMU build
================================================================================

```
$ sudo apt-get install libpci-dev
$ sudo apt-get install dh-autoreconf
$ sudo apt-get install libglib2.0-dev
$ sudo apt-get install autoconf
$ sudo apt-get install libsdl1.2-dev libsdl1.2debian
$ sudo add-apt-repository ppa:gezakovacs/ppa
$ sudo apt-get update
$ sudo apt-get install unetbootin
$ ./configure --enable-sdl --audio-drv-list=alsa
$ make
$ sudo make install
```