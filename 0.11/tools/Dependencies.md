Linux 0.11 内核模块依赖关系
================================================================================

bootsect的构建过程
--------------------------------------------------------------------------------

bootsect模块是由boot/下bootsect.s汇编语言文件由as86和ld86编译链接而成

path: Makefile
```
# 8086汇编编译器和链接器. -0 生成8086目标程序: -a 生成与as和ld部分兼容的代码
AS86    =as86 -0 -a
LD86    =ld86 -0
...
boot/bootsect:  boot/bootsect.s
       $(AS86) -o boot/bootsect.o boot/bootsect.s
       $(LD86) -s -o boot/bootsect boot/bootsect.o
```

setup的构建过程
--------------------------------------------------------------------------------

setup模块是由boot/下setup.s汇编语言文件由as86和ld86编译链接而成

path: Makefile
```
boot/setup: boot/setup.s
            $(AS86) -o boot/setup.o boot/setup.s
            $(LD86) -s -o boot/setup boot/setup.o
```

system的构建过程
--------------------------------------------------------------------------------

system模块是由boot/head.o, init/main.o, ARCHIVES, DRIVERS, MATH, LIBS所声明模块编译链接而成，
具体各个模块的编译链接过程如下Makefile声明所示:

path: Makefile
```
ARCHIVES=kernel/kernel.o mm/mm.o fs/fs.o
DRIVERS =kernel/blk_drv/blk_drv.a kernel/chr_drv/chr_drv.a
MATH    =kernel/math/math.a
LIBS    =lib/lib.a
...
tools/system:  boot/head.o init/main.o $(ARCHIVES) $(DRIVERS) $(MATH) $(LIBS)
               $(LD) $(LDFLAGS) \
                   boot/head.o init/main.o \
                   $(ARCHIVES) \
                   $(DRIVERS) \
                   $(MATH) \
                   $(LIBS) \
                   -o tools/system > System.map
```

下面我们分别描述system模块所依赖的各个模块的编译过程.

### head模块(boot/head.o)

head.o模块是system模块的头部,其是由as编译器编译而成.

path: Makefile
```
.s.o:
        $(AS) --32 -o $*.o $<
...
boot/head.o: boot/head.s
```

### main模块(init/main.o)

main.o是由init/main.c文件生成的.

```
.c.o:
        $(CC) $(CFLAGS) \
        -nostdinc -Iinclude -c -o $*.o $<
...
# 以下是main模块所依赖的源码文件
init/main.o : init/main.c include/unistd.h include/sys/stat.h \
  include/sys/types.h include/sys/times.h include/sys/utsname.h \
  include/utime.h include/time.h include/linux/tty.h include/termios.h \
  include/linux/sched.h include/linux/head.h include/linux/fs.h \
  include/linux/mm.h include/signal.h include/asm/system.h include/asm/io.h \
  include/stddef.h include/stdarg.h include/fcntl.h
```

### ARCHIVES(kernel/kernel.o, mm/mm.o, fs/fs.o)

ARCHIVES声明为kernel/kernel.o mm/mm.o fs/fs.o这三个模块,各个模块的编译如下所示

#### kernel模块(kernel.o)

kernel模块所依赖的模块如下所示:

path: kernel/Makefile
```
# 以下是kernel模块所依赖的各个子模块.
# 对应源码文件如下所示 --> path: kernel/
# sched.c system_call.s traps.c asm.s fork.c
# panic.c printk.c vsprintf.c sys.c exit.c
# signal.c mktime.c
OBJS  = sched.o system_call.o traps.o asm.o fork.o \
      panic.o printk.o vsprintf.o sys.o exit.o \
      signal.o mktime.o

kernel.o: $(OBJS)
          $(LD) -r -o kernel.o $(OBJS)
          sync
```

#### mm模块(mm/mm.o)

mm模块所依赖的如下所示

path: mm/Makefile
```
# 以下是mm.o所对应的各个子模块
# 对应的源码文件如下 - mm/
# memory.c page.s
OBJS    = memory.o page.o

all: mm.o

mm.o: $(OBJS)
      $(LD) -r -o mm.o $(OBJS)
```

#### fs模块(fs/fs.o)

path: fs/Makefile
```
# 以下是fs模块所依赖的各个子模块
# open.c read_write.c inode.c file_table.c buffer.c super.c
# block_dev.c char_dev.c file_dev.c stat.c exec.c pipe.c namei.c
# bitmap.c fcntl.c ioctl.c truncate.c
OBJS=   open.o read_write.o inode.o file_table.o buffer.o super.o \
        block_dev.o char_dev.o file_dev.o stat.o exec.o pipe.o namei.o \
        bitmap.o fcntl.o ioctl.o truncate.o

fs.o: $(OBJS)
      $(LD) -r -o fs.o $(OBJS)
```

### DRIVERS模块

DRIVERS模块包括内核驱动静态库,其分别由: kernel/blk_drv/blk_drv.a kernel/chr_drv/chr_drv.a组成

#### blk_drv块设备驱动模块(kernel/blk_drv/blk_drv.a)

path: kernel/blk_drv/Makefile
```
# blk_drv块设备驱动模块由如下子模块编译而成，其对应的源码文件如下所示 - kernel/blk_drv:
# ll_rw_blk.c floppy.c hd.c ramdisk.c
OBJS  = ll_rw_blk.o floppy.o hd.o ramdisk.o

blk_drv.a: $(OBJS)
    $(AR) rcs blk_drv.a $(OBJS)
    sync
```

#### chr_drv块设备驱动模块(kernel/chr_drv/chr_drv.a)

```
# chr_drv块设备驱动模块由如下子模块编译而成，其对应的源码文件如下所示 - kernel/chr_drv:
# tty_io.c console.c keyboard.S serial.c rs_io.s tty_ioctl.c
OBJS  = tty_io.o console.o keyboard.o serial.o rs_io.o \
        tty_ioctl.o

chr_drv.a: $(OBJS)
    $(AR) rcs chr_drv.a $(OBJS)
    sync
```

### MATH

#### kernel/math/math.a

path: kernel/math/Makefile
```
# math_emulate.c源文件编译生成math_emulate.o模块
OBJS  = math_emulate.o

math.a: $(OBJS)
    $(AR) rcs math.a $(OBJS)
    sync
```

### LIBS

#### lib/lib.a

path: lib/Makefile
```
# ctype.c _exit.c open.c close.c errno.c write.c dup.c
# setsid.c execve.c wait.c string.c malloc.c
OBJS  = ctype.o _exit.o open.o close.o errno.o write.o dup.o setsid.o \
    execve.o wait.o string.o malloc.o

lib.a: $(OBJS)
    $(AR) rcs lib.a $(OBJS)
    sync
```

build工具程序的构建过程
--------------------------------------------------------------------------------

path: Makefile
```
tools/build: tools/build.c
        $(CC) $(CFLAGS) \
        -o tools/build tools/build.c
```