Debug With Objdump
================================================================================

Example:
--------------------------------------------------------------------------------

### sources:

```
#include <stdio.h>

int main(void)
{
    char *p = NULL;
    char c;

    c = *p;
    *p = 'a';

    return 0;
}
```

### Android.mk:

```
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE_TAGS := optional
LOCAL_SRC_FILES := test.c
LOCAL_MODULE := test_objdump

include $(BUILD_EXECUTABLE)
```

### log:

```
<7>[ 1231.173553] test_objdump: unhandled page fault (11) at 0x00000000, code 0x805
<1>[ 1231.173614] pgd = ea4b8000
<1>[ 1231.175292] [00000000] *pgd=00000000
<4>[ 1231.178863]
<4>[ 1231.182373] Pid: 4356, comm:         test_objdump
<4>[ 1231.186065] CPU: 0    Tainted: G        W  O  (3.4.0-perf-g4c1c0b5-00572-g07922aa #1)
<4>[ 1231.194976] PC is at 0xb6feb2b0
<4>[ 1231.197662] LR is at 0xb6f70b5b
<4>[ 1231.201171] pc : [<b6feb2b0>]    lr : [<b6f70b5b>]    psr: 200b0030
<4>[ 1231.201171] sp : be843930  ip : b6f72e49  fp : be84395c
<4>[ 1231.213928] r10: 00000000  r9 : 00000000  r8 : 00000000
<4>[ 1231.218750] r7 : b6feb2ad  r6 : 00000001  r5 : be84396c  r4 : be843964
<4>[ 1231.225738] r3 : 00000061  r2 : be84396c  r1 : be843964  r0 : 00000000
<4>[ 1231.232635] Flags: nzCv  IRQs on  FIQs on  Mode USER_32  ISA Thumb  Segment user
<4>[ 1231.240478] Control: 10c5787d  Table: aa6b806a  DAC: 00000015
<4>[ 1231.245880] [<c010bcf0>] (unwind_backtrace+0x0/0x11c) from [<c0111c5c>] (__do_user_fault+0xfc/0x148)
<4>[ 1231.255493] [<c0111c5c>] (__do_user_fault+0xfc/0x148) from [<c08f5404>] (do_page_fault+0x358/0x3e8)
<4>[ 1231.266021] [<c08f5404>] (do_page_fault+0x358/0x3e8) from [<c0100388>] (do_DataAbort+0x134/0x1a8)
<4>[ 1231.274932] [<c0100388>] (do_DataAbort+0x134/0x1a8) from [<c08f3c74>] (__dabt_usr+0x34/0x40)
<4>[ 1231.283752] Exception stack(0xc005dfb0 to 0xc005dff8)
<4>[ 1231.287811] dfa0:                                     00000000 be843964 be84396c 00000061
<4>[ 1231.297454] dfc0: be843964 be84396c 00000001 b6feb2ad 00000000 00000000 00000000 be84395c
<4>[ 1231.305999] dfe0: b6f72e49 be843930 b6f70b5b b6feb2b0 200b0030 ffffffff
```

objdump & readelf & gdb & maps
--------------------------------------------------------------------------------

### readelf:

```
$ arm-linux-androideabi-readelf -h test_objdump
ELF Header:
  Magic:   7f 45 4c 46 01 01 01 00 00 00 00 00 00 00 00 00
  Class:                             ELF32
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              DYN (Shared object file)
  Machine:                           ARM
  Version:                           0x1
  Entry point address:               0x2b4
  Start of program headers:          52 (bytes into file)
  Start of section headers:          6452 (bytes into file)
  Flags:                             0x5000000, Version5 EABI
  Size of this header:               52 (bytes)
  Size of program headers:           32 (bytes)
  Number of program headers:         8
  Size of section headers:           40 (bytes)
  Number of section headers:         31
  Section header string table index: 30
```

### objdump:

```
000002b4 <_start>:
 2b4:    e92d4800       push    {fp, lr}
 2b8:    e28db004       add     fp, sp, #4
 2bc:    e24dd010       sub     sp, sp, #16
 2c0:    e59f3050       ldr     r3, [pc, #80]   ; 318 <_start+0x64>
 2c4:    e08f3003       add     r3, pc, r3
...

000002ac <main>:
 2ac: 2000      movs r0, #0
 2ae: 2361      movs r3, #97 ; 0x61
 # 以下这条指令会出现段错误,其偏移地址为2b0,加上重定位基地址b6feb000,等于0xb6feb2b0
 2b0: 7003      strb r3, [r0, #0]
 2b2: 4770      bx lr
```

### gdb

```
$ adb forward tcp:5039 tcp:5039
$ adb push out/target/product/aries/system/bin/gdbserver /system/bin
3141 KB/s (397672 bytes in 0.123s)
$ adb shell gdbserver :5039 /system/bin/test_objdump &
$ Process /system/bin/test_objdump created; pid = 4356
Listening on port 5039

$ gdbclient test_objdump

If you haven't done so already, do this first on the device:
    gdbserver :5039 /system/bin/system/bin/test_objdump
 or
    gdbserver :5039 --attach <PID>

GNU gdb (GDB) 7.6
Copyright (C) 2013 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
and "show warranty" for details.
This GDB was configured as "--host=x86_64-linux-gnu --target=arm-linux-android".
For bug reporting instructions, please see:
<http://source.android.com/source/report-bugs.html>...
Reading symbols from /home/liminghao/ssd/aries-l-org/out/target/product/aries/symbols/system/bin/test_objdump...done.
Remote debugging from host 127.0.0.1
__dl__start () at bionic/linker/arch/arm/begin.S:32
32            mov r0, sp
(gdb) p _start
$1 = {<text variable, no debug info>} 0xb6feb2b4 <_start>
(gdb) c
Continuing.
warning: Could not load shared library symbols for libNimsWrap.so.
Do you need "set solib-search-path" or "set sysroot"?
warning: Could not load shared library symbols for libvendorconn.so.
Do you need "set solib-search-path" or "set sysroot"?

Program received signal SIGSEGV, Segmentation fault.
0xb6feb2b0 in main () at frameworks/base/cmds/test_objdump/test.c:9
9              *p = 'a';
(gdb) p $pc
$2 = (void (*)()) 0xb6feb2b0 <main+4>   # 发生段错误的当前指令
(gdb) x/10i $pc
=> 0xb6feb2b0 <main+4>: strb    r3, [r0, #0]
   0xb6feb2b2 <main+6>: bx      lr
   0xb6feb2b4 <_start>: push    {r11, lr}
   0xb6feb2b8 <_start+4>:       add   r11, sp, #4
   0xb6feb2bc <_start+8>:       sub   sp, sp, #16
   0xb6feb2c0 <_start+12>:      ldr   r3, [pc, #80]     ; 0xb6feb318 <_start+100>
   0xb6feb2c4 <_start+16>:      add   r3, pc, r3
   0xb6feb2c8 <_start+20>:      ldr   r2, [pc, #76]     ; 0xb6feb31c <_start+104>
   0xb6feb2cc <_start+24>:      ldr   r2, [r3, r2]
   0xb6feb2d0 <_start+28>:      str   r2, [r11, #-20]
(gdb) info registers
r0             0x0      0
r1             0xbe843964       3196336484
r2             0xbe84396c       3196336492
r3             0x61             97
r4             0xbe843964       3196336484
r5             0xbe84396c       3196336492
r6             0x1              1
r7             0xb6feb2ad       3070145197
r8             0x0              0
r9             0x0              0
r10            0x0              0
r11            0xbe84395c       3196336476
r12            0xb6f72e49       3069652553
sp             0xbe843930       0xbe843930
lr             0xb6f70b5b       -1225323685
pc             0xb6feb2b0       0xb6feb2b0 <main+4>
cpsr           0x200b0030       537591856
```

### maps

```
liminghao@liminghao:~/ssd/aries-l-org$ adb shell
root@aries:/ # ps | grep test
root      4356  4352  216    16    c01870e4 b6fdba18 t /system/bin/test_objdump
root@aries:/ # cat /proc/4356/maps
b6fda000-b6fdb000 r-xp 00000000 00:00 0          [sigpage]
b6fdb000-b6fe8000 r-xp 00000000 b3:17 295        /system/bin/linker
b6fe8000-b6fea000 rw-p 0000c000 b3:17 295        /system/bin/linker
b6fea000-b6feb000 rw-p 00000000 00:00 0
# test_objdump每次映射的虚拟地址空间的起始地址是会变的，不变的是其映射空间大小
# 为0x2000
b6feb000-b6fec000 r-xp 00000000 b3:17 1946       /system/bin/test_objdump
b6fec000-b6fed000 rw-p 00000000 b3:17 1946       /system/bin/test_objdump
b6fed000-b6fee000 rw-p 00000000 00:00 0
be823000-be844000 rw-p 00000000 00:00 0          [stack]
ffff0000-ffff1000 r-xp 00000000 00:00 0          [vectors]
```

Note: b6feb000 + 2b4 = 0xb6feb2b4, b6feb000是test_objdump重定位的基地址.

再一次启动test_objdump的maps如下:

```
root@aries:/ # ps | grep test
root      7281  7277  216    4     c01870e4 b6f11a18 t /system/bin/test_objdump
root@aries:/ # cat /proc/7281/maps
b6f10000-b6f11000 r-xp 00000000 00:00 0          [sigpage]
b6f11000-b6f1e000 r-xp 00000000 b3:17 295        /system/bin/linker
b6f1e000-b6f20000 rw-p 0000c000 b3:17 295        /system/bin/linker
b6f20000-b6f21000 rw-p 00000000 00:00 0
b6f21000-b6f22000 r-xp 00000000 b3:17 1946       /system/bin/test_objdump
b6f22000-b6f23000 rw-p 00000000 b3:17 1946       /system/bin/test_objdump
b6f23000-b6f24000 rw-p 00000000 00:00 0
beea5000-beec6000 rw-p 00000000 00:00 0          [stack]
ffff0000-ffff1000 r-xp 00000000 00:00 0          [vectors]

```

Each row in /proc/$PID/maps describes a region of contiguous virtual memory in a process or
thread. Each row has the following fields:

```
address           perms offset  dev   inode   pathname
08048000-08056000 r-xp 00000000 03:0c 64593   /usr/sbin/gpm
```

* address - This is the starting and ending address of the region in the process's address space
* permissions - This describes how pages in the region can be accessed. There are
  four different permissions: read, write, execute, and shared. If read/write/execute
  are disabled, a '-' will appear instead of the 'r'/'w'/'x'. If a region is not shared,
  it is private, so a 'p' will appear instead of an 's'. If the process attempts to
  access memory in a way that is not permitted, a segmentation fault is generated.
  Permissions can be changed using the mprotect system call.
* offset - If the region was mapped from a file (using mmap), this is the offset in the
  file where the mapping begins. If the memory was not mapped from a file, it's just 0.
* device - If the region was mapped from a file, this is the major and minor device number
  (in hex) where the file lives.
* inode - If the region was mapped from a file, this is the file number.
* pathname - If the region was mapped from a file, this is the name of the file.
  This field is blank for anonymous mapped regions. There are also special regions
  with names like [heap], [stack], or [vdso]. [vdso] stands for virtual dynamic
  shared object. It's used by system calls to switch to kernel mode.