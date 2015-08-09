A Sample Of Debug Native Shared Libraries
========================================

查看bugreporter发现没有调用栈，只有简单的信息。

```
Build fingerprint: 'Xiaomi/cancro_wc_lte/cancro:4.4.4/KTU84P/5.7.30:user/release-keys'
Revision: '0'
pid: 17241, tid: 17276, name: Thread-413 >>> com.towords <<<
signal 11 (SIGSEGV), code 1 (SEGV_MAPERR), fault addr 0000001c
```

本地验证发现每次拓词crash时，debuggerd进程也会一起crash，所以才不会生成调用栈。
所以先得看看debuggerd为什么会挂掉。
加入coredump机制，复现问题，有了debuggerd的coredump。

GDB
----------------------------------------

用GDB分析如下:

```
#0  load_symbol_table (filename=filename@entry=0x411ae05c "/data/data/com.towords/files/libprotectClass.so") at system/core/libcorkscrew/symbol_table.c:94
94            if (shdr[i].sh_type == SHT_SYMTAB) {
(gdb) bt
#0  load_symbol_table (filename=filename@entry=0x411ae05c "/data/data/com.towords/files/libprotectClass.so") at system/core/libcorkscrew/symbol_table.c:94
#1  0x401039fe in load_ptrace_map_info_data (mi=0x411ae048, pid=<optimized out>) at system/core/libcorkscrew/ptrace.c:96
#2  load_ptrace_context (pid=pid@entry=4486) at system/core/libcorkscrew/ptrace.c:112
...
```

path: system/core/libcorkscrew/symbol_table.c

```
symbol_table_t* load_symbol_table(const char *filename) {
    symbol_table_t* table = NULL;
    // 打开/data/data/com.towords/files/libprotectClass.so
    int fd = open(filename, O_RDONLY);
    struct stat sb;

    size_t length = sb.st_size;
    char* base = mmap(NULL, length, PROT_READ, MAP_PRIVATE, fd, 0);  //映射到内存空间中
    Elf32_Ehdr *hdr = (Elf32_Ehdr*)base;
    Elf32_Shdr *shdr = (Elf32_Shdr*)(base + hdr->e_shoff);          //获取SectionHeader的偏移
    int sym_idx = -1;
    int dynsym_idx = -1;
    for (Elf32_Half i = 0; i < hdr->e_shnum; i++) {
        if (shdr[i].sh_type == SHT_SYMTAB) {  <<<<             //查找symboltable
            sym_idx = i;
        }
```

debuggerd在读取libprotectClass.so的symboltable的时候下表i越界了。

```
(gdb) info reg
r0             0x1d    29
r1             0x28    40
r2             0x0    0
r3             0x0    0
r4             0x4016b00c    1075228684
r5             0x4013b000    1075032064
r6             0x1    1
r7             0x4016ab84    1075227524
r8             0xffffffff    4294967295
r9             0x1    1
r10            0x1    1
r11            0x4005b6c0    1074116288
r12            0x66    102
sp             0xbebe4f88    0xbebe4f88
lr             0x40096cef    1074359535
pc             0x40103b18    0x40103b18 <load_symbol_table+92>
cpsr           0x80010030    -2147418064

(gdb) disassemble
Dump of assembler code for function load_symbol_table:
   0x4012cabc <+0>:    stmdb    sp!, {r4, r5, r6, r7, r8, r9, r10, r11, lr}
   0x4012cac0 <+4>:    movs    r1, #0
   0x4012cac2 <+6>:    sub    sp, #148    ; 0x94
   ...
   0x4012cb14 <+88>:    mla    r4, r1, r0, r7
=> 0x4012cb18 <+92>:    ldr    r3, [r4, #4]
```

可以看到i值也就是r0为29，且shdr[i]也就是R4值为0x4016b00c，也就是刚刚好过了一个页。
因此可以推断这个值刚好是mmap的下界附近。
正常来说i值一般是25左右，29有些不正常。

把手机里的libprotectClass.so文件pull出来，用readelf查看文件头，发现如下：

```
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
  Entry point address:               0x0
  Start of program headers:          52 (bytes into file)
  Start of section headers:          195460 (bytes into file)
  Flags:                             0x5000000, Version5 EABI
  Size of this header:               52 (bytes)
  Size of program headers:           32 (bytes)
  Number of program headers:         7
  Size of section headers:           108 (bytes)
  Number of section headers:         102
```

其中很明显最后两项值很不正常，且少了一个Section header string table index。
对比正常的elf文件:

```
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
  Entry point address:               0xd4c
  Start of program headers:          52 (bytes into file)
  Start of section headers:          8568 (bytes into file)
  Flags:                             0x5000000, Version5 EABI
  Size of this header:               52 (bytes)
  Size of program headers:           32 (bytes)
  Number of program headers:         8
  Size of section headers:           40 (bytes)
  Number of section headers:         25
  Section header string table index: 24
```

显然，应用商为了避免自己的code被人反解，对so文件做了些手脚。
但我们可以把它改回来，
真正的section header值可以通过so文件大小0x2ff1c减去Start of section headers值0x2fb84(195460)，
再除以Size of section headers值40即可获得。

```
(gdb) p /x (0x2ff1c-0x2fb84)/40
$19 = 0x17
```

再通过二进制编辑器将libprotectClass.so文件里的对应位改掉即可。
修改前

```
7F 45 4C 46 01 01 01 00 00 00 00 00 00 00 00 00
03 00 28 00 01 00 00 00 00 00 00 00 34 00 00 00
84 FB 02 00 00 00 00 05 34 00 20 00 07 00 6C 00
66 00 78 00 06 00 00 00 34 00 00 00 34 00 00 00
```

修改后

```
7F 45 4C 46 01 01 01 00 00 00 00 00 00 00 00 00
03 00 28 00 01 00 00 00 00 00 00 00 34 00 00 00
84 FB 02 00 00 00 00 05 34 00 20 00 07 00 28 00
17 00 16 00 06 00 00 00 34 00 00 00 34 00 00 00
```

push到手机里后，重启复现问题，发现debuggerd还是会crash，而且调用栈一模一样。
因此推断可能是程序启动的时候，自己改写这个so库。因此用chmod 555 libprotectClass.so命令把这个库的写权限给去掉。
再重启复现问题，发现debuggerd不再crash，也会生成libprotectClass.so的调用栈，coredump文件、maps文件等调试信息。
且log里面多了如下信息：

```
08-06 21:35:04.303  5299  5299 W System.err: java.io.FileNotFoundException: /data/data/com.towords/files/libprotectClass.so: open failed: EACCES (Permission denied)
08-06 21:35:04.305  5299  5299 W System.err:     at libcore.io.IoBridge.open(IoBridge.java:409)
08-06 21:35:04.305  5299  5299 W System.err:     at java.io.FileOutputStream.<init>(FileOutputStream.java:88)
08-06 21:35:04.305  5299  5299 W System.err:     at java.io.FileOutputStream.<init>(FileOutputStream.java:128)
08-06 21:35:04.306  5299  5299 W System.err:     at java.io.FileOutputStream.<init>(FileOutputStream.java:117)
08-06 21:35:04.306  5299  5299 W System.err:     at com.qihoo.util.StubApplication.copy(StubApplication.java:217)
08-06 21:35:04.306  5299  5299 W System.err:     at com.qihoo.util.StubApplication.attachBaseContext(StubApplication.java:147)
08-06 21:35:04.306  5299  5299 W System.err:     at android.app.Application.attach(Application.java:185)
08-06 21:35:04.306  5299  5299 W System.err:     at android.app.Instrumentation.newApplication(Instrumentation.java:991)
08-06 21:35:04.306  5299  5299 W System.err:     at android.app.Instrumentation.newApplication(Instrumentation.java:975)
08-06 21:35:04.306  5299  5299 W System.err:     at android.app.LoadedApk.makeApplication(LoadedApk.java:504)
08-06 21:35:04.306  5299  5299 W System.err:     at android.app.ActivityThread.handleBindApplication(ActivityThread.java:4314)
08-06 21:35:04.306  5299  5299 W System.err:     at android.app.ActivityThread.access$1500(ActivityThread.java:138)
08-06 21:35:04.306  5299  5299 W System.err:     at android.app.ActivityThread$H.handleMessage(ActivityThread.java:1261)
08-06 21:35:04.306  5299  5299 W System.err:     at android.os.Handler.dispatchMessage(Handler.java:102)
08-06 21:35:04.307  5299  5299 W System.err:     at android.os.Looper.loop(Looper.java:136)
08-06 21:35:04.307  5299  5299 W System.err:     at android.app.ActivityThread.main(ActivityThread.java:5016)
08-06 21:35:04.307  5299  5299 W System.err:     at java.lang.reflect.Method.invokeNative(Native Method)
08-06 21:35:04.307  5299  5299 W System.err:     at java.lang.reflect.Method.invoke(Method.java:515)
08-06 21:35:04.307  5299  5299 W System.err:     at com.android.internal.os.ZygoteInit$MethodAndArgsCaller.run(ZygoteInit.java:792)
08-06 21:35:04.307  5299  5299 W System.err:     at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:608)
08-06 21:35:04.307  5299  5299 W System.err:     at dalvik.system.NativeStart.main(Native Method)
08-06 21:35:04.307  5299  5299 W System.err: Caused by: libcore.io.ErrnoException: open failed: EACCES (Permission denied)
08-06 21:35:04.308  5299  5299 W System.err:     at libcore.io.Posix.open(Native Method)
08-06 21:35:04.308  5299  5299 W System.err:     at libcore.io.BlockGuardOs.open(BlockGuardOs.java:110)
08-06 21:35:04.308  5299  5299 W System.err:     at libcore.io.IoBridge.open(IoBridge.java:393)
08-06 21:35:04.309  5299  5299 W System.err:     ... 20 more
```

很明显，程序确实在启动的时候再改写这个libprotectClass.so文件，由于是W的log，即使不让它写，也不会影响程序的执行。
从com.qihoo.util.StubApplication可以看到，这里拓词可能是用了奇虎的一些保护机制。
回归正题，现在再看看拓词是怎么挂的
有了应用的coredump、maps、tombstone等信息，我们就可以对这个应用进行全面的分析。
从tombstone可以看到如下信息

```
*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
Build fingerprint: 'Xiaomi/pisces/pisces:4.4.4/KTU84P/eng.mi.20150728.105944:userdebug/test-keys'
Revision: '0'
pid: 5299, tid: 5397, name: Thread-333  >>> com.towords <<<
signal 11 (SIGSEGV), code 1 (SEGV_MAPERR), fault addr 0000001c
    r0 753d0628  r1 00000000  r2 42da5e60  r3 00000000
    r4 42da5e60  r5 42da5e60  r6 00000000  r7 7598f7d8
    r8 7598fb10  r9 7539ff0c  sl 00000001  fp 7598fb24
    ip 1d300001  sp 7598f748  lr 415479e7  pc 4155ac2e  cpsr 600b0030
backtrace:
    #00  pc 0005fc2e  /system/lib/libdvm.so (dvmCallMethodV(Thread*, Method const*, Object*, bool, JValue*, std::__va_list)+9)
    #01  pc 0004c9e3  /system/lib/libdvm.so
    #02  pc 0000ebbb  <unknown>
```

从寄存器的信息可以看到，这个现场和修改libprotectClass.so前一模一样，确定修改库没破坏现场。

```
r0             0x753d0628    1966933544
r1             0x0    0
r2             0x42da5e60    1121607264
r3             0x0    0
r4             0x42da5e60    1121607264
r5             0x42da5e60    1121607264
r6             0x0    0
r7             0x7598f7d8    1972959192
r8             0x7598fb10    1972960016
r9             0x7539ff0c    1966735116
r10            0x1    1
r11            0x7598fb24    1972960036
r12            0x1d300001    489684993
sp             0x7598f748    0x7598f748
lr             0x415479e7    1096055271
pc             0x4155ac2e    0x4155ac2e <dvmCallMethodV(Thread*, Method const*, Object*, bool, JValue*, std::__va_list)+10>
cpsr           0x600b0030    1611333680
```

```
(gdb) disassemble
Dump of assembler code for function dvmCallMethodV(Thread*, Method const*, Object*, bool, JValue*, std::__va_list):
   0x4155ac24 <+0>:    stmdb    sp!, {r4, r5, r6, r7, r8, r9, r10, r11, lr}
   0x4155ac28 <+4>:    mov    r10, r3
   0x4155ac2a <+6>:    sub    sp, #28
   0x4155ac2c <+8>:    movs    r3, #0
=>pc: 0x4155ac2e <+10>:    ldr    r5, [r1, #28]
   0x4155ac30 <+12>:    mov    r6, r0
```

显然r1值为空导致这次crash。r1值是Method*，是上一级函数传下来的。
通过栈推导上一级函数：

```
0x7598f748:    0x42da5e60    0x415b5bd8    0x00000014    0x415245cc
0x7598f758:    0x42da5e60    0x753d0628    0x415a6c6c    0x42da5e60
                                r4
0x7598f768:    0x42da5e60    0x00000000    0x7598f7d8    0x7598fb10
        r5        r6        r7        r8
0x7598f778:    0x7539ff0c    0x753d0638    0x7598fb24    0x415479e7
        r9        r10        r11        lr
```

从lr的值可以推出上一级的函数地址为0x415479e6

```
(gdb) disassemble 0x415479e6
Dump of assembler code for function NewObjectV(JNIEnv*, jclass, jmethodID, va_list):
   0x415479a0 <+0>:    push    {r4, r5, r6, r7, lr}
   0x415479a2 <+2>:    mov    r5, r0
   0x415479a4 <+4>:    sub    sp, #28
   0x415479a6 <+6>:    mov    r4, r1
   0x415479a8 <+8>:    add    r0, sp, #12
   0x415479aa <+10>:    mov    r1, r5
   0x415479ac <+12>:    mov    r6, r2  <<<<<<jmethodID
   0x415479ae <+14>:    mov    r7, r3
   0x415479b0 <+16>:    bl    0x41543c88 <ScopedJniThreadState::ScopedJniThreadState(_JNIEnv*)>
   0x415479b4 <+20>:    mov    r1, r4
   0x415479b6 <+22>:    ldr    r0, [sp, #12]
   0x415479b8 <+24>:    bl    0x41544d00 <dvmDecodeIndirectRef(Thread*, _jobject*)>
   0x415479bc <+28>:    mov    r4, r0
   0x415479be <+30>:    bl    0x41543974 <canAllocClass(ClassObject*)>
   0x415479c2 <+34>:    cbz    r0, 0x41547a02 <NewObjectV(JNIEnv*, jclass, jmethodID, va_list)+98>
   0x415479c4 <+36>:    ldr    r3, [r4, #44]    ; 0x2c
   0x415479c6 <+38>:    cmp    r3, #7
   0x415479c8 <+40>:    beq.n    0x415479e8 <NewObjectV(JNIEnv*, jclass, jmethodID, va_list)+72>
   0x415479ca <+42>:    mov    r0, r4
   0x415479cc <+44>:    bl    0x41566010 <dvmInitClass(ClassObject*)>
   0x415479d0 <+48>:    cbnz    r0, 0x415479e8 <NewObjectV(JNIEnv*, jclass, jmethodID, va_list)+72>
   0x415479d2 <+50>:    b.n    0x41547a02 <NewObjectV(JNIEnv*, jclass, jmethodID, va_list)+98>
   0x415479d4 <+52>:    add    r3, sp, #16
   0x415479d6 <+54>:    ldr    r0, [sp, #12]

   0x415479d8 <+56>:    mov    r1, r6  <<<<<<jmethodID
   0x415479da <+58>:    mov    r2, r4  <<<<<<Object*

   0x415479dc <+60>:    stmia.w    sp, {r3, r7}
   0x415479e0 <+64>:    movs    r3, #1

   0x415479e2 <+66>:    bl    0x4155ac24 <dvmCallMethodV(Thread*, Method const*, Object*, bool, JValue*, std::__va_list)>
=> 0x415479e6 <+70>:    b.n    0x41547a04 <NewObjectV(JNIEnv*, jclass, jmethodID, va_list)+100>
   0x415479e8 <+72>:    mov    r0, r4
```

其中，栈里的数据录下：

```
0x7598f788:    0x7598f798    0x7598f7d8    0x00000000    0x753d0628
                                Thread*
0x7598f798:    0x4185ceb0    0x415477c5    0x753d0cc8    0x415479a1
                                r4
0x7598f7a8:    0x753d0cc8    0x754034bc    0x753ff80a    0x753f0bbd
        r5        r6        r7        lr
```

这里的参数Method*依然是从上一级函数传下来的。
再往上推一个函数：

```
    0x753f0b84:    push    {r3}
    0x753f0b86:    push    {r0, r1, r4, r5, r6, r7, lr}
    0x753f0b88:    ldr    r3, [r0, #0]
    0x753f0b8a:    adds    r5, r0, #0
    0x753f0b8c:    adds    r7, r2, #0
    0x753f0b8e:    ldr    r3, [r3, #24]
    0x753f0b90:    blx    r3          <<<<<<FindClass()
    0x753f0b92:    ldr    r6, [pc, #52]    ; (0x753f0bc8)
    0x753f0b94:    adds    r1, r0, #0
    0x753f0b96:    add    r6, pc
    0x753f0b98:    str    r0, [r6, #0]
    0x753f0b9a:    cmp    r0, #0
    0x753f0b9c:    beq.n    0x753f0bbe

    0x753f0b9e:    ldr    r3, [r5, #0]
    0x753f0ba0:    adds    r2, r7, #0
    0x753f0ba2:    adds    r0, r5, #0
    0x753f0ba4:    adds    r3, #8
    0x753f0ba6:    ldr    r4, [r3, #124]    ; 0x7c

    0x753f0ba8:    ldr    r3, [sp, #28]    ()v

    0x753f0baa:    blx    r4        <<<<<<GetMethodID(FindClass("android/telephony/TelephonyManager"),"<init>","()V")

    0x753f0bac:    adds    r2, r0, #0

    0x753f0bae:    ldr    r0, [r5, #0]
    0x753f0bb0:    add    r3, sp, #32
    0x753f0bb2:    str    r3, [sp, #4]
    0x753f0bb4:    ldr    r4, [r0, #116]    ; 0x74
    0x753f0bb6:    ldr    r1, [r6, #0]
    0x753f0bb8:    adds   r0, r5, #0

==> 0x753f0bba:    blx    r4        <<<<<<NewObjectV()
    0x753f0bbc:    str    r0, [r6, #4]
    0x753f0bbe:    pop    {r0, r1, r4, r5, r6, r7}
```

其中，栈里的数据录下：

0x7598f7b8:    0x753d0cc8    0x7598f7d8    0x753d0cc8    0x753c86a8
        r0        r1        r4        r5
0x7598f7c8:    0x753d0cc8    0x400c6384    0x753f0d35    0x753ff19c
        r6        r7        lr              r3

这里的r2是参数Method*，它是"0x753f0baa:    blx    r4"函数调用的返回值。

```
    0x753f0b86:    push    {r0, r1, r4, r5, r6, r7, lr}
    0x753f0b8a:    adds    r5, r0, #0
    ...
    0x753f0b9e:    ldr    r3, [r5, #0]
    0x753f0ba0:    adds    r2, r7, #0
    0x753f0ba2:    adds    r0, r5, #0
    0x753f0ba4:    adds    r3, #8
    0x753f0ba6:    ldr    r4, [r3, #124]    ; 0x7c
    0x753f0ba8:    ldr    r3, [sp, #28]    ()v
    0x753f0baa:    blx    r4
    0x753f0bac:    adds    r2, r0, #0
```

从栈里的值可以知道，这里r0 = 0x753d0cc8

```
(gdb) x 0x415a43e4+8+0x7c

0x415a4468 <_ZL16gNativeInterface+132>:    0x415477c5
```

r4的值是0x415477c5
原来是GetMethodID()。这个函数返回值为空了，那八成是它的参数不对。

```
(gdb) disassemble 0x415477c5
Dump of assembler code for function GetMethodID(JNIEnv*, jclass, char const*, char const*):
   0x415477c4 <+0>:    stmdb    sp!, {r4, r5, r6, r7, r8, r9, lr}
   0x415477c8 <+4>:    mov    r5, r0
   0x415477ca <+6>:    sub    sp, #20
   0x415477cc <+8>:    mov    r4, r1
```

再看看它的参数怎么来的:

```
   0x753f0b84:    push    {r3}
   0x753f0b86:    push    {r0, r1, r4, r5, r6, r7, lr}
   0x753f0b88:    ldr    r3, [r0, #0]
   0x753f0b8a:    adds    r5, r0, #0
   0x753f0b8c:    adds    r7, r2, #0
   0x753f0b8e:    ldr    r3, [r3, #24]
   0x753f0b90:    blx    r3
   0x753f0b92:    ldr    r6, [pc, #52]    ; (0x753f0bc8)
   0x753f0b94:    adds    r1, r0, #0
   0x753f0b96:    add    r6, pc
   0x753f0b98:    str    r0, [r6, #0]
   0x753f0b9a:    cmp    r0, #0
   0x753f0b9c:    beq.n    0x753f0bbe
   0x753f0b9e:    ldr    r3, [r5, #0]
   0x753f0ba0:    adds    r2, r7, #0
   0x753f0ba2:    adds    r0, r5, #0
   0x753f0ba4:    adds    r3, #8
   0x753f0ba6:    ldr    r4, [r3, #124]    ; 0x7c
   0x753f0ba8:    ldr    r3, [sp, #28]
   # GetMethodID(FindClass("android/telephony/TelephonyManager"),"<init>","()V")

   0x753f0baa:    blx    r4
```

### 第一个参数 - r0

```
r0 = 0x753d0cc8
```

### 第二个参数 - r1

是"blx    r3"的返回值。它存在r6里，如下：

```
   0x753f0b90:    blx    r3
   0x753f0b92:    ldr    r6, [pc, #52]    ; (0x753f0bc8)
   0x753f0b94:    adds   r1, r0, #0
   0x753f0b96:    add    r6, pc
   0x753f0b98:    str    r0, [r6, #0]
   0x753f0b9a:    cmp    r0, #0
```

```
(gdb) x 0x753f0bc8
0x753f0bc8:    0x00012922
(gdb) x 0x753f0b98+0x00012922+2
0x754034bc:    0x4185ceb0
```

r1 = 0x4185ceb0，根据GetMethodID定义可知它的类型是ClassObject*

```
(gdb) p *(ClassObject*)0x4185ceb0
$14 = {
  <Object> = {
    clazz = 0x416cc1e8,
    lock = 0
  },
  members of ClassObject:
  instanceData = {0, 0, 0, 0},
  descriptor = 0x6f21a8b9 <Address 0x6f21a8b9 out of bounds>,
  ...
```

通过map表，可以知道这个descriptor是/data/dalvik-cache/system@framework@framework.jar@classes.dex
@maps_5299

```
6ec5c000-6edd4000 r--p 00000000 b3:1b 40972      /data/dalvik-cache/system@framework@framework.jar@classes.dex
6edd4000-6edd5000 r--p 00178000 b3:1b 40972      /data/dalvik-cache/system@framework@framework.jar@classes.dex
6edd5000-6edd9000 r--p 00179000 b3:1b 40972      /data/dalvik-cache/system@framework@framework.jar@classes.dex
...
6f14b000-6f14c000 r--p 004ef000 b3:1b 40972      /data/dalvik-cache/system@framework@framework.jar@classes.dex
6f14c000-6f5b0000 r--p 004f0000 b3:1b 40972      /data/dalvik-cache/system@framework@framework.jar@classes.dex
6f5b0000-6f669000 rw-p 00000000 00:04 9331       /dev/ashmem/dalvik-aux-structure (deleted)
```

计算相对偏移

```
(gdb) p /x 0x6f21a8b9-0x6ec5c000
$15 = 0x5be8b9
```

从手机中导出/data/dalvik-cache/system@framework@framework.jar@classes.dex，用二进制编辑器查看

```
@/data/dalvik-cache/system@framework@framework.jar@classes.dex
0x5be8b9:
24 4C 61 6E 64 72 6F 69 64 2F 74 65 6C 65 70 68 6F 6E 79 2F 54 65 6C 65 70 68 6F 6E 79 4D 61 6E 61 67 65 72 3B 00
$Landroid/telephony/TelephonyManager;
```

发现这个类是android/telephony/TelephonyManager。

这里的blx r3通过推导也很容易知道是调用FindClass()，
也就是说这里通过FindClass()找到了android/telephony/TelephonyManager类。

### 第三个参数：

```
    0x753f0ba0:    adds    r2, r7, #0
```

这里r7的值直接取下一级函数NewObjectV()对应的栈里面取就是了。

```
0x7598f788:    0x7598f798    0x7598f7d8    0x00000000    0x753d0628
                                Thead*
0x7598f798:    0x4185ceb0    0x415477c5    0x753d0cc8    0x415479a1
                                r4
0x7598f7a8:    0x753d0cc8    0x754034bc    0x753ff80a    0x753f0bbd
        r5        r6        r7        lr
r2 = 0x753ff80a
753e2000-75402000 r-xp 00000000 00:00 0
```

根据GetMethodID定义可知他是一个字符串：

```
(gdb) x /8c 0x753ff80a
0x753ff80a:    60 '<'    105 'i'    110 'n'    105 'i'    116 't'    62 '>'    0 '\000'
<init>
```

### 第四个参数：

r3 就是第一句话中压入栈里的 0x753ff19c，根据GetMethodID定义可知他是一个字符串：

```
(gdb) x /10c  0x753ff19c
0x753ff19c:    40 '('    41 ')'    86 'V'    0 '\000'
```

所以第四个参数是字符串"()V"

至此，这里大概的逻辑是这样的

```
jclass localClass = env->FindClass("android/telephony/TelephonyManager");
jmethodID localCtor = env->GetMethodID(localClass,"<init>","()V")
jobject localObject = env->NewObject(localClass,localCtor,NULL)
```

也就是在调用android/telephony/TelephonyManager的无参构造函数的时候死掉的。

查找代码，发现

```
miui/frameworks/telephony/base/java/android/telephony/TelephonyManager.java
中，确实没有android/telephony/TelephonyManager的无参构造函数。
```

查了下原生代码是有无参构造函数。

修改miui/frameworks/telephony/base/java/android/telephony/TelephonyManager.java

增加无参构造函数后问题得到解决，不再crash。
