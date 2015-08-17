debug uboot build with arm
================================================================================

liminghao@liminghao:~/yudatun/bootloader/uboot-qemu$ arm-none-linux-gnueabi-gdb ../../out/target/product/qemu/bootloader
GNU gdb (Sourcery CodeBench Lite 2013.05-24) 7.4.50.20120716-cvs
Copyright (C) 2012 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
and "show warranty" for details.
This GDB was configured as "--host=i686-pc-linux-gnu --target=arm-none-linux-gnueabi".
For bug reporting instructions, please see:
<https://sourcery.mentor.com/GNUToolchain/>...
Reading symbols from /home/liminghao/yudatun/out/target/product/qemu/bootloader...done.
(gdb) p _start
$1 = {<text variable, no debug info>} 0x60800000 <_start>
(gdb) target remote :1234
Remote debugging using :1234
warning: Unable to find dynamic linker breakpoint function.
GDB will be unable to debug shared library initializers
and track explicitly loaded dynamic code.
_start () at /home/liminghao/yudatun/bootloader/uboot-qemu/arch/arm/lib/vectors.S:54
54        b  reset
(gdb) add-symbol-file ../../out/target/product/qemu/bootloader 0x60800000
add symbol table from file "../../out/target/product/qemu/bootloader" at
    .text_addr = 0x60800000
(y or n) y
Reading symbols from /home/liminghao/yudatun/out/target/product/qemu/bootloader...done.
(gdb) b 0x60800000
malformed linespec error: unexpected string, "x60800000"
(gdb) b *0x60800000
Breakpoint 1 at 0x60800000: file /home/liminghao/yudatun/bootloader/uboot-qemu/arch/arm/lib/vectors.S, line 54.
(gdb) c
