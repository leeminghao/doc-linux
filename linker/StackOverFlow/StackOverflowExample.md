一个Android系统OTA升级过程由于Stack Overflow导致的失败实例
================================================================================

首先，我们大致了解下Android OTA升级的大致流程:
具体过程如下图所示: 应用层Updater同过本地socket向otad发送installupdate命令以及参数
请求otad进行ota升级，otad服务接收到命令之后fork子进程update-binary来进行真正的ota工作,
此时otad等待子进程update-binary执行，并将update-binary进行升级的进度信息和状态信息发送
给otad服务, 最终传递给应用Updater..

```
  updater(Application)
    |
installupdate(command)
    |
   otad(server) --fork--> update(otad child, real update)
```

大致了解了ota升级的流程之后，我们来看发生ota失败问题的log, 如下所示:

```
// 这个是ota对应服务中打印出来的
09-15 14:47:15.928   256   256 E OTA     : Update system failed, status=0x0006
```

这log对应的代码如下所示:

path: system/otad/commands.c
```
#define UPDATER "/data/local/tmp/update-binary"
#define ASSUMED_UPDATE_BINARY_NAME "META-INF/com/google/android/update-binary"
...
int install_update(int s, const char *update_package, const char *logfile)
{
    ...
    ZipArchive zip;
    int err = mzOpenZipArchive(update_package, &zip);
    ...
    const ZipEntry* binary_entry = mzFindZipEntry(&zip, ASSUMED_UPDATE_BINARY_NAME);
    ...
    unlink(UPDATER);
    int fd = creat(UPDATER, 0750);
    ...
    bool ok = mzExtractZipEntryToFile(&zip, binary_entry, fd);
    ...
    int pipefd[2];
    ...
    pid_t pid = fork();
    ...

    if (pid == 0) {
        ...
        char **args = malloc(sizeof(char*) * 6);
        args[0] = UPDATER;
        args[1] = EXPAND(RECOVERY_API_VERSION);
        args[2] = (char*)malloc(10);
        sprintf(args[2], "%d", pipefd[1]);
        args[3] = (char*)update_package;
        args[4] = (char*)malloc(10);
        sprintf(args[4], "%d", buddy_system_id);
        args[5] = NULL;

        execv(UPDATER, args);
        // 如果是执行execv函数失败的话那么将打印如下信息, 但是从搜集的log来看，update-binary
        // 肯定是成功执行了，因为如下的错误信息并没有打印出来.
        ALOGE("failed to execute updater: %s\n", strerror(errno));
        exit(1);
    }
    ...
    int status;
    waitpid(pid, &status, 0);
    updater_pid = -1;
    if (WIFEXITED(status) && WEXITSTATUS(status) == 0) {
        ALOGV("Update system succeeded\n");
        return 0;
    } else {
        umount(MOUNT_POINT_SYSTEM);
        umount(MOUNT_POINT_DATA);
        // 09-15 14:47:15.928   256   256 E OTA     : Update system failed, status=0x0006
        // 根据log发现是由于update-binary进程发生异常退出导致ota升级失败
        ALOGE("Update system failed, status=0x%04x\n", status);
        return status;
    }
}
```

于是check install.log这个log文件保存的是update-binary在升级过程中的各种流程信息.

其信息如下所示:

/data/data/com.android.updater/cache/install.log
```
Creating filesystem with parameters:
    Size: 671088640
    Block size: 4096
    Blocks per group: 32768
    Inodes per group: 8192
    Inode size: 256
    Journal blocks: 2560
    Label:
    Blocks: 163840
    Block groups: 5
    Reserved block group size: 39
Created filesystem with 11/40960 inodes and 5256/163840 blocks
minzip: Extracted 2 file(s)
```

查看了install.log后发现update-binary在解压缩了两个文件之后,后续流程就中断了，根据当前log
无法判断出是如何中断的，于是,

再次跟踪update-binary进程在升级过程中的log check是否有异常迹象，最终定位到如下log
```
// 这个是update-binary进程中打印出来的
09-15 14:47:15.008  3661  3661 F libc    : stack corruption detected
```

3661进程就是update-binary,发现一条非常有意思的log --> "stack corruption detected"

根据log锁定代码出错位置:

path: bionic/libc/bionic/__stack_chk_fail.cpp
```
void __stack_chk_fail() {
   __libc_fatal("stack corruption detected");
}
```

path: bionic/libc/bionic/libc_logging.cpp
```
void __libc_fatal(const char* format, ...) {
  va_list args;
  va_start(args, format);
  __libc_fatal(format, args);
  va_end(args);
  abort();
}
```

综上代码分析可知，正是由于update-binary进程因为某种原因执行了libc中的__stack_chk_fail函数
最终导致异常退出. 可是仅凭上述信息根本无法定位出具体代码出错的位置. 我们只得缩小范围, 我们
采取如下两种方法定位出出错代码函数:

* 在ota升级包中直接修改updater-script edify脚本找到是在解压缩system目录中文件出错.

* 在bootable/recovery目录中的updater和minzip目录中添加log定位出是在解压缩Settings.apk的时候出错.

出错的地方非常有意思,如下所示:
```
minzip: we will extract: targetFile = /data/buddy/system/priv-app/SecurityCenter.apk
minzip: we will call mzProcessZipEntryContents

minzip: processDeflatedEntry
minzip: processDeflatedEntry sucessuly
minzip: processDeflatedEntry finished

minzip: we have finished mzProcessZipEntryContents
minzip: Extracted file "/data/buddy/system/priv-app/SecurityCenter.apk"

minzip: we will extract: targetFile = /data/buddy/system/priv-app/Settings.apk
minzip: we will call mzProcessZipEntryContents
minzip: processDeflatedEntry
minzip: processDeflatedEntry sucessuly
```

根据我们添加的log来分析代码:

path: bootable/recovery/minzip/Zip.c
```
bool mzProcessZipEntryContents(const ZipArchive *pArchive,
    const ZipEntry *pEntry, ProcessZipEntryContentsFunction processFunction,
    void *cookie)
{
    ...
    switch (pEntry->compression) {
    ...
    case DEFLATED:
        ret = processDeflatedEntry(pArchive, pEntry, processFunction, cookie);
        // log: minzip: processDeflatedEntry finished
        // 是在这个位置打印的
        break;
    }

    return ret;
}

static bool processDeflatedEntry(const ZipArchive *pArchive,
    const ZipEntry *pEntry, ProcessZipEntryContentsFunction processFunction,
    void *cookie)
{
    // log: minzip: processDeflatedEntry
    // 是在这个位置打印
    long result = -1;
    unsigned char readBuf[32 * 1024];
    unsigned char procBuf[32 * 1024];
    z_stream zstream;
    int zerr;
    long compRemaining;

    compRemaining = pEntry->compLen;

    /*
     * Initialize the zlib stream.
     */
    memset(&zstream, 0, sizeof(zstream));
    zstream.zalloc = Z_NULL;
    zstream.zfree = Z_NULL;
    zstream.opaque = Z_NULL;
    zstream.next_in = NULL;
    zstream.avail_in = 0;
    zstream.next_out = (Bytef*) procBuf;
    zstream.avail_out = sizeof(procBuf);
    zstream.data_type = Z_UNKNOWN;

    /*
     * Use the undocumented "negative window bits" feature to tell zlib
     * that there's no zlib header waiting for it.
     */
    zerr = inflateInit2(&zstream, -MAX_WBITS);
    if (zerr != Z_OK) {
        if (zerr == Z_VERSION_ERROR) {
            LOGE("Installed zlib is not compatible with linked version (%s)\n",
                ZLIB_VERSION);
        } else {
            LOGE("Call to inflateInit2 failed (zerr=%d)\n", zerr);
        }
        goto bail;
    }

    /*
     * Loop while we have data.
     */
    do {
        /* read as much as we can */
        if (zstream.avail_in == 0) {
            long getSize = (compRemaining > (long)sizeof(readBuf)) ?
                        (long)sizeof(readBuf) : compRemaining;
            LOGVV("+++ reading %ld bytes (%ld left)\n",
                getSize, compRemaining);

            int cc = read(pArchive->fd, readBuf, getSize);
            if (cc != (int) getSize) {
                LOGW("inflate read failed (%d vs %ld)\n", cc, getSize);
                goto z_bail;
            }

            compRemaining -= getSize;

            zstream.next_in = readBuf;
            zstream.avail_in = getSize;
        }

        /* uncompress the data */
        zerr = inflate(&zstream, Z_NO_FLUSH);
        if (zerr != Z_OK && zerr != Z_STREAM_END) {
            LOGD("zlib inflate call failed (zerr=%d)\n", zerr);
            goto z_bail;
        }

        /* write when we're full or when we're done */
        if (zstream.avail_out == 0 ||
            (zerr == Z_STREAM_END && zstream.avail_out != sizeof(procBuf)))
        {
            long procSize = zstream.next_out - procBuf;
            LOGVV("+++ processing %d bytes\n", (int) procSize);
            bool ret = processFunction(procBuf, procSize, cookie);
            if (!ret) {
                LOGW("Process function elected to fail (in inflate)\n");
                goto z_bail;
            }

            zstream.next_out = procBuf;
            zstream.avail_out = sizeof(procBuf);
        }
    } while (zerr == Z_OK);

    assert(zerr == Z_STREAM_END);       /* other errors should've been caught */

    // success!
    result = zstream.total_out;

z_bail:
    inflateEnd(&zstream);        /* free up any allocated structures */

bail:
    if (result != pEntry->uncompLen) {
        if (result != -1)        // error already shown?
            LOGW("Size mismatch on inflated file (%ld vs %ld)\n",
                result, pEntry->uncompLen);
        return false;
    }
    // log: minzip: processDeflatedEntry sucessuly
    // 是在这个位置打印
    return true;
}
```

对比SecurityCenter.apk和Settings.apk解压缩的log我们很快就发现在调用函数processDeflatedEntry来
解压缩Settings.apk的时候在返回到mzProcessZipEntryContents函数出错不再往下执行了，出现的错误就是:

```
09-15 14:47:15.008  3661  3661 F libc    : stack corruption detected
```

这究竟是为什么呢？processDeflatedEntry函数都执行完成了，而且检查/system/priv-app/下也发现了
解压缩成功的Settings.apk(push可用),可是仅仅在函数返回过程中报出了如上所示错误.

在函数返回过程中究竟发生了什么? 为什么没有返回到调用函数中继续执行?

抱着这样的疑问，我们不得不反汇编processDefaltedEntry函数查看对应的汇编代码, 由于反汇编出来代码
太长了，我们只关注函数调用返回的时候所执行的代码.
函数汇编实现如下所示:

```
    # 根据arm过程调用的规定，stmdb是预先减少存储，先修改sp栈顶指针，然后将调用processDeflatedEntry
    # 函数的r4-r14寄存器值压栈,特别注意fp指针是函数的栈帧指针.
    /* 开始执行processDefaltedEntry函数 */
    83a8:    e92d 4ff0     stmdb    sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
    83ac:    469b          mov    fp, r3

    83ae:    4b4f          ldr    r3, [pc, #316]    ; (84ec <processDeflatedEntry+0x144>)
    83b0:    4692          mov    sl, r2
    83b2:    4a4f          ldr    r2, [pc, #316]    ; (84f0 <processDeflatedEntry+0x148>)
    83b4:    4681          mov    r9, r0
    83b6:    447b          add    r3, pc

    # 在当前函数processDeflatedEntry栈中为临时变量分配空间大小
    # 65536 正好是64KB = readBuf + procBuf的大小
    83b8:    f5ad 3d80     sub.w    sp, sp, #65536    ; 0x10000
    # 下面是为其余的临时变量分配空间.
    83bc:    b093          sub    sp, #76    ; 0x4c


    # 由于反汇编出来的代码实在太长了，什么都不管，先来找到函数返回过程执行的代码，
    # **注意**:
    # arm架构cpu的堆栈是自高地址向低地址增长,所以指向栈顶的寄存器sp总是指向的是低地址位置,
    # 一般默认是使用小端存储来存储数据的(也就是高字节存储在高地址，低字节存储在低地址).
    # 例如, buffer[10] - buffer[0]元素存储在低地址，buffer[9]元素存储在高地址.
    # 函数调用返回开始的位置
    84ca:    e000          b.n    84ce <processDeflatedEntry+0x126>
    # 将r1寄存器指向距离栈顶64KB的位置
    84ce:    f50d 3180     add.w    r1, sp, #65536    ; 0x10000
    # 取出距离栈顶指针一个字位置处的值
    84d2:    9b01          ldr    r3, [sp, #4]
    # 将r1地址再次上调68各字节
    84d4:    3144          adds    r1, #68    ; 0x44
    84d6:    680a          ldr    r2, [r1, #0]
    84d8:    6819          ldr    r1, [r3, #0]
    # 这里做了一个check,大致的意思就是比较两个栈中什么玩意儿的值,
    # 相等的话就跳转到84e2地址返回到上一级的调用函数继续执行,不相等的话
    # 就要调用__stack_chk_fail函数.
    84da:    428a          cmp    r2, r1
    84dc:    d001          beq.n    84e2 <processDeflatedEntry+0x13a>
    84de:    f004 fc95     bl    ce0c <__stack_chk_fail>

    # 出栈动作
    84e2:    b013          add    sp, #76    ; 0x4c
    84e4:    f50d 3d80     add.w    sp, sp, #65536    ; 0x10000
    # 这里就是返回到调用函数的地方,如果函数调用逻辑能够走到这里，那么就能够正常恢复调用函数的
    # 栈帧指针,就能够成功返回到调用函数中继续执行.
    84e8:    e8bd 8ff0     ldmia.w    sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
```

看到这段反汇编的代码我们明白了，原来gcc编译器做了额外的工作, 在编译程序的时候添加了一段check
程序, 这段check程序就是使我们代码出现分叉导致错误的地方.

到了这里我们初步怀疑是android系统在编译c代码的时候默认打开了函数堆栈检查的标记.

于是查看gcc的编译选项, 看到如下选项:

path: build/core/combo/TARGET_linux-arm.mk
```
TARGET_GLOBAL_CFLAGS += \
    ...
    -fstack-protector \  // 这就是gcc的堆栈保护开关
    ...
```

现代gcc编译器为了防止函数堆栈溢出做了一个堆栈保护选项"-fstack-protector", 这个保护选项的作用就是:
启用堆栈保护，不过只为局部变量中含有 char 数组的函数插入保护代码.

到了这里我们首先通过一个简单的小例子来说明下这个-fstack-protector选项的作用.

https://github.com/leeminghao/doc-linux/blob/master/linker/StackOverFlow/GccSsp.md

通过上述例子我们知道，正是由于android默认打开了这个开关选项，此时如果有代码越界访问char数组
的缓冲区，那么就有可能覆盖gcc在函数堆栈中插入检查缓冲区越界的标志变量: __stack_chk_guard,
此时，根据我们总结的两个规律, 我们在processDeflatedEntry函数中使用了这样一个小技巧，如下
代码所示:

**注意**: 在这里为了说明这个小技巧我们没有把我们所添加的所有log加上，只是为了说明这个问题而已.

```
// 这个变量就是在bionic/libc/bionic/libc_init_common.cpp中定义，并在运行程序的随机进行初始化的
// 这个值会在具有char数组局部变量缓冲区的函数并且在设置-fstack-protector选项编译之后会在函数
// 运行之后保存在紧挨着靠近缓冲区的前一个4字节对齐的字中. 其在每次函数运行时是不变的的，但是
// 根据前面的例子我们知道，如果我们越界访问缓冲区的话极有可能会覆盖其值导致在函数返回时从
// 堆栈中读取出来的值跟直接从GOT表中获取到的不一致就会造成类似错误:
// 09-15 14:47:15.008  3661  3661 F libc    : stack corruption detected
// 最终导致函数执行失败
extern uintptr_t __stack_chk_guard;
uintptr_t *guardptr;

static bool processDeflatedEntry(const ZipArchive *pArchive,
    const ZipEntry *pEntry, ProcessZipEntryContentsFunction processFunction,
    void *cookie)
{
    // 1. 在进入函数执行前打印出__stack_chk_guard值.
    LOGD("__stack_chk_guard=%x\n", __stack_chk_guard);

    long result = -1;
    unsigned char readBuf[32 * 1024];
    unsigned char procBuf[32 * 1024];
    z_stream zstream;
    int zerr;
    long compRemaining;

    // 2. 接着找到其保存在函数堆栈中的地址, 并且输出其值，查看是否和__stack_chk_guard
    // 一致. 其实如何找到保存在堆栈中的__stack_chk_guard值的地址很简单: 根据arm的堆栈
    // 是从高地址向低地址增长; 默认采用小端存储数据; 读取按照4字节对齐; -fstack-protector
    // 选项是针对char数组缓冲区进行check的. 那么这个值存储的位置只有一个地方，那就是:
    // 对应char数组缓冲区最后一个元素所保存的地址字节前一个4字节对齐的地址处.
    // 在这里因为有两个缓冲区, 但是根据实例2，我们知道只可能有一个缓冲区前面的4字节地址
    // 对齐位置保存了__stack_chk_guard变量值. 我们分别实验了两次，找到最终保存在了procBuf
    // 缓冲区的最后一个元素的前一个4字节对齐地址处，我们使用如下代码取出地址值:
    guardptr = (uintptr_t*)procBuf + 8 * 1024; // 8 == 32 / 4
    LOGD("procBuf guardptr=%x\n", *guardptr);

    compRemaining = pEntry->compLen;

    /*
     * Initialize the zlib stream.
     */
    memset(&zstream, 0, sizeof(zstream));
    zstream.zalloc = Z_NULL;
    zstream.zfree = Z_NULL;
    zstream.opaque = Z_NULL;
    zstream.next_in = NULL;
    zstream.avail_in = 0;
    zstream.next_out = (Bytef*) procBuf;
    zstream.avail_out = sizeof(procBuf);
    zstream.data_type = Z_UNKNOWN;

    /*
     * Use the undocumented "negative window bits" feature to tell zlib
     * that there's no zlib header waiting for it.
     */
    zerr = inflateInit2(&zstream, -MAX_WBITS);
    if (zerr != Z_OK) {
        if (zerr == Z_VERSION_ERROR) {
            LOGE("Installed zlib is not compatible with linked version (%s)\n",
                ZLIB_VERSION);
        } else {
            LOGE("Call to inflateInit2 failed (zerr=%d)\n", zerr);
        }
        goto bail;
    }

    /*
     * Loop while we have data.
     */
    do {
        /* read as much as we can */
        if (zstream.avail_in == 0) {
            long getSize = (compRemaining > (long)sizeof(readBuf)) ?
                        (long)sizeof(readBuf) : compRemaining;
            LOGVV("+++ reading %ld bytes (%ld left)\n",
                getSize, compRemaining);

            int cc = read(pArchive->fd, readBuf, getSize);
            if (cc != (int) getSize) {
                LOGW("inflate read failed (%d vs %ld)\n", cc, getSize);
                goto z_bail;
            }

            compRemaining -= getSize;

            zstream.next_in = readBuf;
            zstream.avail_in = getSize;
        }

        /* uncompress the data */
        // 3. 我们在所有能够改变procBuf缓冲区值的函数前后都添加了如下的LOG
        // 就是打印保存在堆栈中的__stack_chk_guard值，查看在什么时候改变的.
        LOGD("check ib guardptr=%x\n", *guardptr);
        zerr = inflate(&zstream, Z_NO_FLUSH);
        LOGD("check ei guardptr=%x\n", *guardptr);
        if (zerr != Z_OK && zerr != Z_STREAM_END) {
            LOGD("zlib inflate call failed (zerr=%d)\n", zerr);
            goto z_bail;
        }

        /* write when we're full or when we're done */
        if (zstream.avail_out == 0 ||
            (zerr == Z_STREAM_END && zstream.avail_out != sizeof(procBuf)))
        {
            long procSize = zstream.next_out - procBuf;
            LOGVV("+++ processing %d bytes\n", (int) procSize);
            bool ret = processFunction(procBuf, procSize, cookie);
            if (!ret) {
                LOGW("Process function elected to fail (in inflate)\n");
                goto z_bail;
            }

            zstream.next_out = procBuf;
            zstream.avail_out = sizeof(procBuf);
        }
    } while (zerr == Z_OK);

    assert(zerr == Z_STREAM_END);       /* other errors should've been caught */

    // success!
    result = zstream.total_out;

z_bail:
    inflateEnd(&zstream);        /* free up any allocated structures */

bail:
    if (result != pEntry->uncompLen) {
        if (result != -1)        // error already shown?
            LOGW("Size mismatch on inflated file (%ld vs %ld)\n",
                result, pEntry->uncompLen);
        return false;
    }

    LOGD("exit guardptr=%x\n", *guardptr);
    return true;
}
```

利用如上所示的小技巧，我们不断的在改变procBuf函数的前后输出堆栈中的__stack_chk_guard值,
并和通过GOT表找到的__stack_chk_guard(也就是直接输出的那个值)进行比较看在哪个调用函数的
地方进行其发生了改变。类似如下的log:

```
minzip: __stack_chk_guard=5ffbedfa
minzip: enter guardptr=5ffbedfa
...
// 这里显示的是在调用inflate函数stack_chk_guard值发生了变化.
minzip: check ib guardptr=5f fb ed fa
minzip: check ei guardptr=5f fb ed d4
...
minzip: exit guardptr=5ffbedd4
```

后续的调试办法就没有什么技巧而言，就是不断类似的缩小查找的范围，最后在external/zlib库中的inflate
函数。该函数会调用一个汇编函数inflate_fast_copy_neon执行拷贝动作，此函数根据不同情况会对拷贝的
大小进行每次4, 8, 16字节这样的拷贝方式。当缓冲区拷贝剩余只有3个字节的时候，由于4字节进行拷贝，后边
的一个字节就会被覆盖(也就是如上log中的fa 变成了 d4)，就这样造成了缓冲区溢出。

最终在函数返回的时候读取了guardptr所指向的保存__stack_chk_guard值的地址处的值同__stack_chk_guard
值进行了比较，不相等的时候就跳转到__stack_chk_fail函数中abort当前执行的函数, 在这里只是为了介绍
c函数的调用方式以及gcc编译器-fstack-protector相关选项的作用，以及这类错误的调试办法，具体我们怎么
修复这个函数的在此就不做赘述.