Install bochs
================================================================================

Dependence
--------------------------------------------------------------------------------

```
$ sudo apt-get install build-essential
$ sudo apt-get install libx11-dev
$ sudo apt-get install libxrandr-dev
$ sudo apt-get install xorg-dev
$ sudo apt-get install libgtk2.0-dev
$ sudo apt-get install vgabios
```

Configure
--------------------------------------------------------------------------------

```
$ LDFLAGS=-lpthread ./configure --with-x11 --enable-disasm --enable-gdb-stub [--enable-debugger]
$ make
$ sudo make install
```