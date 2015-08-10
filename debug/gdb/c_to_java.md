c to java
========================================

用GDB的bt命令很容易就能打印native的调用栈

```
(gdb) bt
#0  tgkill () at bionic/libc/arch-arm/bionic/tgkill.S:46
#1  0x40061030 in pthread_kill (t=<optimized out>, sig=6) at bionic/libc/bionic/pthread_kill.cpp:49
#2  0x40061244 in raise (sig=6) at bionic/libc/bionic/raise.cpp:32
#3  0x4005ff9e in __libc_android_abort () at bionic/libc/bionic/abort.cpp:65
#4  0x4006f850 in abort () at bionic/libc/arch-arm/bionic/abort_arm.S:41
#5  0x7217b50c in DebugBreak () at external/chromium_org/base/debug/debugger_posix.cc:233
#6  base::debug::BreakDebugger () at external/chromium_org/base/debug/debugger_posix.cc:257
#7  0x7217910e in base::android::CheckException (env=env@entry=0x414cefa8) at external/chromium_org/base/android/jni_android.cc:204
#8  0x72b2d0dc in Java_ContentViewCore_setTitle (title=0xbe500021, obj=0x240001d, env=0x414cefa8) at out/target/product/pisces/obj/GYP/shared_intermediates/content/jni/ContentViewCore_jni.h:1282
#9  content::ContentViewCoreImpl::SetTitle (this=<optimized out>, title=...) at external/chromium_org/content/browser/android/content_view_core_impl.cc:437
#10 0x72b89dfc in content::WebContentsImpl::UpdateTitleForEntry (this=this@entry=0x76b22280, entry=entry@entry=0x7a0cf7b0, title=...)
    at external/chromium_org/content/browser/web_contents/web_contents_impl.cc:2717
...
```

有时候我们想知道Native Crash时的java调用栈，这时候我们可以用gDvm中的数据来推导java栈。
我们知道gDvm中有一个threadList，它是一个线程链表，可以通过这个链表遍历当前进程中的所有线程。

```
(gdb) p gDvm->threadList
$1 = (Thread *) 0x414d0558

(gdb) p * (Thread *) 0x414d0558
$3 = {
  ...
  threadId = 1,
  ...
  status = THREAD_NATIVE,
  systemTid = 23405,
  interpStackStart = 0x6d557000 "",
  threadObj = 0x416b2ca8,
  jniEnv = 0x414cefa8,
  prev = 0x0,
  next = 0x7b88a3a8,
  ...
}
```

```
(gdb) p * (Thread *) 0x7b88a3a8
$4 = {
  ...
  threadId = 26,
  ...
  status = THREAD_NATIVE,
  systemTid = 25905,
  interpStackStart = 0x77ead000 <Address 0x77ead000 out of bounds>,
  threadObj = 0x42dacd70,
  jniEnv = 0x7a0cff28,
  prev = 0x414d0558,
  next = 0x7a095de0,
  ...
}
```

用info thread命令可以看到，出问题的线程是23405线程，也就是主线程。

```
(gdb) info thread
  Id   Target Id         Frame
  54   LWP 23412         recvmsg () at bionic/libc/arch-arm/syscalls/recvmsg.S:9
  53   LWP 23451         __futex_syscall3 () at bionic/libc/arch-arm/bionic/futex_arm.S:39
  ...
  5    LWP 23460         __futex_syscall3 () at bionic/libc/arch-arm/bionic/futex_arm.S:39
  4    LWP 23418         __ioctl () at bionic/libc/arch-arm/syscalls/__ioctl.S:9
  3    LWP 25905         __ioctl () at bionic/libc/arch-arm/syscalls/__ioctl.S:9
  2    LWP 23417         __ioctl () at bionic/libc/arch-arm/syscalls/__ioctl.S:9
* 1    LWP 23405         tgkill () at bionic/libc/arch-arm/bionic/tgkill.S:46
```

接下来就开始推导主线程的调用栈：

```
(gdb) p *(Thread*)0x414d0558
$3 = {
  interpSave = {
    pc = 0x6e601544,
    curFrame = 0x6d556e20,
    ...
  },
  threadId = 1,
  ...
  status = THREAD_NATIVE,
  systemTid = 23405,
  interpStackStart = 0x6d557000 "",
  threadObj = 0x416b2ca8,
  jniEnv = 0x414cefa8,
  ...
  prev = 0x0,
  next = 0x7b88a3a8,
  ...
}
```

从interpSave的curFrame可以推导最顶层的StackSaveArea，由于
#define SAVEAREA_FROM_FP(_fp)   ((StackSaveArea*)(_fp) -1)
所以最顶层的StackSaveArea为：

```
(gdb) p *(StackSaveArea*)(0x6d556e20-sizeof(StackSaveArea))
$5 = {
  prevFrame = 0x6d556e40,
  savedPc = 0x7015e73c,
  method = 0x6d7d6068,
  ...
}
```

取Method：

```
(gdb) p *(Method*) 0x6d7d6068
$6 = {
  clazz = 0x4187f7b8,
  accessFlags = 258,
  methodIndex = 0,
  registersSize = 3,
  outsSize = 0,
  insSize = 3,
  name = 0x701b6c59 <Address 0x701b6c59 out of bounds>,
  ...
}
```

取Method对应的ClassObject

```
(gdb) p *(ClassObject*) 0x4187f7b8
$7 = {
  ...
  descriptor = 0x7019bc6d <Address 0x7019bc6d out of bounds>,
  ...
}
```

对照map表，发现是这个descriptor的地址是webviewchromium的dex文件。
@maps_23405
```
7012e000-701ef000 r--p 00000000 b3:1b 40987      /data/dalvik-cache/system@framework@webviewchromium.jar@classes.dex
```

descriptor的地址减去dex的起始地址，就得到类名称字符串在dex中的偏移地址。

```
(gdb) p /x 0x7019bc6d-0x7012e000
$8 = 0x6dc6d
```

从手机中pull出来这个dex文件后，用hexdump查看：

```
$ hexdump -C -n64 -s0x6dc6d system@framework@webviewchromium.jar@classes.dex
0006dc6d  4c 63 6f 6d 2f 61 6e 64  72 6f 69 64 2f 6f 72 67  |Lcom/android/org|
0006dc7d  2f 63 68 72 6f 6d 69 75  6d 2f 62 61 73 65 2f 53  |/chromium/base/S|
0006dc8d  79 73 74 65 6d 4d 65 73  73 61 67 65 48 61 6e 64  |ystemMessageHand|
0006dc9d  6c 65 72 3b 00 2b 4c 63  6f 6d 2f 61 6e 64 72 6f  |ler;.+Lcom/andro|
```

可知，这个类的名称是com/android/org/chromium/base/SystemMessageHandler

Method里有name成员，表示函数名，它的偏移地址为：

```
(gdb) p /x 0x701b6c59-0x7012e000
$9 = 0x88c59
```

同样用hexdump就能得到这个函数名

```
$ hexdump -C -n32 -s0x88c59 system@framework@webviewchromium.jar@classes.dex
00088c59  6e 61 74 69 76 65 44 6f  52 75 6e 4c 6f 6f 70 4f  |nativeDoRunLoopO|
00088c69  6e 63 65 00 17 6e 61 74  69 76 65 44 6f 63 75 6d  |nce..nativeDocum|
```

最顶层的函数名为nativeDoRunLoopOnce()
再看看次顶层,次顶层的frame保存在顶层StackSaveArea的prevFrame成员里。

```
(gdb) p *(StackSaveArea*)(0x6d556e20-sizeof(StackSaveArea))
$5 = {
  prevFrame = 0x6d556e40,
  ...
}

(gdb) p *(StackSaveArea*)(0x6d556e20-sizeof(StackSaveArea))
$5 = {
  prevFrame = 0x6d556e40,
  savedPc = 0x7015e73c,
  method = 0x6d7d6068,
  ...
}

(gdb) p *(StackSaveArea*)(0x6d556e40-sizeof(StackSaveArea))
$12 = {
  prevFrame = 0x6d556e64,
  savedPc = 0x6edd27f0,
  method = 0x6d7d6150,
  ...
}

(gdb) p *(Method*) 0x6d7d6150
$13 = {
  clazz = 0x4187f7b8,
  accessFlags = 1,
  methodIndex = 16,
  registersSize = 4,
  outsSize = 3,
  insSize = 2,
  name = 0x701b091d <Address 0x701b091d out of bounds>,
  ...
}
```

clazz和顶层的一样是com/android/org/chromium/base/SystemMessageHandler
name的偏移地址：

```
(gdb) p /x 0x701b091d-0x7012e000
$17 = 0x8291d
```

函数名为handleMessage()

```
$ hexdump -C -n32 -s0x8291d system@framework@webviewchromium.jar@classes.dex
0008291d  68 61 6e 64 6c 65 4d 65  73 73 61 67 65 00 0e 68  |handleMessage..h|
0008292d  61 6e 64 6c 65 4e 61 76  69 67 61 74 65 00 10 68  |andleNavigate..h|
```

再推导下一个

```
(gdb) p *(StackSaveArea*)(0x6d556e64-sizeof(StackSaveArea))
$34 = {
  prevFrame = 0x6d556e84,
  savedPc = 0x6efdd434,
  method = 0x6d5f75a0,
  ...
}

(gdb) p *(Method*)0x6d5f75a0
$35 = {
  clazz = 0x416e0ad8,
  accessFlags = 1,
  methodIndex = 11,
  registersSize = 3,
  outsSize = 2,
  insSize = 2,
  name = 0x6f28d6c6 <Address 0x6f28d6c6 out of bounds>,
  ...
}

(gdb) p *(ClassObject*)0x416e0ad8
$36 = {
  ...
  descriptor =  <Address 0x6f1e621b out of bounds>,
  ...
}
```

@maps_23405

```
6ec32000-6edaa000 r--p 00000000 b3:1b 40972      /data/dalvik-cache/system@framework@framework.jar@classes.dex
...
6f127000-6f586000 r--p 004f5000 b3:1b 40972      /data/dalvik-cache/system@framework@framework.jar@classes.dex
```

```
(gdb) p /x 0x6f1e621b-0x6ec32000
$40 = 0x5b421b

$ hexdump -C -n32 -s0x5b421b system@framework@framework.jar@classes.dex
005b421b  4c 61 6e 64 72 6f 69 64  2f 6f 73 2f 48 61 6e 64  |Landroid/os/Hand|
005b422b  6c 65 72 3b 00 1a 4c 61  6e 64 72 6f 69 64 2f 6f  |ler;..Landroid/o|

(gdb) p /x 0x6f28d6c6-0x6ec32000
$41 = 0x65b6c6

$ hexdump -C -n32 -s0x65b6c6 system@framework@framework.jar@classes.dex
0065b6c6  64 69 73 70 61 74 63 68  4d 65 73 73 61 67 65 00  |dispatchMessage.|
0065b6d6  0d 64 69 73 70 61 74 63  68 4d 6f 76 65 64 00 11  |.dispatchMoved..|
```

得到的调用栈大概就是
com.android.org.chromium.base.SystemMessageHandler.nativeDoRunLoopOnce
com.android.org.chromium.base.SystemMessageHandler.handleMessage
android.os.Handler.dispatchMessage
...
