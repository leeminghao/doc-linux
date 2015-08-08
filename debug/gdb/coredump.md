CoreDump
========================================

open coredump
----------------------------------------

### 1. 打开kernel宏开关

```
@kernel/arch/arm/Kconfig
config ARM
        bool
        default y
        select HAVE_AOUT
        select HAVE_DMA_API_DEBUG
        ...
+       select ELF_CORE
        ...
        select HAVE_BPF_JIT if NET
        help
        ...
```

### 2.修改rc文件

```
@init.pisces.rc
on early-init
+   # set core dump resource limit piaoyingmin@xiaomi.com
+   setrlimit 4 2147483647 2147483647

+   # coredump file will not be generated in release version
+   write /proc/sys/kernel/core_pattern /dev/null

on post-fs-data
+   mkdir /data/tombstones 0711 system system
+   mkdir /data/corefile
+   chmod 777 /data/corefile

on property:ro.debuggable=1
+   #enable core dump for debug version
+   write /proc/sys/kernel/core_pattern /data/corefile/core-%e-%p
+   write /proc/sys/fs/suid_dumpable 1：q
```

### 3. 修改虚拟机

```
@dalvik/vm/native/dalvik_system_Zygote.cpp
static void enableDebugFeatures(u4 debugFlags)
{
    ...
#ifdef HAVE_ANDROID_OS
    if ((debugFlags & DEBUG_ENABLE_DEBUGGER) != 0) {
        /* To let a non-privileged gdbserver attach to this
         * process, we must set its dumpable bit flag. However
         * we are not interested in generating a coredump in
         * case of a crash, so also set the coredump size to 0
         * to disable that
         */
        if (prctl(PR_SET_DUMPABLE, 1, 0, 0, 0) < 0) {
            ALOGE("could not set dumpable bit flag for pid %d: %s",
                 getpid(), strerror(errno));
        } else {
            struct rlimit rl;
+#if 0
            rl.rlim_cur = 0;
            rl.rlim_max = RLIM_INFINITY;
+#else
+           rl.rlim_cur = -1;
+           rl.rlim_max = -1;
+#endif
```

如何触发coredump
----------------------------------------

coredump是kernel的信号处理函数作的，它会判断当前信号的默认处理类型是否为coredump，如果是则进入dump流程
关于信号及其默认处理类型如下：

 *      +--------------------+------------------+
 *      |  POSIX signal      |  default action  |
 *      +--------------------+------------------+
 *      |  SIGHUP            |  terminate       |
 *      |  SIGINT            |  terminate       |
 *      |  SIGQUIT           |  coredump        |
 *      |  SIGILL            |  coredump        |
 *      |  SIGTRAP           |  coredump        |
 *      |  SIGABRT/SIGIOT    |  coredump        |
 *      |  SIGBUS            |  coredump        |
 *      |  SIGFPE            |  coredump        |
 *      |  SIGKILL           |  terminate(+)    |
 *      |  SIGUSR1           |  terminate       |
 *      |  SIGSEGV           |  coredump        |
 *      |  SIGUSR2           |  terminate       |
 *      |  SIGPIPE           |  terminate       |
 *      |  SIGALRM           |  terminate       |
 *      |  SIGTERM           |  terminate       |
 *      |  SIGCHLD           |  ignore          |
 *      |  SIGCONT           |  ignore(*)       |
 *      |  SIGSTOP           |  stop(*)(+)      |
 *      |  SIGTSTP           |  stop(*)         |
 *      |  SIGTTIN           |  stop(*)         |
 *      |  SIGTTOU           |  stop(*)         |
 *      |  SIGURG            |  ignore          |
 *      |  SIGXCPU           |  coredump        |
 *      |  SIGXFSZ           |  coredump        |
 *      |  SIGVTALRM         |  terminate       |
 *      |  SIGPROF           |  terminate       |
 *      |  SIGPOLL/SIGIO     |  terminate       |
 *      |  SIGSYS/SIGUNUSED  |  coredump        |
 *      |  SIGSTKFLT         |  terminate       |
 *      |  SIGWINCH          |  ignore          |
 *      |  SIGPWR            |  terminate       |
 *      |  SIGRTMIN-SIGRTMAX |  terminate       |
 *      +--------------------+------------------+
 *      |  non-POSIX signal  |  default action  |
 *      +--------------------+------------------+
 *      |  SIGEMT            |  coredump        |
 *      +--------------------+------------------+

其中SIGQUIT是android重新定义了信号处理函数，用作dump java trace。

我们native crash里常见的SIGBUS、SIGABRT、SIGSEGV都是coredump类型的。
所以一旦程序出了上述类型的错误，就会自动进入coredump。

我们也可以在有root权限的情况下，adb shell后用kill -11 {pid}命令来主动出发coredump
（注意亮屏下要敲2～3下才会进入dump流程）。

【生成的dump的文件在哪】

```
/data/corefile/core_***_{pid}
```

【如何分析coredump】
----------------------------------------

### 步骤1：获取工具

prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.7/bin/arm-linux-androideabi-gdb

### 步骤2：准备symbols

out/target/product/pisces/symbols/ (必须要跟手机coredump时的版本一致！)

### 步骤3：进入gdb环境(直接运行gdb即可)

```
$ prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.7/bin/arm-linux-androideabi-gdb
GNU gdb (GDB) 7.6
Copyright (C) 2013 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
and "show warranty" for details.
This GDB was configured as "--host=x86_64-linux-gnu --target=arm-linux-android".
For bug reporting instructions, please see:
<http://source.android.com/source/report-bugs.html>.
(gdb)
```

### 步骤4：装载可执行程序

```
(gdb) file out/target/product/pisces/symbols/system/bin/app_process
Reading symbols from /home/mi/workspace/0-mi3_v6/out/target/product/pisces/symbols/system/bin/app_process...done.
```

### 步骤5：配置动态库搜索路径

```
(gdb) set solib-search-path out/target/product/pisces/symbols/system/lib
```

### 步骤6：装载core文件

```
(gdb) core core-du.map.location-1804
warning: core file may not match specified executable file.
[New LWP 1804]
[New LWP 1824]
[New LWP 2210]
[New LWP 2320]
[New LWP 1826]
[New LWP 1818]
[New LWP 2062]
[New LWP 1819]
[New LWP 1813]
[New LWP 1817]
[New LWP 1808]
[New LWP 1814]
[New LWP 1815]
[New LWP 2076]
[New LWP 1992]
warning: Could not load shared library symbols for 3 libraries, e.g. /system/bin/linker.
Use the "info sharedlibrary" command to see the complete listing.
Do you need "set solib-search-path" or "set sysroot"?
Core was generated by `com.baidu.map.location                                                     '.
Program terminated with signal 11, Segmentation fault.
#0  epoll_wait () at bionic/libc/arch-arm/syscalls/epoll_wait.S:10
10        mov     r7, ip
```

到此已经是在gdb环境下了

【GDB常用命令】
----------------------------------------

```
bt: 打印调用栈
(gdb) bt
#0  epoll_wait () at bionic/libc/arch-arm/syscalls/epoll_wait.S:10
#1  0x401275ea in android::Looper::pollInner (this=this@entry=0x747fd3f0, timeoutMillis=<optimized out>, timeoutMillis@entry=85688516) at system/core/libutils/Looper.cpp:223
#2  0x40127814 in android::Looper::pollOnce (this=0x747fd3f0, timeoutMillis=85688516, outFd=outFd@entry=0x0, outEvents=outEvents@entry=0x0, outData=outData@entry=0x0)
    at system/core/libutils/Looper.cpp:191
#3  0x401d13dc in pollOnce (timeoutMillis=<optimized out>, this=<optimized out>) at system/core/include/utils/Looper.h:176
#4  android::NativeMessageQueue::pollOnce (this=0x747fef58, env=0x4151dfa8, timeoutMillis=<optimized out>) at frameworks/base/core/jni/android_os_MessageQueue.cpp:97
#5  0x4153d310 in dvmPlatformInvoke () at dalvik/vm/arch/arm/CallEABI.S:258
#6  0x4156d8de in dvmCallJNIMethod (args=0x6d5a5e18, pResult=0x4151f568, method=0x6d60e2d8, self=0x4151f558) at dalvik/vm/Jni.cpp:1159
#7  0x41546724 in dalvik_mterp () at dalvik/vm/mterp/out/InterpAsm-armv7-a-neon.S:16240
#8  0x4154d794 in dvmMterpStd (self=self@entry=0x4151f558) at dalvik/vm/mterp/Mterp.cpp:105
#9  0x4154adf8 in dvmInterpret (self=self@entry=0x4151f558, method=method@entry=0x6d68eeb8, pResult=pResult@entry=0xbe88e658) at dalvik/vm/interp/Interp.cpp:1961
#10 0x4158005c in dvmInvokeMethod (obj=obj@entry=0x0, method=method@entry=0x6d68eeb8, argList=argList@entry=0x42dc4350, params=params@entry=0x42dc4278, returnType=returnType@entry=0x416f12a8,
    noAccessCheck=noAccessCheck@entry=false) at dalvik/vm/interp/Stack.cpp:737
#11 0x41587ff6 in Dalvik_java_lang_reflect_Method_invokeNative (args=<optimized out>, pResult=0x4151f568) at dalvik/vm/native/java_lang_reflect_Method.cpp:101
#12 0x41546724 in dalvik_mterp () at dalvik/vm/mterp/out/InterpAsm-armv7-a-neon.S:16240
#13 0x4154d794 in dvmMterpStd (self=self@entry=0x4151f558) at dalvik/vm/mterp/Mterp.cpp:105
#14 0x4154adf8 in dvmInterpret (self=self@entry=0x4151f558, method=method@entry=0x6d682328, pResult=pResult@entry=0xbe88e818) at dalvik/vm/interp/Interp.cpp:1961
#15 0x4157fd78 in dvmCallMethodV (self=0x4151f558, method=method@entry=0x6d682328, obj=obj@entry=0x0, fromJni=fromJni@entry=true, pResult=pResult@entry=0xbe88e818, args=..., args@entry=...)
    at dalvik/vm/interp/Stack.cpp:526
#16 0x415694c6 in CallStaticVoidMethodV (env=<optimized out>, jclazz=<optimized out>, methodID=0x6d682328, args=...) at dalvik/vm/Jni.cpp:2096
#17 0x401b406c in _JNIEnv::CallStaticVoidMethod (this=<optimized out>, clazz=clazz@entry=0x1d500015, methodID=0x6d682328) at libnativehelper/include/nativehelper/jni.h:780
#18 0x401b4d92 in android::AndroidRuntime::start (this=<optimized out>, className=0x4007445a "com.android.internal.os.ZygoteInit", options=<optimized out>)
    at frameworks/base/core/jni/AndroidRuntime.cpp:889
#19 0x400740c2 in main (argc=4, argv=0xbe88e9e8) at frameworks/base/cmds/app_process/app_main.cpp:245

f：切换到调用栈的第n层
(gdb) f 11
#11 0x41587ff6 in Dalvik_java_lang_reflect_Method_invokeNative (args=<optimized out>, pResult=0x4151f568) at dalvik/vm/native/java_lang_reflect_Method.cpp:101
101                    noAccessCheck);

disassemble:显示汇编代码
(gdb) disassemble
Dump of assembler code for function Dalvik_java_lang_reflect_Method_invokeNative(u4 const*, JValue*):
   0x41587f7c <+0>:    stmdb    sp!, {r0, r1, r2, r4, r5, r6, r7, r8, r9, r10, r11, lr}
   0x41587f80 <+4>:    add.w    r4, r0, #12
   0x41587f84 <+8>:    ldmia.w    r4, {r4, r8, r9}
   0x41587f88 <+12>:    mov    r5, r0
   0x41587f8a <+14>:    mov    r11, r1
   0x41587f8c <+16>:    ldr    r6, [r0, #4]
   0x41587f8e <+18>:    ldr    r7, [r0, #8]
   0x41587f90 <+20>:    ldr.w    r10, [r0, #28]
   0x41587f94 <+24>:    ldr    r1, [r5, #24]
   0x41587f96 <+26>:    mov    r0, r4
   0x41587f98 <+28>:    bl    0x4158e828 <dvmSlotToMethod(ClassObject*, int)>
   0x41587f9c <+32>:    ldr    r3, [r0, #4]
   ...

(gdb) disassemble 0x401b406c
Dump of assembler code for function _JNIEnv::CallStaticVoidMethod(_jclass*, _jmethodID*, ...):
   0x401b4058 <+0>:    push    {r2, r3}
   0x401b405a <+2>:    push    {r0, r1, r4, lr}
   0x401b405c <+4>:    add    r3, sp, #16
   0x401b405e <+6>:    ldr    r4, [r0, #0]
   0x401b4060 <+8>:    ldr.w    r2, [r3], #4
   0x401b4064 <+12>:    ldr.w    r4, [r4, #568]    ; 0x238
   0x401b4068 <+16>:    str    r3, [sp, #4]
   0x401b406a <+18>:    blx    r4
   0x401b406c <+20>:    ldmia.w    sp!, {r2, r3, r4, lr}
   0x401b4070 <+24>:    add    sp, #8
   0x401b4072 <+26>:    bx    lr
End of assembler dump.


info reg:查看当前的寄存器直
(gdb) info reg
r0             0x0    0
r1             0x4151dfa8    1095884712
r2             0x10    16
r3             0x0    0
r4             0x4175c138    1098236216
r5             0x6d68eeb8    1835593400
r6             0x0    0
r7             0x42dc4350    1121731408
r8             0x42dc4278    1121731192
r9             0x416f12a8    1097798312
r10            0x0    0
r11            0x4151f568    1095890280
r12            0xbe88e2d8    3196642008
sp             0xbe88e6c0    0xbe88e6c0
lr             0x41587ff7    1096318967
pc             0x41587ff6    0x41587ff6 <Dalvik_java_lang_reflect_Method_invokeNative(u4 const*, JValue*)+122>
cpsr           0x200f0030    537854000

info thread:显示当前进程的所有线程
(gdb) info thread
  Id   Target Id         Frame
  15   LWP 1992          epoll_wait () at bionic/libc/arch-arm/syscalls/epoll_wait.S:10
  14   LWP 2076          epoll_wait () at bionic/libc/arch-arm/syscalls/epoll_wait.S:10
  13   LWP 1815          __futex_syscall3 () at bionic/libc/arch-arm/bionic/futex_arm.S:39
  12   LWP 1814          recvmsg () at bionic/libc/arch-arm/syscalls/recvmsg.S:9
  11   LWP 1808          __futex_syscall3 () at bionic/libc/arch-arm/bionic/futex_arm.S:39
  10   LWP 1817          __futex_syscall3 () at bionic/libc/arch-arm/bionic/futex_arm.S:39
  9    LWP 1813          __rt_sigtimedwait () at bionic/libc/arch-arm/syscalls/__rt_sigtimedwait.S:10
  8    LWP 1819          __futex_syscall3 () at bionic/libc/arch-arm/bionic/futex_arm.S:39
  7    LWP 2062          __futex_syscall3 () at bionic/libc/arch-arm/bionic/futex_arm.S:39
  6    LWP 1818          __futex_syscall3 () at bionic/libc/arch-arm/bionic/futex_arm.S:39
  5    LWP 1826          __ioctl () at bionic/libc/arch-arm/syscalls/__ioctl.S:9
  4    LWP 2320          __ioctl () at bionic/libc/arch-arm/syscalls/__ioctl.S:9
  3    LWP 2210          epoll_wait () at bionic/libc/arch-arm/syscalls/epoll_wait.S:10
  2    LWP 1824          __ioctl () at bionic/libc/arch-arm/syscalls/__ioctl.S:9
* 1    LWP 1804          epoll_wait () at bionic/libc/arch-arm/syscalls/epoll_wait.S:10

t：切换线程
(gdb) t 9
[Switching to thread 9 (LWP 1813)]
#0  __rt_sigtimedwait () at bionic/libc/arch-arm/syscalls/__rt_sigtimedwait.S:10
10        mov     r7, ip
(gdb) bt
#0  __rt_sigtimedwait () at bionic/libc/arch-arm/syscalls/__rt_sigtimedwait.S:10
#1  0x400b039c in sigwait (set=<optimized out>, sig=0x7194ad48) at bionic/libc/bionic/sigwait.cpp:43
#2  0x415716ca in signalCatcherThreadStart (arg=<optimized out>) at dalvik/vm/SignalCatcher.cpp:287
#3  0x41574176 in internalThreadStart (arg=0x747fd9d8) at dalvik/vm/Thread.cpp:1746
#4  0x400aa1d4 in __thread_entry (func=0x41574129 <internalThreadStart(void*)>, arg=0x747fd9d8, tls=0x7194add0) at bionic/libc/bionic/pthread_create.cpp:105
#5  0x400aa36c in pthread_create (thread_out=0x415db07c <gDvm+1188>, attr=<optimized out>, start_routine=0x41574129 <internalThreadStart(void*)>, arg=0x78) at bionic/libc/bionic/pthread_create.cpp:224
#6  0x00000000 in ?? ()

x:查看内存值
(gdb) x /32wx 0x7194ad48
0x7194ad48:    0x00000004    0x6fbf3830    0x415dabd8    0x41573619
0x7194ad58:    0x41700880    0x42dc0768    0x00000005    0x00000001
0x7194ad68:    0x00000001    0x00000000    0x6fbf3830    0x747fd9d8
0x7194ad78:    0x415dabd8    0xbe88e598    0x747fd9d8    0x41574129
0x7194ad88:    0x7184d000    0x415db07c    0x400e92ec    0x41574177
0x7194ad98:    0x747fd9d8    0x00010002    0x747fd9f8    0x41700880
0x7194ada8:    0x7194add0    0x747f85a8    0x41574129    0x400aa1d4
0x7194adb8:    0x747fd9d8    0x747f85a8    0x7194add0    0x00000001

(gdb) x /20c 0xbe88eb48
0xbe88eb48:    47 '/'    115 's'    98 'b'    105 'i'    110 'n'    58 ':'    47 '/'    118 'v'
0xbe88eb50:    101 'e'    110 'n'    100 'd'    111 'o'    114 'r'    47 '/'    98 'b'    105 'i'
0xbe88eb58:    110 'n'    58 ':'    47 '/'    115 's'

p:显示符号
(gdb) p *(Method*)0x6d682328
$1 = {clazz = 0x41755dc0, accessFlags = 9, methodIndex = 0, registersSize = 6, outsSize = 3, insSize = 1, name = 0x6f8c1862 <Address 0x6f8c1862 out of bounds>, prototype = {dexFile = 0x6d5aac48,
    protoIdx = 3750}, shorty = 0x6f88be67 <Address 0x6f88be67 out of bounds>, insns = 0x6f745d98, jniArgInfo = 0, nativeFunc = 0x0, fastJni = false, noRef = false, shouldTrace = false,
  registerMap = 0x71a557d8, inProfile = false}

【若干配置】
set print pretty on     ：结构体显示的漂亮一些
set print union         ：设置显示结构体时，是否显式其内的联合体数据。
set print vtbl          ：当此选项打开时，GDB将用比较规整的格式来显示虚函数表时。其默认是关闭的。
例如：
(gdb)  set print pretty on
(gdb) p *(Method*)0x6d682328
$2 = {
  clazz = 0x41755dc0,
  accessFlags = 9,
  methodIndex = 0,
  registersSize = 6,
  outsSize = 3,
  insSize = 1,
  name = 0x6f8c1862 <Address 0x6f8c1862 out of bounds>,
  prototype = {
    dexFile = 0x6d5aac48,
    protoIdx = 3750
  },
  shorty = 0x6f88be67 <Address 0x6f88be67 out of bounds>,
  insns = 0x6f745d98,
  jniArgInfo = 0,
  nativeFunc = 0x0,
  fastJni = false,
  noRef = false,
  shouldTrace = false,
  registerMap = 0x71a557d8,
  inProfile = false
}
```